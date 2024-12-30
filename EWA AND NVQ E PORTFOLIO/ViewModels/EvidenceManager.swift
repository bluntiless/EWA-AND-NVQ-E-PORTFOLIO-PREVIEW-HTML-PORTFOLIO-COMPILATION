import Foundation
import Combine

@MainActor
class EvidenceManager: ObservableObject {
    @Published var evidenceItems: [Evidence] = []
    @Published var lastUploadTimestamp: Date?
    @Published var isLoading = true
    private let storageManager: StorageManager
    
    init(storageManager: StorageManager = StorageManager()) {
        self.storageManager = storageManager
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        print("EvidenceManager - Loading initial data")
        isLoading = true
        do {
            let items = try await storageManager.fetchEvidence()
            print("EvidenceManager - Loaded \(items.count) items")
            print("Items with SharePoint URLs: \(items.filter { $0.sharePointUrl != nil }.count)")
            await MainActor.run {
                self.evidenceItems = items
                self.isLoading = false
            }
        } catch {
            print("Error loading evidence: \(error)")
            isLoading = false
        }
    }
    
    func deleteEvidence(_ evidence: Evidence) async {
        do {
            try await storageManager.deleteEvidence(evidence)
            evidenceItems.removeAll { $0.id == evidence.id }
        } catch {
            print("Error deleting evidence: \(error)")
        }
    }
    
    func uploadEvidence(_ evidence: Evidence) async throws {
        // 1. Upload to SharePoint
        let updatedEvidence = try await TeamsManager.shared.uploadMultipleToSharePoint(evidenceItems: [evidence]).first!
        
        // 2. Save to local storage
        try await storageManager.updateEvidence(updatedEvidence)
        
        // 3. Update UI state
        await MainActor.run {
            if let index = evidenceItems.firstIndex(where: { $0.id == updatedEvidence.id }) {
                evidenceItems[index] = updatedEvidence
            } else {
                evidenceItems.append(updatedEvidence)
            }
            lastUploadTimestamp = Date()
        }
        
        // 4. Refresh status
        await refreshEvidenceStatus()
    }
    
    func addEvidence(_ evidence: Evidence) {
        evidenceItems.append(evidence)
    }
    
    func refreshEvidenceStatus() async {
        print("Starting evidence status refresh")
        do {
            let updatedItems = try await storageManager.fetchEvidence()
            var modifiedItems = updatedItems
            
            for i in modifiedItems.indices {
                if let sharePointUrl = modifiedItems[i].sharePointUrl {
                    do {
                        try await TeamsManager.shared.authenticate()
                        print("Fetching metadata for item \(i): \(sharePointUrl)")
                        let metadata = try await fetchEvidenceMetadata(for: modifiedItems[i])
                        print("Received metadata for item \(i): \(metadata)")
                        modifiedItems[i].updateAssessmentInfo(from: metadata)
                        try await storageManager.updateEvidence(modifiedItems[i])
                    } catch {
                        print("Error fetching metadata for evidence \(i): \(error)")
                    }
                }
            }
            
            await MainActor.run {
                print("Updating UI with \(modifiedItems.count) items")
                self.evidenceItems = modifiedItems
            }
        } catch {
            print("Error refreshing evidence status: \(error)")
        }
    }
    
    func fetchEvidenceMetadata(for evidence: Evidence) async throws -> EvidenceMetadata {
        guard let sharePointURL = evidence.sharePointUrl,
              let _ = URL(string: sharePointURL) else {
            throw EvidenceError.invalidURL
        }
        
        return try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointURL)
    }
} 

