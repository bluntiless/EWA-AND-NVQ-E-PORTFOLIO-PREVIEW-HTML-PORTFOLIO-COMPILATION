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
    private let minimumRefreshInterval: TimeInterval = 120 // 2 minutes
    private let forceRefreshInterval: TimeInterval = 600 // 10 minutes
    
    // Add rate limiter properties
    private var requestTokens: Int = 10  // Reduced from 30 to 10 requests per window
    private let maxTokens: Int = 10      // Reduced from 30 to 10
    private let tokenRefillInterval: TimeInterval = 120.0  // Increased to 2 minutes
    private var lastTokenRefillTime: Date = Date()
    
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
           let hiddenItems = try? JSONDecoder().decode([String: Bool].self, from: data) {
            // Restore hidden state using string IDs
            evidenceItems = evidenceItems.map { evidence in
                var updatedEvidence = evidence
                updatedEvidence.isHidden = hiddenItems[evidence.id.uuidString] ?? false
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
        let uploadPath = try await TeamsManager.shared.getEvidenceUploadPath(for: evidence)
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
    
    private func waitForRequestToken() async throws {
        while true {
            // Refill tokens if enough time has passed
            let now = Date()
            let timeSinceRefill = now.timeIntervalSince(lastTokenRefillTime)
            if timeSinceRefill >= tokenRefillInterval {
                requestTokens = maxTokens
                lastTokenRefillTime = now
                // Add extra delay after refill
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 second cooldown
            }
            
            // If we have tokens, use one and proceed
            if requestTokens > 0 {
                requestTokens -= 1
                // Add delay between requests even with tokens
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
                return
            }
            
            // Wait longer before checking again
            try await Task.sleep(nanoseconds: 3_000_000_000)  // 3 seconds
        }
    }
    
    func refreshEvidenceStatus() async {
        print("\n=== Starting Evidence Status Refresh ===")
        
        for evidence in evidenceItems {
            if let sharePointUrl = evidence.sharePointUrl {
                // Try up to 3 times with increasing delays
                for attempt in 1...3 {
                    do {
                        // Wait for available request token
                        try await waitForRequestToken()
                        
                        // Exponential backoff delay on retry
                        if attempt > 1 {
                            let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                            try await Task.sleep(nanoseconds: delay)
                        }
                        
                        let wasHidden = evidence.isHidden
                        let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
                        
                        await MainActor.run {
                            if let index = self.evidenceItems.firstIndex(where: { $0.id == evidence.id }) {
                                var updatedEvidence = evidence
                                updatedEvidence.updateAssessmentInfo(from: metadata)
                                updatedEvidence.isHidden = wasHidden
                                self.evidenceItems[index] = updatedEvidence
                                
                                Task {
                                    try? await self.storageManager.updateEvidence(updatedEvidence)
                                }
                            }
                        }
                        
                        // Success - break retry loop
                        break
                        
                    } catch {
                        print("❌ Attempt \(attempt) failed for \(evidence.id): \(error)")
                        if attempt == 3 {
                            print("❌ All attempts failed for \(evidence.id)")
                        }
                    }
                }
            }
        }
        
        await MainActor.run {
            objectWillChange.send()
            updateProgress()
        }
    }
    
    private func needsMetadataRefresh(_ evidence: Evidence) -> Bool {
        guard let lastCheck = evidence.lastMetadataCheck else {
            return true // Never checked before
        }
        
        let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
        
        // Always refresh if status is pending
        if evidence.assessmentStatus == .pending {
            return timeSinceLastCheck >= minimumRefreshInterval
        }
        
        // For approved/rejected status, only check occasionally
        if evidence.assessmentStatus == .approved || evidence.assessmentStatus == .rejected {
            return timeSinceLastCheck >= forceRefreshInterval
        }
        
        // For needs revision, check more frequently
        if evidence.assessmentStatus == .needsRevision {
            return timeSinceLastCheck >= minimumRefreshInterval
        }
        
        return false
    }
    
    func refreshEvidenceMetadata(for evidence: Evidence) async {
        // Skip if refresh not needed
        guard needsMetadataRefresh(evidence) else {
            print("Skipping metadata refresh - too soon since last check")
            return
        }
        
        let wasHidden = evidence.isHidden
        let currentIndex = evidenceItems.firstIndex(where: { $0.id == evidence.id })
        
        do {
            let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(for: evidence)
            await MainActor.run {
                if let index = currentIndex {
                    var updatedEvidence = evidenceItems[index]
                    updatedEvidence.updateAssessmentInfo(from: metadata)
                    updatedEvidence.isHidden = wasHidden
                    evidenceItems[index] = updatedEvidence
                    
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
    
    func fetchEvidenceMetadata(for evidence: Evidence) async throws -> EvidenceMetadata {
        guard let sharePointURL = evidence.sharePointUrl else {
            throw EvidenceError.invalidURL
        }
        
        do {
            try await TeamsManager.shared.authenticate()
            
            // Handle HTML files differently
            let isHtmlFile = sharePointURL.lowercased().hasSuffix(".html")
            
            let urlString: String
            if isHtmlFile {
                // Use a different path format for HTML files
                urlString = SharePointPathFormatter.constructUrl(
                    path: SharePointPathFormatter.formatPath(
                        unitCode: evidence.unitCode,
                        criteriaCode: evidence.criteriaCode,
                        isHtmlDocument: true
                    ),
                    fileName: URL(string: sharePointURL)?.lastPathComponent ?? "",
                    format: .htmlMetadata
                )
            } else {
                // Existing path for images
                urlString = SharePointPathFormatter.constructUrl(
                    path: SharePointPathFormatter.formatPath(
                        unitCode: evidence.unitCode,
                        criteriaCode: evidence.criteriaCode
                    ),
                    fileName: URL(string: sharePointURL)?.lastPathComponent ?? "",
                    format: .metadata
                )
            }
            
            // Convert string to URL
            guard let _ = URL(string: urlString) else { // Just validate URL format
                throw EvidenceError.invalidURL
            }
            
            // Use the URL version for the API call
            return try await TeamsManager.shared.fetchEvidenceMetadata(from: urlString)
        } catch {
            print("❌ Metadata fetch failed for \(evidence.id) (HTML: \(sharePointURL.lowercased().hasSuffix(".html"))): \(error)")
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
        evidenceItems.filter { 
            $0.unitCode == unitCode && 
            !$0.isHidden && 
            $0.assessmentStatus == .approved 
        }.count
    }
    
    func getTotalEvidenceCount(for unitCode: String) -> Int {
        evidenceItems.filter { 
            $0.unitCode == unitCode && 
            !$0.isHidden 
        }.count
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
        // Create dictionary with string representation of UUIDs as keys
        let hiddenItems = Dictionary(
            evidenceItems.map { ($0.id.uuidString, $0.isHidden) },
            uniquingKeysWith: { first, _ in first }  // Keep first value in case of duplicates
        )
        
        if let data = try? JSONEncoder().encode(hiddenItems) {
            UserDefaults.standard.set(data, forKey: hiddenStateKey)
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
        let updatedEvidence = try await withThrowingTaskGroup(of: Evidence.self) { group in
            var results: [Evidence] = []
            
            // Only refresh items that need it
            let itemsNeedingRefresh = evidenceItems.filter { needsMetadataRefresh($0) }
            
            for evidence in itemsNeedingRefresh {
                group.addTask {
                    if let sharePointUrl = evidence.sharePointUrl {
                        do {
                            try await TeamsManager.shared.authenticate()
                            let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
                            var updated = evidence
                            updated.updateAssessmentInfo(from: metadata)
                            return updated
                        } catch {
                            print("Error fetching metadata for \(evidence.id): \(error)")
                            return evidence
                        }
                    }
                    return evidence
                }
            }
            
            // Collect results
            for try await item in group {
                results.append(item)
            }
            
            return results
        }
        return updatedEvidence
    }
    
    func getEvidenceForCriteria(_ criteriaCode: String) -> [Evidence] {
        evidenceItems.filter { evidence in
            evidence.criteriaArray.contains(criteriaCode) ||
            evidence.associatedCriteria.contains(criteriaCode)
        }
    }
    
    func getProgressForUnit(_ unitCode: String) -> Double {
        let evidenceForUnit = evidenceItems.filter { $0.unitCode == unitCode && !$0.isHidden }
        let approvedEvidence = evidenceForUnit.filter { $0.assessmentStatus == .approved }
        
        // Avoid division by zero
        guard !evidenceForUnit.isEmpty else { return 0.0 }
        return Double(approvedEvidence.count) / Double(evidenceForUnit.count)
    }
    
    func getUnit(withCode code: String) -> Unit? {
        // Search in both unit collections
        return cityAndGuilds2357Units.first { $0.code == code } ?? 
               EALUnits.ewaUnits.first { $0.code == code }
    }
    
    // Add progress calculation without modifying existing code
    func getUnitProgress(_ unit: Unit) -> Double {
        let allCriteria = unit.learningOutcomes.flatMap { $0.performanceCriteria }
        let completedCriteria = allCriteria.filter { criteria in
            let evidence = getEvidenceForCriteria(criteria.code)
            return evidence.contains { $0.assessmentStatus == .approved }
        }
        
        return allCriteria.isEmpty ? 0 : Double(completedCriteria.count) / Double(allCriteria.count)
    }
    
    // Add debug logging to track status changes
    func updateEvidenceStatus(_ evidence: Evidence, status: Evidence.AssessmentStatus) {
        print("\n=== Updating Evidence Status ===")
        print("Evidence: \(evidence.title)")
        print("Old Status: \(evidence.assessmentStatus)")
        print("New Status: \(status)")
        
        if let index = evidenceItems.firstIndex(where: { $0.id == evidence.id }) {
            evidenceItems[index].assessmentStatus = status
            print("Status Updated Successfully")
        }
    }
} 

