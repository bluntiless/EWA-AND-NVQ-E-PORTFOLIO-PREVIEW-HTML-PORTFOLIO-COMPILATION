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
    
    func uploadMultipleEvidence(_ evidenceItems: [Evidence]) async throws {
        // 1. Upload all items to SharePoint with MSAL auth
        let updatedEvidenceItems = try await TeamsManager.shared.uploadMultipleToSharePoint(evidenceItems: evidenceItems)
        
        // 2. Save all to local storage with proper metadata
        for evidence in updatedEvidenceItems {
            try await storageManager.updateEvidence(evidence)
        }
        
        // 3. Update UI state
        await MainActor.run {
            for evidence in updatedEvidenceItems {
                if let index = self.evidenceItems.firstIndex(where: { $0.id == evidence.id }) {
                    self.evidenceItems[index] = evidence
                } else {
                    self.evidenceItems.append(evidence)
                }
            }
            lastUploadTimestamp = Date()
        }
        
        // 4. Refresh status to get assessment updates
        await refreshEvidenceStatus()
    }
    
    func uploadEvidence(_ evidence: Evidence) async throws {
        try await uploadMultipleEvidence([evidence])
    }
    
    func addEvidence(_ evidence: Evidence) {
        evidenceItems.append(evidence)
    }
    
    func refreshEvidenceStatus() async {
        print("Starting evidence status refresh")
        do {
            let updatedItems = try await storageManager.fetchEvidence()
            let modifiedItems = updatedItems
            
            for i in modifiedItems.indices {
                // Use the actual SharePoint URL that was saved during upload
                guard let sharePointUrl = modifiedItems[i].sharePointUrl else { 
                    print("No SharePoint URL for item \(i)")
                    continue 
                }
                
                do {
                    try await TeamsManager.shared.authenticate()
                    
                    // Use the exact URL that was saved during upload
                    print("Fetching metadata for: \(sharePointUrl)")
                    let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
                    print("Received metadata: \(metadata)")
                    
                    // Update assessment info
                    modifiedItems[i].updateAssessmentInfo(from: metadata)
                    
                    // Save to storage
                    try await storageManager.updateEvidence(modifiedItems[i])
                } catch {
                    print("Error fetching metadata: \(error)")
                }
            }
            
            await MainActor.run {
                self.evidenceItems = modifiedItems
            }
        } catch {
            print("Error refreshing evidence status: \(error)")
        }
    }
    
    func fetchEvidenceMetadata(for evidence: Evidence) async throws -> EvidenceMetadata {
        guard let sharePointURL = evidence.sharePointUrl else {
            throw EvidenceError.invalidURL
        }
        
        // Use the existing verification response to get metadata
        do {
            try await TeamsManager.shared.authenticate()
            
            // Use the SharePoint URL directly since we know it works
            let metadataUrl = SharePointPathFormatter.constructUrl(
                path: SharePointPathFormatter.formatPath(
                    unitCode: evidence.unitCode,
                    criteriaCode: evidence.criteriaCode
                ),
                fileName: URL(string: sharePointURL)?.lastPathComponent ?? "",
                format: .metadata
            )
            
            return try await TeamsManager.shared.fetchEvidenceMetadata(from: metadataUrl)
        } catch {
            print("Metadata fetch failed: \(error)")
            throw error
        }
    }
    
    func getApprovedEvidence(for unitCode: String) -> [Evidence] {
        evidenceItems.filter { evidence in
            let isApproved = evidence.assessmentStatus == .approved
            return isApproved && evidence.unitCode == unitCode
        }
    }
    
    func getApprovedEvidenceCount(for unitCode: String) -> Int {
        getApprovedEvidence(for: unitCode).count
    }
    
    func getRecentApprovedEvidence(for unitCode: String, limit: Int = 2) -> [Evidence]? {
        let approved = getApprovedEvidence(for: unitCode)
        return approved.isEmpty ? nil : Array(approved.prefix(limit))
    }
    
    func verifyFileExists(at sharePointUrl: String) async throws -> Bool {
        do {
            // Create temporary Evidence object for metadata fetch
            let tempEvidence = Evidence(
                id: UUID(),
                criteriaCode: "",
                unitCode: "",
                dateUploaded: Date(),
                type: .photo,
                title: "",
                description: "",
                bookmarkData: nil,
                sharePointUrl: sharePointUrl,
                fileURL: nil,
                uploadDate: nil,
                associatedCriteria: [],
                criteriaDescription: "",
                assessmentStatus: .pending,
                assessorFeedback: nil,
                assessorName: nil,
                assessmentDate: nil,
                isLocallyUploaded: true
            )
            
            // Initial delay to allow SharePoint to process
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 second initial delay
            
            // Use existing metadata fetch with progressive retry
            for attempt in 1...5 {
                do {
                    print("Attempting verification (\(attempt)/5) for: \(sharePointUrl)")
                    let metadata = try await fetchEvidenceMetadata(for: tempEvidence)
                    if metadata != nil {
                        print("✅ File verification successful on attempt \(attempt)")
                        return true
                    }
                    // Exponential backoff with longer delays
                    let delay = UInt64(pow(3.0, Double(attempt)) * 1_000_000_000)
                    print("Waiting \(delay/1_000_000_000)s before next attempt...")
                    try await Task.sleep(nanoseconds: delay)
                } catch {
                    print("⚠️ Verification attempt \(attempt) failed: \(error)")
                    if attempt == 5 { return false }
                    let delay = UInt64(pow(3.0, Double(attempt)) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: delay)
                }
            }
            return false
        } catch {
            print("❌ File verification failed: \(error)")
            return false
        }
    }
} 

