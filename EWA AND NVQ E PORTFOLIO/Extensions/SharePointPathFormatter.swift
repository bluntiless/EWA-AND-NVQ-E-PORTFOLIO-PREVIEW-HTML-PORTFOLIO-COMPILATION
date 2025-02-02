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
    
    static func formatPath(unitCode: String, criteriaCode: String, isHtmlDocument: Bool = false) -> String {
        if isHtmlDocument {
            // For HTML files, encode for Graph API with proper escaping
            let encodedUnit = unitCode
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?
                .replacingOccurrences(of: " ", with: "+") ?? unitCode
            
            let encodedCriteria = criteriaCode
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?
                .replacingOccurrences(of: " ", with: "+") ?? criteriaCode
            
            return "Evidence/\(encodedUnit)/\(encodedCriteria)"
                .replacingOccurrences(of: "%", with: "%25")
        } else {
            let sanitizedUnit = unitCode.asSharePointPathComponent()
            let sanitizedCriteria = criteriaCode.asSharePointPathComponent()
            return "Evidence/\(sanitizedUnit)/\(sanitizedCriteria)"
        }
    }
    
    static func constructUrl(path: String, fileName: String, format: UrlFormat = .absolute) -> String {
        let encodedPath = path // Path is already encoded appropriately
        
        // Use appropriate space encoding based on format
        let encodedFileName = format == .htmlMetadata 
            ? fileName.replacingOccurrences(of: " ", with: "_")
                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
            : fileName.replacingOccurrences(of: " ", with: "%20")
        
        let basePath = "\(baseUrl)\(siteUrl)/\(documentsPath)"
        
        switch format {
        case .metadata, .htmlMetadata:
            if format == .htmlMetadata {
                // For HTML files, ensure consistent underscore usage
                return "\(basePath)/\(encodedPath)/\(encodedFileName)"
                    .replacingOccurrences(of: "%20", with: "_")
            } else {
                return "\(basePath)/\(encodedPath)/\(encodedFileName)"
            }
        case .absolute:
            return "\(basePath)/\(encodedPath)/\(encodedFileName)"
        case .relative:
            return "\(siteUrl)/\(documentsPath)/\(encodedPath)/\(encodedFileName)"
        }
    }
    
    enum UrlFormat {
        case absolute   // Full URL for display/verification
        case relative   // For SharePoint API calls
        case metadata   // For regular metadata API calls
        case htmlMetadata // For HTML file metadata
    }
} 