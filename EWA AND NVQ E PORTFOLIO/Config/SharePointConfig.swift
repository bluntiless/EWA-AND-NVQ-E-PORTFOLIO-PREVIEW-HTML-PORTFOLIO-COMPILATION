import Foundation

struct SharePointConfig {
    static let siteHost = "wrightspark625.sharepoint.com"
    static let sitePath = "sites/EWANVQLevel3ElectroTechnical"
    static let siteURL = "https://\(siteHost)/\(sitePath)"
    
    static let evidenceLibrary = "Evidence"
    static let assessmentsLibrary = "Assessments"
    static let templatesLibrary = "Templates"
    
    static let maxFileSize = 100 * 1024 * 1024 // 100MB
    static let allowedFileTypes = [
        "jpg", "jpeg", "png", // Images
        "mp4", "mov",         // Videos
        "pdf", "doc", "docx"  // Documents
    ]
    
    static func validateFile(_ url: URL) -> Bool {
        let fileExtension = url.pathExtension.lowercased()
        return allowedFileTypes.contains(fileExtension)
    }
    
    static func evidencePath(for evidence: Evidence, userEmail: String) -> String {
        let candidatePath = getCandidatePath(for: userEmail)
        return "\(candidatePath)/\(evidence.unitCode)/\(evidence.criteriaCode)"
    }
    
    static let baseUrl = "wrightspark625.sharepoint.com"
    static let siteId = "..."
    
    static func getCandidatePath(for userEmail: String) -> String {
        let username = userEmail.split(separator: "@").first ?? ""
        return "\(evidenceLibrary)/Candidates/\(username)"
    }
} 