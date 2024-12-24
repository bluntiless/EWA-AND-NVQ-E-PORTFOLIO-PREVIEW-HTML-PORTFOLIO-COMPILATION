import Foundation

enum AppError: Error {
    case notConfigured
    case authenticationFailed
    case networkError(Error)
    case fileAccessError(Error)
    case uploadFailed(Error)
    case schedulingFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .notConfigured:
            return "App is not properly configured"
        case .authenticationFailed:
            return "Authentication failed"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .fileAccessError(let error):
            return "File access error: \(error.localizedDescription)"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .schedulingFailed(let error):
            return "Scheduling failed: \(error.localizedDescription)"
        }
    }
} 