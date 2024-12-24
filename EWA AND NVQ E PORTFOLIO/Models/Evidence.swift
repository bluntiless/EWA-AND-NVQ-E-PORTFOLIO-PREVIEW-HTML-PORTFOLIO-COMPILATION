import Foundation

struct Evidence: Codable, Identifiable {
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
    var sharePointURL: String?
    let associatedCriteria: [String]
    let criteriaDescription: String
    
    enum EvidenceType: String, Codable {
        case document
        case photo
        case video
        
        var allowedExtensions: [String] {
            switch self {
            case .document:
                return ["pdf", "doc", "docx"]
            case .photo:
                return ["jpg", "jpeg", "png", "heic"]
            case .video:
                return ["mp4", "mov"]
            }
        }
        
        var maxFileSize: Int {
            switch self {
            case .document:
                return 50 * 1024 * 1024  // 50MB
            case .photo:
                return 20 * 1024 * 1024  // 20MB
            case .video:
                return 500 * 1024 * 1024 // 500MB
            }
        }
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
         associatedCriteria: [String] = [],
         criteriaDescription: String = "") {
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
        self.associatedCriteria = associatedCriteria
        self.criteriaDescription = criteriaDescription
        self.uploadDate = nil
        self.sharePointURL = nil
    }
    
    var resolvedFileURL: URL? {
        get throws {
            if let url = _fileURL {
                return url
            }
            
            guard let bookmarkData = bookmarkData else {
                throw AppError.fileAccessError(NSError(domain: "", code: -1))
            }
            
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData,
                            options: [],
                            relativeTo: nil,
                            bookmarkDataIsStale: &isStale)
            
            return url
        }
    }
    
    mutating func setFileURL(_ url: URL) {
        self._fileURL = url
    }
    
    mutating func setBookmarkData(_ data: Data) {
        self.bookmarkData = data
    }
    
    mutating func setSharePointUrl(_ url: String) {
        self.sharePointUrl = url
    }
    
    mutating func setUploadDate(_ date: Date) {
        self.uploadDate = date
    }
} 