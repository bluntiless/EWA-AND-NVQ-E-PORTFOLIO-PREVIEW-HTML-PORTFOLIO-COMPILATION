import Foundation
import SwiftUI

enum EvidenceError: LocalizedError {
    case fileAccessError
    case invalidFileType
    case fileTooLarge(maxSize: Int)
    case uploadFailed(String)
    case bookmarkError(String)
    case invalidURL
    case invalidPath
    case invalidSiteResponse
    case invalidDriveResponse
    case invalidMetadata
    case invalidDates
    case cannotDeleteApproved
    
    var errorDescription: String? {
        switch self {
        case .fileAccessError:
            return "Could not access the file. Please try again."
        case .invalidFileType:
            return "Invalid file type. Please select a supported file format."
        case .fileTooLarge(let maxSize):
            let sizeMB = maxSize / (1024 * 1024)
            return "File is too large. Maximum size allowed is \(sizeMB)MB."
        case .uploadFailed(let reason):
            return "Upload failed: \(reason)"
        case .bookmarkError(let reason):
            return "Bookmark error: \(reason)"
        case .invalidURL:
            return "Invalid SharePoint URL"
        case .invalidPath:
            return "Invalid file path"
        case .invalidSiteResponse:
            return "Invalid site response from SharePoint"
        case .invalidDriveResponse:
            return "Invalid drive response from SharePoint"
        case .invalidMetadata:
            return "Invalid metadata format"
        case .invalidDates:
            return "Invalid date format"
        case .cannotDeleteApproved:
            return "Cannot delete approved evidence as it affects unit progress"
        }
    }
}

class Evidence: ObservableObject, Identifiable, Codable {
    let id: UUID
    let criteriaCode: String
    let unitCode: String
    let dateUploaded: Date
    let type: EvidenceType
    let title: String
    let description: String
    var bookmarkData: Data?
    var sharePointUrl: String?
    private var _fileURL: URL?
    var uploadDate: Date?
    let associatedCriteria: [String]
    let criteriaDescription: String
    
    @Published var assessmentStatus: AssessmentStatus = .pending
    @Published var assessorFeedback: String?
    @Published var assessorName: String?
    @Published var assessmentDate: Date?
    @Published var isLocallyUploaded: Bool = false
    
    @Published var uploadProgress: Double = 0.0
    @Published var processingStatus: ProcessingStatus = .notStarted
    
    var isHidden: Bool = false
    
    enum ProcessingStatus: String, Codable {
        case notStarted = "Not Started"
        case uploading = "Uploading"
        case processing = "Processing"
        case complete = "Complete"
        case failed = "Failed"
        
        var icon: String {
            switch self {
            case .notStarted: return "circle"
            case .uploading: return "arrow.up.circle"
            case .processing: return "gear.circle"
            case .complete: return "checkmark.circle.fill"
            case .failed: return "exclamationmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .notStarted: return .gray
            case .uploading, .processing: return .blue
            case .complete: return .green
            case .failed: return .red
            }
        }
    }
    
    var displayURL: URL? {
        // Use resolvedFileURL which already handles both local and SharePoint URLs
        return resolvedFileURL
    }
    
    enum EvidenceType: String, Codable, CaseIterable {
        case photo = "Photo"
        case video = "Video"
        case document = "Document"
        case audio = "Audio"
        
        var iconName: String {
            switch self {
            case .photo: return "photo"
            case .video: return "video"
            case .document: return "doc"
            case .audio: return "music.note"
            }
        }
    }
    
    enum AssessmentStatus: String, Codable {
        case pending = "Pending"
        case approved = "Approved"
        case rejected = "Rejected"
        case needsRevision = "Needs Revision"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, criteriaCode, unitCode, dateUploaded, type, title, description
        case bookmarkData, sharePointUrl, uploadDate, associatedCriteria
        case criteriaDescription, assessmentStatus, assessorFeedback
        case assessmentDate, assessorName, isLocallyUploaded
        case _fileURL = "fileURL"
        case uploadProgress
        case processingStatus
        case isHidden
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode non-published properties first
        id = try container.decode(UUID.self, forKey: .id)
        criteriaCode = try container.decode(String.self, forKey: .criteriaCode)
        unitCode = try container.decode(String.self, forKey: .unitCode)
        dateUploaded = try container.decode(Date.self, forKey: .dateUploaded)
        type = try container.decode(EvidenceType.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        associatedCriteria = try container.decode([String].self, forKey: .associatedCriteria)
        criteriaDescription = try container.decode(String.self, forKey: .criteriaDescription)
        
        // Initialize published properties
        _assessmentStatus = Published(initialValue: try container.decodeIfPresent(AssessmentStatus.self, forKey: .assessmentStatus) ?? .pending)
        _assessorFeedback = Published(initialValue: try container.decodeIfPresent(String.self, forKey: .assessorFeedback))
        _assessorName = Published(initialValue: try container.decodeIfPresent(String.self, forKey: .assessorName))
        _assessmentDate = Published(initialValue: try container.decodeIfPresent(Date.self, forKey: .assessmentDate))
        _isLocallyUploaded = Published(initialValue: try container.decodeIfPresent(Bool.self, forKey: .isLocallyUploaded) ?? false)
        _uploadProgress = Published(initialValue: try container.decodeIfPresent(Double.self, forKey: .uploadProgress) ?? 0.0)
        _processingStatus = Published(initialValue: try container.decodeIfPresent(ProcessingStatus.self, forKey: .processingStatus) ?? .notStarted)
        
        // Optional fields
        bookmarkData = try container.decodeIfPresent(Data.self, forKey: .bookmarkData)
        sharePointUrl = try container.decodeIfPresent(String.self, forKey: .sharePointUrl)
        _fileURL = try container.decodeIfPresent(URL.self, forKey: ._fileURL)
        uploadDate = try container.decodeIfPresent(Date.self, forKey: .uploadDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode non-published properties
        try container.encode(id, forKey: .id)
        try container.encode(criteriaCode, forKey: .criteriaCode)
        try container.encode(unitCode, forKey: .unitCode)
        try container.encode(dateUploaded, forKey: .dateUploaded)
        try container.encode(type, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(associatedCriteria, forKey: .associatedCriteria)
        try container.encode(criteriaDescription, forKey: .criteriaDescription)
        
        // Encode published properties
        try container.encode(assessmentStatus, forKey: .assessmentStatus)
        try container.encode(assessorFeedback, forKey: .assessorFeedback)
        try container.encode(assessorName, forKey: .assessorName)
        try container.encode(assessmentDate, forKey: .assessmentDate)
        try container.encode(isLocallyUploaded, forKey: .isLocallyUploaded)
        
        // Optional fields
        try container.encodeIfPresent(bookmarkData, forKey: .bookmarkData)
        try container.encodeIfPresent(sharePointUrl, forKey: .sharePointUrl)
        try container.encodeIfPresent(_fileURL, forKey: ._fileURL)
        try container.encodeIfPresent(uploadDate, forKey: .uploadDate)
        try container.encode(uploadProgress, forKey: .uploadProgress)
        try container.encode(processingStatus, forKey: .processingStatus)
    }
    
    init(id: UUID = UUID(),
         criteriaCode: String,
         unitCode: String,
         dateUploaded: Date = Date(),
         type: EvidenceType,
         title: String,
         description: String,
         bookmarkData: Data? = nil,
         sharePointUrl: String? = nil,
         fileURL: URL? = nil,
         uploadDate: Date? = nil,
         associatedCriteria: [String],
         criteriaDescription: String,
         assessmentStatus: AssessmentStatus? = nil,
         assessorFeedback: String? = nil,
         assessorName: String? = nil,
         assessmentDate: Date? = nil,
         isLocallyUploaded: Bool = false) {
        
        self.id = id
        self.criteriaCode = criteriaCode
        self.unitCode = unitCode
        self.dateUploaded = dateUploaded
        self.type = type
        self.title = title
        self.description = description
        self.bookmarkData = bookmarkData
        self.sharePointUrl = sharePointUrl
        self._fileURL = fileURL
        self.uploadDate = uploadDate
        self.associatedCriteria = associatedCriteria
        self.criteriaDescription = criteriaDescription
        self.assessmentStatus = assessmentStatus ?? .pending
        self.assessorFeedback = assessorFeedback
        self.assessorName = assessorName
        self.assessmentDate = assessmentDate
        self.isLocallyUploaded = isLocallyUploaded
    }
    
    var resolvedFileURL: URL? {
        // First try SharePoint URL if available
        if let sharePointURL = sharePointUrl,
           let url = URL(string: sharePointURL) {
            return url
        }
        
        // Then try local bookmark if available
        if let bookmarkData = bookmarkData {
            var isStale = false
            do {
                #if targetEnvironment(simulator)
                return _fileURL
                #else
                let url = try URL(resolvingBookmarkData: bookmarkData, 
                                options: [], 
                                relativeTo: nil, 
                                bookmarkDataIsStale: &isStale)
                return url
                #endif
            } catch {
                print("Error resolving bookmark: \(error)")
            }
        }
        
        // Finally fall back to stored URL
        return _fileURL
    }
    
    func updateSharePointInfo(url: String, status: AssessmentStatus = .pending) {
        if let webUrl = extractWebUrl(from: url) {
            self.sharePointUrl = webUrl
            self.uploadDate = Date()
            self.assessmentStatus = status
            self.assessorFeedback = ""
            self.assessmentDate = self.uploadDate
            self.isLocallyUploaded = true
            
            print("Evidence Upload Status:")
            print("- SharePoint URL: \(self.sharePointUrl ?? "")")
            print("- Status: \(status.rawValue)")
            print("- Upload Date: \(self.uploadDate?.description ?? "Unknown")")
            print("- Is Uploaded: \(self.isUploaded)")
        }
    }
    
    private func extractWebUrl(from url: String) -> String? {
        return url.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updateAssessmentInfo(from metadata: EvidenceMetadata) {
        print("Updating assessment info from metadata:")
        print("- Previous Status:", assessmentStatus.rawValue)
        print("- New Status:", metadata.assessmentStatus?.rawValue ?? "nil")
        
        if let newStatus = metadata.assessmentStatus {
            assessmentStatus = newStatus
        }
        assessorFeedback = metadata.assessorFeedback
        assessorName = metadata.assessorName
        assessmentDate = metadata.assessmentDate
        
        print("Update complete:")
        print("- Current Status:", assessmentStatus.rawValue)
        print("- Has Feedback:", hasFeedback)
    }
    
    var isUploaded: Bool {
        // Consider evidence uploaded if it has a SharePoint URL or is marked as locally uploaded
        return (sharePointUrl != nil && !sharePointUrl!.isEmpty) || isLocallyUploaded
    }
    
    var hasAssessment: Bool {
        return assessmentStatus != .pending
    }
    
    var currentStatus: AssessmentStatus {
        return assessmentStatus
    }
    
    var displayStatus: String {
        return currentStatus.rawValue
    }
    
    var hasFeedback: Bool {
        return assessorFeedback != nil && !assessorFeedback!.isEmpty
    }
    
    static func == (lhs: Evidence, rhs: Evidence) -> Bool {
        return lhs.id == rhs.id &&
               lhs.criteriaCode == rhs.criteriaCode &&
               lhs.unitCode == rhs.unitCode &&
               lhs.dateUploaded == rhs.dateUploaded &&
               lhs.type == rhs.type &&
               lhs.title == rhs.title &&
               lhs.description == rhs.description &&
               lhs.sharePointUrl == rhs.sharePointUrl &&
               lhs.uploadDate == rhs.uploadDate &&
               lhs.associatedCriteria == rhs.associatedCriteria &&
               lhs.criteriaDescription == rhs.criteriaDescription &&
               lhs.assessmentStatus == rhs.assessmentStatus &&
               lhs.assessorFeedback == rhs.assessorFeedback &&
               lhs.assessmentDate == rhs.assessmentDate &&
               lhs.assessorName == rhs.assessorName &&
               lhs.isLocallyUploaded == rhs.isLocallyUploaded
    }
    
    func updateProgress(_ progress: Double) {
        uploadProgress = min(max(progress, 0), 1)
        if progress >= 1 {
            processingStatus = .processing
        } else if progress > 0 {
            processingStatus = .uploading
        }
    }
    
    func completeProcessing(success: Bool) {
        processingStatus = success ? .complete : .failed
        if success {
            uploadProgress = 1.0
        }
    }
    
    var overallStatus: String {
        if processingStatus != .complete {
            return processingStatus.rawValue
        }
        return assessmentStatus.displayName
    }
    
    var criteriaArray: [String] {
        // Convert underscore-separated string to array
        criteriaCode.split(separator: "_").map(String.init)
    }
    
    var displayCriteriaCode: String {
        // For display purposes, show with commas and spaces
        criteriaArray.joined(separator: ", ")
    }
    
    var sharePointCriteriaCode: String {
        // Ensure we always use underscores for SharePoint
        criteriaArray.joined(separator: "_")
    }
    
    var criteriaDescriptionArray: [String] {
        // Split descriptions that were joined with pipes
        criteriaDescription.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}

extension Evidence.AssessmentStatus {
    var displayName: String {
        switch self {
        case .pending: return "Pending Assessment"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .needsRevision: return "Revision Required"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .approved: return .green
        case .rejected: return .red
        case .needsRevision: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "hourglass.circle"
        case .approved: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        case .needsRevision: return "pencil.circle"
        }
    }
    
    var accessibilityDescription: String {
        switch self {
        case .pending: return "Assessment is pending review"
        case .approved: return "Evidence has been approved"
        case .rejected: return "Evidence requires revision"
        case .needsRevision: return "Evidence needs to be revised"
        }
    }
}

extension Evidence {
    var statusDisplayInfo: (text: String, color: Color, icon: String) {
        let status = currentStatus
        return (
            text: status.displayName,
            color: status.color,
            icon: status.icon
        )
    }
    
    var formattedAssessmentDate: String? {
        guard let date = assessmentDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var feedbackSummary: String {
        if let feedback = assessorFeedback, !feedback.isEmpty {
            return feedback
        }
        return "No feedback provided yet"
    }
    
    var progressDisplayInfo: (progress: Double, color: Color, icon: String) {
        switch processingStatus {
        case .notStarted:
            return (0, .gray, "circle")
        case .uploading:
            return (uploadProgress, .blue, "arrow.up.circle")
        case .processing:
            return (uploadProgress, .blue, "gear.circle")
        case .complete:
            return (1, statusDisplayInfo.color, statusDisplayInfo.icon)
        case .failed:
            return (uploadProgress, .red, "exclamationmark.circle.fill")
        }
    }
} 