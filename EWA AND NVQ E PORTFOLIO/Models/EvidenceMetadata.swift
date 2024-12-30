import Foundation

struct EvidenceMetadata: Codable {
    let id: String?
    let name: String?
    let webUrl: String?
    let downloadUrl: String?
    let createdDateTime: Date?
    let lastModifiedDateTime: Date?
    let size: Int?
    let mimeType: String?
    let assessmentStatus: Evidence.AssessmentStatus?
    let assessorFeedback: String?
    let assessorName: String?
    let assessmentDate: Date?
    
    init(id: String? = nil,
         name: String? = nil,
         webUrl: String? = nil,
         downloadUrl: String? = nil,
         createdDateTime: Date? = nil,
         lastModifiedDateTime: Date? = nil,
         size: Int? = nil,
         mimeType: String? = nil,
         assessmentStatus: Evidence.AssessmentStatus? = nil,
         assessorFeedback: String? = nil,
         assessorName: String? = nil,
         assessmentDate: Date? = nil) {
        self.id = id
        self.name = name
        self.webUrl = webUrl
        self.downloadUrl = downloadUrl
        self.createdDateTime = createdDateTime
        self.lastModifiedDateTime = lastModifiedDateTime
        self.size = size
        self.mimeType = mimeType
        self.assessmentStatus = assessmentStatus
        self.assessorFeedback = assessorFeedback
        self.assessorName = assessorName
        self.assessmentDate = assessmentDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, webUrl
        case downloadUrl = "@microsoft.graph.downloadUrl"
        case createdDateTime, lastModifiedDateTime, size
        case file
        case listItem
    }
    
    enum FileKeys: String, CodingKey {
        case mimeType
    }
    
    enum ListItemKeys: String, CodingKey {
        case fields
    }
    
    enum FieldKeys: String, CodingKey {
        case assessmentStatus = "AssessmentStatus"
        case assessorFeedback = "AssessorFeedback"
        case assessorName = "AssessorName"
        case assessmentDate = "AssessmentDate"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        webUrl = try container.decodeIfPresent(String.self, forKey: .webUrl)
        downloadUrl = try container.decodeIfPresent(String.self, forKey: .downloadUrl)
        createdDateTime = try container.decodeIfPresent(Date.self, forKey: .createdDateTime)
        lastModifiedDateTime = try container.decodeIfPresent(Date.self, forKey: .lastModifiedDateTime)
        size = try container.decodeIfPresent(Int.self, forKey: .size)
        
        // Get file metadata
        if let fileContainer = try? container.nestedContainer(keyedBy: FileKeys.self, forKey: .file) {
            mimeType = try fileContainer.decodeIfPresent(String.self, forKey: .mimeType)
        } else {
            mimeType = nil
        }
        
        // Get assessment metadata
        if let listItemContainer = try? container.nestedContainer(keyedBy: ListItemKeys.self, forKey: .listItem),
           let fieldsContainer = try? listItemContainer.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields) {
            let statusString = try fieldsContainer.decodeIfPresent(String.self, forKey: .assessmentStatus)
            assessmentStatus = statusString.flatMap { Evidence.AssessmentStatus(rawValue: $0.lowercased()) } ?? .pending
            assessorFeedback = try fieldsContainer.decodeIfPresent(String.self, forKey: .assessorFeedback)
            assessorName = try fieldsContainer.decodeIfPresent(String.self, forKey: .assessorName)
            assessmentDate = try fieldsContainer.decodeIfPresent(Date.self, forKey: .assessmentDate)
        } else {
            assessmentStatus = .pending
            assessorFeedback = nil
            assessorName = nil
            assessmentDate = lastModifiedDateTime
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(webUrl, forKey: .webUrl)
        try container.encodeIfPresent(downloadUrl, forKey: .downloadUrl)
        try container.encodeIfPresent(createdDateTime, forKey: .createdDateTime)
        try container.encodeIfPresent(lastModifiedDateTime, forKey: .lastModifiedDateTime)
        try container.encodeIfPresent(size, forKey: .size)
        
        var fileContainer = container.nestedContainer(keyedBy: FileKeys.self, forKey: .file)
        try fileContainer.encodeIfPresent(mimeType, forKey: .mimeType)
        
        var listItemContainer = container.nestedContainer(keyedBy: ListItemKeys.self, forKey: .listItem)
        var fieldsContainer = listItemContainer.nestedContainer(keyedBy: FieldKeys.self, forKey: .fields)
        try fieldsContainer.encodeIfPresent(assessmentStatus?.rawValue, forKey: .assessmentStatus)
        try fieldsContainer.encodeIfPresent(assessorFeedback, forKey: .assessorFeedback)
        try fieldsContainer.encodeIfPresent(assessorName, forKey: .assessorName)
        try fieldsContainer.encodeIfPresent(assessmentDate, forKey: .assessmentDate)
    }
}