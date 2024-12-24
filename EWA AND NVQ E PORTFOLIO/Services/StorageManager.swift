import Foundation

class StorageManager {
    private let fileManager = FileManager.default
    private let evidenceDirectory: URL
    private let metadataURL: URL
    
    init() {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        evidenceDirectory = documentsDirectory.appendingPathComponent("Evidence", isDirectory: true)
        metadataURL = documentsDirectory.appendingPathComponent("evidence_metadata.json")
        
        try? fileManager.createDirectory(at: evidenceDirectory, withIntermediateDirectories: true)
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
        // Remove the actual file if it exists
        let mutableEvidence = evidence  // Create mutable copy
        if let url = try? mutableEvidence.resolvedFileURL {
            try? fileManager.removeItem(at: url)
        }
        
        // Update metadata
        var currentEvidence = try await fetchEvidence()
        currentEvidence.removeAll { $0.id == evidence.id }
        try await saveEvidence(currentEvidence)
    }
    
    func uploadEvidence(_ evidence: Evidence) async throws {
        var currentEvidence = try await fetchEvidence()
        currentEvidence.append(evidence)
        let data = try JSONEncoder().encode(currentEvidence)
        try data.write(to: metadataURL)
        print("Saved evidence item. Total count: \(currentEvidence.count)") // Debug log
    }
    
    private func saveEvidence(_ evidence: [Evidence]) async throws {
        let data = try JSONEncoder().encode(evidence)
        try data.write(to: metadataURL)
    }
} 
