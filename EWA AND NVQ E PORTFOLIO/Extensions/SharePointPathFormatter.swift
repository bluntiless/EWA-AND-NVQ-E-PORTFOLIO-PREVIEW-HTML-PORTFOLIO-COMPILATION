import Foundation

extension String {
    func asSharePointPathComponent() -> String {
        return self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ".", with: "_")
    }
}

struct SharePointPathFormatter {
    private static let baseUrl = "https://wrightspark625.sharepoint.com"
    private static let siteUrl = "/sites/EWANVQLevel3ElectroTechnical"
    private static let documentsPath = "Shared Documents"
    
    static func formatPath(unitCode: String, criteriaCode: String) -> String {
        let sanitizedUnit = unitCode.asSharePointPathComponent()
        let sanitizedCriteria = criteriaCode.asSharePointPathComponent()
        return "Evidence/\(sanitizedUnit)/\(sanitizedCriteria)"
    }
    
    static func constructUrl(path: String, fileName: String, format: UrlFormat = .absolute) -> String {
        switch format {
        case .absolute:
            return "\(baseUrl)\(siteUrl)/\(documentsPath)/\(path)/\(fileName)"
        case .relative:
            return "\(siteUrl)/\(documentsPath)/\(path)/\(fileName)"
        case .metadata:
            // For metadata API calls
            return "\(baseUrl)\(siteUrl)/\(documentsPath)/\(path)/\(fileName)"
                .replacingOccurrences(of: " ", with: "%20")
        }
    }
    
    enum UrlFormat {
        case absolute  // Full URL for display/verification
        case relative  // For SharePoint API calls
        case metadata // For metadata API calls
    }
} 