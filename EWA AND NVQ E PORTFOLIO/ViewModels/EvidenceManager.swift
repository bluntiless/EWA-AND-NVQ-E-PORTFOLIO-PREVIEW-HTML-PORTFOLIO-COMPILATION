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
            evidenceItems.map { ($0.id.uuidString, $0.isHidden) }
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
            
            // Load hidden states from UserDefaults
            if let data = UserDefaults.standard.data(forKey: hiddenStateKey),
               let hiddenItems = try? JSONDecoder().decode([String: Bool].self, from: data) {
                // Apply hidden states to items
                items = items.map { item in
                    var updatedItem = item
                    if let isHidden = hiddenItems[item.id.uuidString] {
                        updatedItem.isHidden = isHidden
                    }
                    return updatedItem
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
        print("Starting evidence status refresh")
        do {
            // First get current hidden states safely
            var hiddenStates = [String: Bool]()
            for item in evidenceItems {
                hiddenStates[item.id.uuidString] = item.isHidden
            }
            
            let updatedItems = try await storageManager.fetchEvidence()
            var modifiedItems = [Evidence]()
            
            for item in updatedItems {
                var modifiedItem = item
                
                // Restore hidden state from our saved states
                if let wasHidden = hiddenStates[item.id.uuidString] {
                    modifiedItem.isHidden = wasHidden
                }
                
                // Skip metadata refresh for hidden items
                if modifiedItem.isHidden {
                    modifiedItems.append(modifiedItem)
                    continue
                }
                
                guard let sharePointUrl = modifiedItem.sharePointUrl else { 
                    print("No SharePoint URL for item")
                    modifiedItems.append(modifiedItem)
                    continue 
                }
                
                do {
                    try await TeamsManager.shared.authenticate()
                    print("Fetching metadata for: \(sharePointUrl)")
                    let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
                    print("Received metadata: \(metadata)")
                    
                    // Update assessment info while explicitly preserving hidden state
                    modifiedItem.updateAssessmentInfo(from: metadata)
                    
                    try await storageManager.updateEvidence(modifiedItem)
                    modifiedItems.append(modifiedItem)
                } catch {
                    print("Error fetching metadata: \(error)")
                    modifiedItems.append(modifiedItem)
                }
            }
            
            await MainActor.run {
                self.evidenceItems = modifiedItems
                // Ensure hidden states are saved after refresh
                self.saveHiddenStateToUserDefaults()
            }
        } catch {
            print("Error refreshing evidence status: \(error)")
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
            evidence.unitCode == unitCode &&
            evidence.assessmentStatus == .approved
        }
    }
    
    func standardizeUnitCode(_ code: String) -> String {
        // Handle special cases first
        if code == "01" {
            return "NETP3-01"
        }
        if code == "03" {
            return "NETP3-03"
        }
        
        // If it's already in the correct format, return as is
        if code.contains("-") {
            return code
        }
        
        // Add standard prefix if missing
        if code.count == 2 && Int(code) != nil {
            return "NETP3-\(code)"
        }
        
        return code
    }
    
    func hasEvidenceForUnit(_ unitCode: String) -> Bool {
        let standardizedCode = standardizeUnitCode(unitCode)
        return evidenceItems.contains { evidence in
            let evidenceUnitCode = standardizeUnitCode(evidence.unitCode)
            return evidenceUnitCode == standardizedCode
        }
    }
    
    func getApprovedEvidenceCount(for unitCode: String) -> Int {
        // First check if unit has any evidence
        guard hasEvidenceForUnit(unitCode) else {
            print("Unit \(unitCode): No evidence found")
            return 0
        }
        
        let standardizedCode = standardizeUnitCode(unitCode)
        
        // Filter evidence for this unit and count only approved items
        let unitEvidence = evidenceItems.filter { evidence in
            let evidenceUnitCode = standardizeUnitCode(evidence.unitCode)
            return evidenceUnitCode == standardizedCode && 
                   evidence.assessmentStatus == .approved
        }
        
        let approvedCriteriaCodes = Set(unitEvidence.flatMap { evidence in
            evidence.criteriaArray
        })
        
        print("Unit \(unitCode): Found \(approvedCriteriaCodes.count) approved criteria")
        return approvedCriteriaCodes.count
    }
    
    func getTotalEvidenceCount(for unitCode: String) -> Int {
        // Count all evidence regardless of hidden state
        evidenceItems.filter { 
            $0.unitCode == unitCode
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
        print("Saving hidden states to UserDefaults")
        
        // Create a dictionary from evidence items with their UUID strings as keys,
        // ensuring we don't have duplicate keys by using a dictionary with unique keys
        var hiddenItems = [String: Bool]()
        for item in evidenceItems {
            hiddenItems[item.id.uuidString] = item.isHidden
        }
        
        if let data = try? JSONEncoder().encode(hiddenItems) {
            UserDefaults.standard.set(data, forKey: hiddenStateKey)
            UserDefaults.standard.synchronize() // Force immediate save
            
            // Debug log
            print("Hidden states saved: \(hiddenItems)")
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
        // Preserve hidden state
        let existingEvidence = evidenceItems.first(where: { $0.id == evidence.id })
        var updatedEvidence = evidence
        updatedEvidence.isHidden = existingEvidence?.isHidden ?? evidence.isHidden
        
        try await storageManager.updateEvidence(updatedEvidence)
        
        await MainActor.run {
            if let index = evidenceItems.firstIndex(where: { $0.id == evidence.id }) {
                evidenceItems[index] = updatedEvidence
            } else {
                evidenceItems.append(updatedEvidence)
            }
        }
        
        // Save hidden state to UserDefaults
        saveHiddenState()
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
    
    // Add helper method for consistent unit code normalization
    private func normalizeUnitCode(_ code: String) -> String {
        return code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }
    
    // 1. Base evidence filtering method
    func getEvidenceForCriteria(_ criteriaCode: String, forUnit unitCode: String? = nil) -> [Evidence] {
        print("\n=== Getting Evidence for Criteria: \(criteriaCode) for Unit: \(unitCode ?? "any") ===")
        return evidenceItems.filter { evidence in
            // Strict unit matching - only if unit code is specified
            let matchesUnit = if let requiredUnit = unitCode {
                evidence.unitCode == requiredUnit
            } else {
                true // Allow any unit only if no specific unit requested
            }
            
            let matchesCriteria = evidence.criteriaArray.contains(criteriaCode)
            
            if matchesUnit && matchesCriteria {
                print("Matching Evidence Found: \(evidence.id) for Unit: \(evidence.unitCode)")
            }
            return matchesUnit && matchesCriteria
        }
    }
    
    // 2. Progress calculation for a specific unit
    func getProgressForUnit(_ unitCode: String) -> Double {
        guard let unit = getUnit(withCode: unitCode) else {
            print("No unit found for code: \(unitCode)")
            return 0.0
        }

        print("\n=== Calculating Progress for Unit: \(unitCode) ===")
        
        let allCriteria = unit.learningOutcomes.flatMap { $0.performanceCriteria }
        print("Total criteria for unit: \(allCriteria.count)")
        
        // Get evidence specifically for this unit
        let evidenceForUnit = allCriteria.flatMap { criteria -> [Evidence] in
            let evidence = getEvidenceForCriteria(criteria.code, forUnit: unitCode) // Explicitly pass unit code
            return evidence.filter { $0.assessmentStatus == .approved }
        }

        if evidenceForUnit.isEmpty {
            print("No approved evidence found for unit \(unitCode). Setting progress to 0.")
            return 0.0
        }

        let completedCriteria = allCriteria.filter { criteria in
            let hasApprovedEvidence = evidenceForUnit.contains { 
                $0.criteriaArray.contains(criteria.code) && 
                $0.unitCode == unitCode // Double-check unit code
            }
            print("Criteria \(criteria.code) completed: \(hasApprovedEvidence)")
            return hasApprovedEvidence
        }

        let progress = Double(completedCriteria.count) / Double(allCriteria.count)
        print("Final progress for unit \(unitCode): \(progress) (\(completedCriteria.count)/\(allCriteria.count))")
        return progress
    }
    
    // 3. Detailed unit progress calculation
    func getUnitProgress(_ unit: Unit) -> Double {
        print("\n=== Calculating Progress for Unit: \(unit.code) ===")
        
        let allCriteria = unit.learningOutcomes.flatMap { $0.performanceCriteria }
        print("Total criteria count: \(allCriteria.count)")
        
        let completedCriteria = allCriteria.filter { criteria in
            print("\nChecking criteria: \(criteria.code)")
            let evidence = getEvidenceForCriteria(criteria.code, forUnit: unit.code)
            
            // Debug each piece of evidence
            evidence.forEach { ev in
                print("Found evidence: \(ev.id)")
                print("  Unit: \(ev.unitCode)")
                print("  Hidden: \(ev.isHidden)")
                print("  Status: \(ev.assessmentStatus)")
            }
            
            // Count approved evidence regardless of hidden state
            let isCompleted = evidence.contains { ev in 
                ev.assessmentStatus == .approved 
            }
            print("Criteria \(criteria.code) completed: \(isCompleted)")
            return isCompleted
        }
        
        print("Completed criteria count: \(completedCriteria.count)")
        let progress = allCriteria.isEmpty ? 0.0 : Double(completedCriteria.count) / Double(allCriteria.count)
        print("Final progress: \(progress)")
        
        return progress
    }
    
    func getUnit(withCode code: String) -> Unit? {
        // Search in both unit collections
        return cityAndGuilds2357Units.first { $0.code == code } ?? 
               EALUnits.ewaUnits.first { $0.code == code }
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
    
    func getPendingEvidenceCount(for unitCode: String) -> Int {
        // First check if unit has any evidence
        guard hasEvidenceForUnit(unitCode) else {
            print("Unit \(unitCode): No evidence found")
            return 0
        }
        
        let standardizedCode = standardizeUnitCode(unitCode)
        
        let unitEvidence = evidenceItems.filter { evidence in
            let evidenceUnitCode = standardizeUnitCode(evidence.unitCode)
            return evidenceUnitCode == standardizedCode && 
                   evidence.assessmentStatus == .pending
        }
        
        let pendingCriteriaCodes = Set(unitEvidence.flatMap { $0.criteriaArray })
        print("Unit \(unitCode): Found \(pendingCriteriaCodes.count) pending criteria")
        return pendingCriteriaCodes.count
    }
} 

