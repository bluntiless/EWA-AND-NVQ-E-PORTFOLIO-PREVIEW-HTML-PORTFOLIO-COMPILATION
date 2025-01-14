import Foundation
import Combine
import SwiftUI

@MainActor
class EvidenceManager: ObservableObject {
    @Published private(set) var evidenceItems: [Evidence] = []
    @Published var lastUploadTimestamp: Date?
    @Published var isLoading = true
    private let storageManager: StorageManager
    
    // Add persistent storage for hidden state
    private let hiddenStateKey = "hiddenEvidenceState"
    
    // Add refresh throttling
    private var lastRefreshTime: Date?
    private let minimumRefreshInterval: TimeInterval = 600 // 10 minutes
    
    init(storageManager: StorageManager = StorageManager()) {
        self.storageManager = storageManager
        
        // Load hidden state on init
        loadHiddenState()
        
        Task {
            await loadInitialData()
        }
    }
    
    private func loadHiddenState() {
        if let data = UserDefaults.standard.data(forKey: hiddenStateKey),
           let hiddenItems = try? JSONDecoder().decode([UUID: Bool].self, from: data) {
            // Restore hidden state to existing items
            evidenceItems = evidenceItems.map { evidence in
                var updatedEvidence = evidence
                updatedEvidence.isHidden = hiddenItems[evidence.id] ?? false
                return updatedEvidence
            }
        }
    }
    
    private func saveHiddenState() {
        let hiddenItems = Dictionary(uniqueKeysWithValues: 
            evidenceItems.map { ($0.id, $0.isHidden) }
        )
        if let data = try? JSONEncoder().encode(hiddenItems) {
            UserDefaults.standard.set(data, forKey: hiddenStateKey)
        }
    }
    
    func loadInitialData() async {
        print("EvidenceManager - Loading initial data")
        isLoading = true
        do {
            var items = try await storageManager.fetchEvidence()
            // Load hidden states without checking status
            if let data = UserDefaults.standard.data(forKey: hiddenStateKey),
               let hiddenItems = try? JSONDecoder().decode([UUID: Bool].self, from: data) {
                for (id, isHidden) in hiddenItems {
                    if let index = items.firstIndex(where: { $0.id == id }) {
                        var item = items[index]
                        item.isHidden = isHidden
                        items[index] = item
                    }
                }
            }
            
            await MainActor.run {
                self.evidenceItems = items
                self.isLoading = false
            }
        } catch {
            print("Error loading evidence: \(error)")
            isLoading = false
        }
    }
    
    func updateProgress() {
        // Add diagnostic logging without changing functionality
        print("\n=== Progress Diagnostic ===")
        
        let groupedEvidence = Dictionary(grouping: evidenceItems) { $0.unitCode }
        
        for (unit, items) in groupedEvidence {
            let visibleItems = items.filter { !$0.isHidden }
            let approvedItems = visibleItems.filter { $0.assessmentStatus == .approved }
            
            print("""
                \nUnit: \(unit)
                - Total Items: \(items.count)
                - Visible Items: \(visibleItems.count)
                - Approved Items: \(approvedItems.count)
                """)
        }
        
        // Preserve existing functionality
        objectWillChange.send()
    }
    
    func uploadMultipleEvidence(_ evidenceItems: [Evidence]) async throws {
        // 1. Upload to SharePoint with MSAL auth
        let updatedEvidenceItems = try await TeamsManager.shared.uploadMultipleToSharePoint(evidenceItems: evidenceItems)
        
        // 2. Save to local storage and update UI
        for evidence in updatedEvidenceItems {
            // Save to storage
            try await storageManager.updateEvidence(evidence)
            
            // Update UI state
            await MainActor.run {
                if let index = self.evidenceItems.firstIndex(where: { $0.id == evidence.id }) {
                    self.evidenceItems[index] = evidence
                } else {
                    self.evidenceItems.append(evidence)
                }
            }
            
            // Refresh metadata
            await refreshEvidenceMetadata(for: evidence)
        }
        
        // Update timestamp
        await MainActor.run {
            lastUploadTimestamp = Date()
            updateProgress()
        }
    }
    
    func uploadEvidence(_ evidence: Evidence) async throws {
        try await uploadMultipleEvidence([evidence])
    }
    
    func addEvidence(_ evidence: Evidence) {
        evidenceItems.append(evidence)
    }
    
    private func shouldRefresh() -> Bool {
        guard let lastRefresh = lastRefreshTime else {
            return true
        }
        return Date().timeIntervalSince(lastRefresh) > minimumRefreshInterval
    }
    
    func refreshEvidenceStatus() async {
        print("\n=== Starting Evidence Status Refresh ===")
        
        do {
            // Get all evidence items, including hidden ones
            let allItems = evidenceItems
            
            for evidence in allItems {
                if let sharePointUrl = evidence.sharePointUrl {
                    do {
                        // Ensure we're authenticated
                        try await TeamsManager.shared.authenticate()
                        
                        print("\nRefreshing status for evidence:")
                        print("- ID:", evidence.id)
                        print("- URL:", sharePointUrl)
                        print("- Current Status:", evidence.assessmentStatus.rawValue)
                        
                        // Fetch fresh metadata
                        let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
                        
                        // Create updated evidence while preserving local properties
                        var updatedEvidence = evidence
                        let wasHidden = evidence.isHidden
                        updatedEvidence.updateAssessmentInfo(from: metadata)
                        updatedEvidence.isHidden = wasHidden
                        
                        // Update storage and UI
                        try await storageManager.updateEvidence(updatedEvidence)
                        
                        if let index = evidenceItems.firstIndex(where: { $0.id == evidence.id }) {
                            evidenceItems[index] = updatedEvidence
                            print("✅ Updated Status:", updatedEvidence.assessmentStatus.rawValue)
                        }
                    } catch {
                        print("❌ Failed to refresh status for \(evidence.id): \(error)")
                    }
                }
            }
            
            // Update UI
            objectWillChange.send()
            updateProgress()
            
            // Update refresh timestamp
            lastRefreshTime = Date()
            
        } catch {
            print("❌ Failed to refresh evidence status: \(error)")
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
        let unitEvidence = evidenceItems.filter { 
            $0.unitCode == unitCode && !$0.isHidden 
        }
        return unitEvidence.filter { $0.assessmentStatus == .approved }.count
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
                    print("✅ File verification successful on attempt \(attempt)")
                    return true
                } catch {
                    print("⚠️ Verification attempt \(attempt) failed: \(error)")
                    if attempt == 5 { return false }
                    let delay = UInt64(pow(3.0, Double(attempt)) * 1_000_000_000)
                    print("Waiting \(delay/1_000_000_000)s before next attempt...")
                    try await Task.sleep(nanoseconds: delay)
                }
            }
            return false
        } catch {
            print("❌ File verification failed: \(error)")
            return false
        }
    }
    
    func hideEvidence(_ evidence: Evidence) {
        var updatedItems = evidenceItems
        if let index = updatedItems.firstIndex(where: { $0.id == evidence.id }) {
            updatedItems[index].isHidden = true
            withAnimation {
                self.evidenceItems = updatedItems
            }
            // Save to both StorageManager and UserDefaults for redundancy
            Task {
                do {
                    try await storageManager.updateEvidence(updatedItems[index])
                    saveHiddenStateToUserDefaults()
                } catch {
                    print("Failed to save hidden state: \(error)")
                }
            }
        }
    }
    
    func unhideEvidence(_ evidence: Evidence) async {
        print("\n=== Unhiding Evidence ===")
        print("ID:", evidence.id)
        
        var updatedItems = evidenceItems
        if let index = updatedItems.firstIndex(where: { $0.id == evidence.id }) {
            // First refresh the status
            do {
                try await updateEvidence(evidence)
            } catch {
                print("⚠️ Status refresh failed during unhide: \(error)")
            }
            
            // Then unhide
            updatedItems[index].isHidden = false
            withAnimation {
                self.evidenceItems = updatedItems
            }
            
            // Save changes
            Task {
                do {
                    try await storageManager.updateEvidence(updatedItems[index])
                    print("✅ Evidence unhidden successfully")
                } catch {
                    print("❌ Failed to save unhide state: \(error)")
                }
            }
        }
    }
    
    private func saveHiddenStateToUserDefaults() {
        let hiddenItems = Dictionary(uniqueKeysWithValues: 
            evidenceItems.map { ($0.id, $0.isHidden) }
        )
        if let data = try? JSONEncoder().encode(hiddenItems) {
            UserDefaults.standard.set(data, forKey: hiddenStateKey)
        }
    }
    
    // Modify refreshEvidenceMetadata to preserve hidden state
    func refreshEvidenceMetadata(for evidence: Evidence) async {
        let wasHidden = evidence.isHidden  // Store current hidden state
        let currentIndex = evidenceItems.firstIndex(where: { $0.id == evidence.id })
        
        do {
            let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(for: evidence)
            await MainActor.run {
                if let index = currentIndex {
                    var updatedEvidence = evidenceItems[index]
                    // Update metadata while preserving hidden state
                    updatedEvidence.assessmentStatus = metadata.assessmentStatus ?? .pending
                    updatedEvidence.assessorFeedback = metadata.assessorFeedback
                    updatedEvidence.assessorName = metadata.assessorName
                    updatedEvidence.assessmentDate = metadata.assessmentDate
                    updatedEvidence.isHidden = wasHidden  // Restore hidden state
                    evidenceItems[index] = updatedEvidence
                    
                    // Ensure hidden state is saved
                    Task {
                        try? await storageManager.updateEvidence(updatedEvidence)
                        saveHiddenStateToUserDefaults()
                    }
                }
            }
        } catch {
            print("Failed to refresh metadata: \(error)")
        }
    }
    
    // Only refresh in these specific cases:
    // 1. Manual pull-to-refresh
    func manualRefresh() async {
        guard shouldRefresh() else {
            print("Skipping refresh - too soon since last refresh")
            return
        }
        lastRefreshTime = Date()
        await refreshEvidenceStatus()
    }
    
    // 2. When viewing specific evidence
    func viewEvidence(_ evidence: Evidence) async {
        print("\n=== Viewing Evidence ===")
        print("ID:", evidence.id)
        print("Hidden:", evidence.isHidden)
        print("SharePoint URL:", evidence.sharePointUrl ?? "nil")
        
        // Always refresh metadata regardless of hidden state
        do {
            try await TeamsManager.shared.authenticate()
            let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(for: evidence)
            
            await MainActor.run {
                if let index = evidenceItems.firstIndex(where: { $0.id == evidence.id }) {
                    var updatedEvidence = evidenceItems[index]
                    // Update metadata while preserving hidden state
                    let wasHidden = updatedEvidence.isHidden
                    updatedEvidence.updateAssessmentInfo(from: metadata)
                    updatedEvidence.isHidden = wasHidden
                    evidenceItems[index] = updatedEvidence
                }
            }
        } catch {
            print("❌ Failed to refresh metadata for hidden evidence: \(error)")
        }
    }
    
    // Add a new method specifically for previews
    func getPreviewUrl(for evidence: Evidence) async throws -> URL? {
        print("\n=== Getting Preview URL ===")
        print("Evidence ID: \(evidence.id)")
        print("Hidden:", evidence.isHidden)
        
        guard let sharePointUrl = evidence.sharePointUrl else {
            print("❌ No SharePoint URL available")
            throw EvidenceError.invalidURL
        }
        
        // Use sharePointUrl in authentication
        try await TeamsManager.shared.authenticate()
        
        // Get fresh metadata using the sharePointUrl
        let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
        
        if let downloadUrl = metadata.downloadUrl,
           let url = URL(string: downloadUrl) {
            print("✅ Successfully retrieved preview URL")
            return url
        }
        
        print("❌ No download URL available in metadata")
        throw EvidenceError.invalidURL
    }
    
    @MainActor
    func updateEvidence(_ evidence: Evidence) async throws {
        print("\n=== Updating Evidence Status ===")
        print("ID:", evidence.id)
        print("Previous Status:", evidence.assessmentStatus.rawValue)
        
        if let sharePointUrl = evidence.sharePointUrl {
            do {
                try await TeamsManager.shared.authenticate()
                let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
                
                // Create updated evidence with new status
                var updatedEvidence = evidence
                updatedEvidence.updateAssessmentInfo(from: metadata)
                
                // Update storage and UI
                try await storageManager.updateEvidence(updatedEvidence)
                
                if let index = evidenceItems.firstIndex(where: { $0.id == evidence.id }) {
                    evidenceItems[index] = updatedEvidence
                    print("New Status:", updatedEvidence.assessmentStatus.rawValue)
                }
                
                // Trigger UI updates
                objectWillChange.send()
                updateProgress()
            } catch {
                print("❌ Failed to update evidence status:", error)
                throw error
            }
        }
    }
    
    @MainActor
    func refreshAndUpdateEvidenceStatus() async {
        print("Refreshing evidence status...")
        guard shouldRefresh() else {
            print("Refresh not needed based on the time interval.")
            return
        }

        do {
            let updatedItems = try await fetchUpdatedEvidenceFromSharePoint()
            for item in updatedItems {
                print("Updating status for item ID: \(item.id) with new status: \(item.assessmentStatus)")
                try await updateEvidence(item)
            }
            print("Successfully updated all items.")
        } catch {
            print("Failed to refresh evidence status: \(error)")
        }
    }

    private func fetchUpdatedEvidenceFromSharePoint() async throws -> [Evidence] {
        var updatedEvidence: [Evidence] = []
        
        for evidence in evidenceItems {
            if let sharePointUrl = evidence.sharePointUrl {
                do {
                    try await TeamsManager.shared.authenticate()
                    let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
                    var updated = evidence
                    updated.updateAssessmentInfo(from: metadata)
                    updatedEvidence.append(updated)
                } catch {
                    print("Failed to fetch metadata for \(evidence.id): \(error)")
                    updatedEvidence.append(evidence)
                }
            } else {
                updatedEvidence.append(evidence)
            }
        }
        
        return updatedEvidence
    }
} 

