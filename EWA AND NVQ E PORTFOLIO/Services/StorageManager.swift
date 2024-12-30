import Foundation

class StorageManager {
    private let fileManager = FileManager.default
    private let evidenceDirectory: URL
    private let metadataURL: URL
    
    init() {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        evidenceDirectory = documentsDirectory.appendingPathComponent("Evidence", isDirectory: true)
        metadataURL = documentsDirectory.appendingPathComponent("evidence_metadata.json")
        
        // Create directories if they don't exist
        do {
            try fileManager.createDirectory(at: evidenceDirectory, withIntermediateDirectories: true)
            
            // Create empty metadata file if it doesn't exist
            if !fileManager.fileExists(atPath: metadataURL.path) {
                let emptyArray: [Evidence] = []
                let data = try JSONEncoder().encode(emptyArray)
                try data.write(to: metadataURL)
                print("Created new metadata file")
            }
        } catch {
            print("Error initializing storage: \(error)")
        }
    }
    
    func fetchEvidence() async throws -> [Evidence] {
        guard fileManager.fileExists(atPath: metadataURL.path) else {
            return []
        }
        
        do {
            let data = try Data(contentsOf: metadataURL)
            let evidence = try JSONDecoder().decode([Evidence].self, from: data)
            print("Loaded \(evidence.count) evidence items") // Debug log
            return evidence
        } catch {
            print("Error loading evidence: \(error)") // Debug log
            throw error
        }
    }
    
    func deleteEvidence(_ evidence: Evidence) async throws {
        if let fileURL = evidence.resolvedFileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
        var items = try await fetchEvidence()
        items.removeAll { $0.id == evidence.id }
        try await saveEvidence(items)
    }
    
    private func saveEvidence(_ evidence: [Evidence]) async throws {
        do {
            let data = try JSONEncoder().encode(evidence)
            try data.write(to: metadataURL, options: .atomic)
            print("Storage - Saved evidence to disk:")
            print("- Total items: \(evidence.count)")
            print("- File path: \(metadataURL.path)")
            
            // Verify the save
            let savedData = try Data(contentsOf: metadataURL)
            let decodedEvidence = try JSONDecoder().decode([Evidence].self, from: savedData)
            print("Storage - Verified save, read back \(decodedEvidence.count) items")
        } catch {
            print("Storage - Error saving evidence: \(error)")
            throw error
        }
    }
    
    func updateEvidence(_ evidence: Evidence) async throws {
        var items = try await fetchEvidence()
        if let index = items.firstIndex(where: { $0.id == evidence.id }) {
            items[index] = evidence
        } else {
            items.append(evidence)
        }
        try await saveEvidence(items)
    }
    
    func fetchMetadata(for evidence: Evidence) async throws -> EvidenceMetadata {
        guard let sharePointUrl = evidence.sharePointUrl,
              let fileEndpoint = getFileEndpoint(from: sharePointUrl) else {
            throw EvidenceError.uploadFailed("Invalid SharePoint URL")
        }
        
        // Add expand parameter to include SharePoint list columns
        let endpoint = "\(fileEndpoint)?$select=id,name,webUrl,@microsoft.graph.downloadUrl,createdDateTime,lastModifiedDateTime,size,file,fields&$expand=fields"
        
        let (data, _) = try await URLSession.shared.data(from: URL(string: endpoint)!)
        
        // Debug the raw response
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw SharePoint response: \(jsonString)")
        }
        
        let metadata = try JSONDecoder().decode(EvidenceMetadata.self, from: data)
        return metadata
    }
    
    private func getFileEndpoint(from sharePointUrl: String) -> String? {
        // Convert SharePoint URL to Graph API endpoint
        // Example: https://tenant.sharepoint.com/sites/site/library/folder/file.jpg
        // To: https://graph.microsoft.com/v1.0/sites/{site-id}/drive/root:/folder/file.jpg
        
        guard let url = URL(string: sharePointUrl) else { return nil }
        let pathComponents = url.pathComponents
        
        if let siteIndex = pathComponents.firstIndex(of: "sites"),
           siteIndex + 1 < pathComponents.count {
            let siteName = pathComponents[siteIndex + 1]
            let documentsPath = pathComponents.suffix(from: siteIndex + 3).joined(separator: "/")
            return "https://graph.microsoft.com/v1.0/sites/\(siteName)/drive/root:/\(documentsPath)"
        }
        return nil
    }
} 
