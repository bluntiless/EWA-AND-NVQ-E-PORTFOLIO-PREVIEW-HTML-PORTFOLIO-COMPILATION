import Foundation
import Combine

@MainActor
class EvidenceManager: ObservableObject {
    @Published var evidenceItems: [Evidence] = []
    private let storageManager: StorageManager
    
    init(storageManager: StorageManager = StorageManager()) {
        self.storageManager = storageManager
    }
    
    func loadInitialData() async {
        do {
            evidenceItems = try await storageManager.fetchEvidence()
        } catch {
            print("Error loading evidence: \(error)")
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
        try await storageManager.uploadEvidence(evidence)
        evidenceItems.append(evidence)
    }
    
    func addEvidence(_ evidence: Evidence) {
        evidenceItems.append(evidence)
    }
} 
