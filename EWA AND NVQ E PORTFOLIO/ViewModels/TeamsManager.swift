import Foundation
import MSAL
import UIKit
import AuthenticationServices
import CommonCrypto

// Move SharePointResponse and related types to file scope
private struct SharePointResponse: Codable {
    let d: SharePointResults
    
    struct SharePointResults: Codable {
        let results: [SharePointItem]
    }
    
    struct SharePointItem: Codable {
        let FileLeafRef: String?
        let AssessmentStatus: String?
        let AssessorFeedback: String?
        let AssessorName: String?
        let Modified: String?
        let Id: Int?
        
        enum CodingKeys: String, CodingKey {
            case FileLeafRef
            case AssessmentStatus = "AssessmentStatus"
            case AssessorFeedback = "AssessorFeedback"
            case AssessorName = "AssessorName"
            case Modified
            case Id
        }
    }
}

class WebAuthenticationPresenter: NSObject, ASWebAuthenticationPresentationContextProviding {
    weak var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
        super.init()
    }
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return window ?? UIWindow()
    }
}

@MainActor
class TeamsManager: NSObject, ObservableObject {
    static let shared = TeamsManager()
    
    @Published var isAuthenticated = false
    @Published var availableChannels: [Channel] = []
    @Published private(set) var currentUpload: UploadProgress?
    
    private let clientId = "4dee2fb0-16a8-417e-99e0-182238406716"
    private let redirectUri = "msauth.com.waynewright.ewa-nvq-portfolio1://auth"
    private let tenantId = "f06bb1fd-4f8d-4dd6-bed9-8ae702c632b9"
    private let authority = "https://login.microsoftonline.com/f06bb1fd-4f8d-4dd6-bed9-8ae702c632b9"
    private let graphEndpoint = "https://graph.microsoft.com/v1.0"
    private var accessToken: String?
    
    private weak var presentingViewController: UIViewController?
    private var webAuthPresenter: WebAuthenticationPresenter?
    
    private var cachedToken: String? {
        get {
            UserDefaults.standard.string(forKey: "msalAccessToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "msalAccessToken")
        }
    }
    
    private var tokenExpirationDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "msalTokenExpiration") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "msalTokenExpiration")
        }
    }
    
    struct Channel: Identifiable {
        let id: String
        let name: String
        let description: String?
    }
    
    struct UploadProgress {
        let filename: String
        var progress: Double
        var status: UploadStatus
        
        enum UploadStatus {
            case preparing
            case uploading
            case processing
            case complete
            case failed(Error)
        }
    }
    
    struct UploadSession: Codable {
        let uploadUrl: String
    }
    
    private override init() {
        super.init()
    }
    
    func setPresentingViewController(_ viewController: UIViewController) {
        self.presentingViewController = viewController
        self.webAuthPresenter = WebAuthenticationPresenter(window: viewController.view.window)
    }
    
    func validateFile(_ url: URL) throws {
        guard SharePointConfig.validateFile(url) else {
            throw AppError.fileAccessError(NSError(
                domain: "com.waynewright.ewa-nvq-portfolio1",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid file"]
            ))
        }
    }
    
    func uploadMultipleToSharePoint(evidenceItems: [Evidence]) async throws -> [Evidence] {
        var updatedItems: [Evidence] = []
        
        for evidence in evidenceItems {
            // Upload file and get verification response
            let updatedEvidence = try await uploadToSharePoint(evidence: evidence)
            updatedItems.append(updatedEvidence)
        }
        
        return updatedItems
    }
    
    private func uploadToSharePoint(evidence: Evidence) async throws -> Evidence {
        print("\n=== Starting SharePoint Upload ===")
        
        // Ensure we're authenticated first
        try await authenticate()
        
        let updatedEvidence = evidence
        
        // Get file URL
        guard let fileURL = evidence.resolvedFileURL else {
            throw EvidenceError.fileAccessError
        }
        
        // Load file data
        guard let fileData = try? Data(contentsOf: fileURL) else {
            throw EvidenceError.fileAccessError
        }
        
        print("✅ File validation passed")
        print("- Size: \(ByteCountFormatter.string(fromByteCount: Int64(fileData.count), countStyle: .file))")
        
        do {
            let session = try await createUploadSession(for: updatedEvidence, fileURL: fileURL)
            
            // Get the verified URL from the folder structure
            let folderPath = "Evidence/\(evidence.unitCode.replacingOccurrences(of: "-", with: "_"))/\(evidence.criteriaCode.replacingOccurrences(of: ".", with: "_"))"
            let webUrl = "https://wrightspark625.sharepoint.com/sites/EWANVQLevel3ElectroTechnical/Shared%20Documents/\(folderPath)/\(fileURL.lastPathComponent)"
            
            // Update evidence with the correct URL
            updatedEvidence.updateSharePointInfo(url: webUrl)
            
            print("✅ Upload session created")
            
            try await uploadFile(
                data: fileData,
                to: session.uploadUrl,
                filename: fileURL.lastPathComponent,
                onProgress: { progress in
                    print("📤 Upload progress: \(Int(progress * 100))%")
                    self.currentUpload = UploadProgress(
                        filename: fileURL.lastPathComponent,
                        progress: progress,
                        status: .uploading
                    )
                }
            )
            
            try await verifyUpload(url: session.uploadUrl)
            
            // Set initial state
            updatedEvidence.uploadDate = Date()
            updatedEvidence.assessmentStatus = .pending
            
            // Try to update metadata
            do {
                let metadata = try await fetchEvidenceMetadata(from: session.uploadUrl)
                updatedEvidence.updateAssessmentInfo(from: metadata)
            } catch {
                print("⚠️ Metadata update failed, using default values: \(error.localizedDescription)")
            }
            
            print("""
            ✅ Upload completed:
            - Status: \(updatedEvidence.assessmentStatus.rawValue)
            - URL: \(updatedEvidence.sharePointUrl ?? "unknown")
            - Date: \(updatedEvidence.uploadDate?.description ?? "unknown")
            """)
            
            // After verification, ensure we're using the verified URL
            if let verifiedUrl = try? await getVerifiedUrl(from: session.uploadUrl) {
                updatedEvidence.updateSharePointInfo(url: verifiedUrl)
            }
            
            return updatedEvidence
            
        } catch {
            print("❌ Upload failed: \(error.localizedDescription)")
            throw EvidenceError.uploadFailed(error.localizedDescription)
        }
    }
    
    private func createFolder(in driveId: String, path: String) async throws -> (String, [String: Any]) {
        print("Creating folder: \(path)")
        
        // Encode the path properly for the URL
        let encodedPath = path.components(separatedBy: "/")
            .map { $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? $0 }
            .joined(separator: "/")
        
        let endpoint = "\(graphEndpoint)/drives/\(driveId)/root:/\(encodedPath)"
        
        guard let url = URL(string: endpoint) else {
            throw EvidenceError.uploadFailed("Invalid folder URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        // First try to get the folder
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // If folder exists (200 status), parse and return its ID and response
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let folderId = json["id"] as? String {
                print("✅ Folder exists: \(path) (ID: \(folderId))")
                return (folderId, json)
            }
            
            // Log the error response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Folder check response: \(responseString)")
            }
        } catch {
            print("Folder not found, creating...")
        }
        
        // If folder doesn't exist, create it
        let parentPath = path.components(separatedBy: "/").dropLast().joined(separator: "/")
        let folderName = path.components(separatedBy: "/").last ?? path
        
        let createEndpoint = parentPath.isEmpty ? 
            "\(graphEndpoint)/drives/\(driveId)/root/children" :
            "\(graphEndpoint)/drives/\(driveId)/root:/\(parentPath):/children"
        
        guard let createUrl = URL(string: createEndpoint) else {
            throw EvidenceError.uploadFailed("Invalid create folder URL")
        }
        
        var createRequest = URLRequest(url: createUrl)
        createRequest.httpMethod = "POST"
        createRequest.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        createRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "name": folderName,
            "folder": [:],
            "@microsoft.graph.conflictBehavior": "rename"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw EvidenceError.uploadFailed("Failed to create request body")
        }
        createRequest.httpBody = jsonData
        
        let (data, createResponse) = try await URLSession.shared.data(for: createRequest)
        
        guard let httpResponse = createResponse as? HTTPURLResponse else {
            throw EvidenceError.uploadFailed("Invalid response")
        }
        
        print("Create folder response status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Create folder response: \(responseString)")
        }
        
        guard httpResponse.statusCode == 201 || httpResponse.statusCode == 200 else {
            if let error = try? JSONDecoder().decode(SharePointError.self, from: data) {
                throw EvidenceError.uploadFailed("Failed to create folder: \(error.error.message)")
            }
            throw EvidenceError.uploadFailed("Failed to create folder (Status: \(httpResponse.statusCode))")
        }
        
        // Parse the response to get the folder ID and return full response
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let folderId = json["id"] as? String else {
            throw EvidenceError.uploadFailed("Could not get folder information from response")
        }
        
        print("✅ Created/Found folder: \(path) (ID: \(folderId))")
        return (folderId, json)
    }
    
    private func findDocumentsDrive() async throws -> String {
        let siteId = "wrightspark625.sharepoint.com,77f748ac-6618-4f8d-ae7b-1e927fad2fea,f7a8aba3-0493-4888-8d22-00685d8072ae"
        let driveEndpoint = "\(graphEndpoint)/sites/\(siteId)/drives"
        
        print("\n=== Getting Drive ID ===")
        
        var request = URLRequest(url: URL(string: driveEndpoint)!)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (driveData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw EvidenceError.uploadFailed("Failed to get drives list")
        }
        
        // Log the full response for debugging
        if let jsonString = String(data: driveData, encoding: .utf8) {
            print("Drives response: \(jsonString)")
        }
        
        guard let drivesJson = try? JSONSerialization.jsonObject(with: driveData) as? [String: Any],
              let drives = drivesJson["value"] as? [[String: Any]] else {
            throw EvidenceError.uploadFailed("Invalid drives response format")
        }
        
        print("Found \(drives.count) drives:")
        for drive in drives {
            print("- Name: \(drive["name"] as? String ?? "unknown")")
            print("  ID: \(drive["id"] as? String ?? "unknown")")
        }
        
        // Try different possible drive names
        let possibleNames = ["Documents", "Shared Documents", "Document Library"]
        for name in possibleNames {
            if let drive = drives.first(where: { ($0["name"] as? String)?.contains(name) ?? false }),
               let driveId = drive["id"] as? String {
                print("✅ Found matching drive: \(name) (ID: \(driveId))")
                return driveId
            }
        }
        
        // If no matching drive found, try to use the first available drive
        if let firstDrive = drives.first,
           let driveId = firstDrive["id"] as? String {
            print("⚠️ Using first available drive: \(firstDrive["name"] as? String ?? "unknown") (ID: \(driveId))")
            return driveId
        }
        
        throw EvidenceError.uploadFailed("No suitable drive found")
    }
    
    private func createUploadSession(for evidence: Evidence, fileURL: URL) async throws -> UploadSession {
        let fileName = fileURL.lastPathComponent
        
        // Sanitize the path components
        let sanitizedUnitCode = evidence.unitCode
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
        
        let sanitizedCriteriaCode = evidence.criteriaCode
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: ",", with: "_")
        
        // Get drive ID with better error handling
        let driveId = try await findDocumentsDrive()
        
        // Create folder structure and get the final folder ID
        let folderStructure = [
            "Evidence",
            "Evidence/\(sanitizedUnitCode)",
            "Evidence/\(sanitizedUnitCode)/\(sanitizedCriteriaCode)"
        ]
        
        print("\n=== Creating Folder Structure ===")
        var finalFolderId: String?
        var finalFolderWebUrl: String?
        
        for folder in folderStructure {
            let (folderId, response) = try await createFolder(in: driveId, path: folder)
            finalFolderId = folderId
            if let webUrl = response["webUrl"] as? String {
                finalFolderWebUrl = webUrl
            }
        }
        
        guard let folderId = finalFolderId,
              let webUrl = finalFolderWebUrl else {
            throw EvidenceError.uploadFailed("Could not get folder information")
        }
        
        // Create upload session using item ID
        let encodedFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? fileName
        let endpoint = "\(graphEndpoint)/drives/\(driveId)/items/\(folderId):/\(encodedFileName):/createUploadSession"
        
        print("\n=== Creating Upload Session ===")
        print("File: \(fileName)")
        print("Folder ID: \(folderId)")
        print("Web URL: \(webUrl)")
        print("Endpoint: \(endpoint)")
        
        guard let url = URL(string: endpoint) else {
            throw EvidenceError.uploadFailed("Invalid upload URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "@microsoft.graph.conflictBehavior": "rename"
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw EvidenceError.uploadFailed("Failed to create request body")
        }
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EvidenceError.uploadFailed("Invalid response")
        }
        
        print("Response status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response body: \(responseString)")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let error = try? JSONDecoder().decode(SharePointError.self, from: data) {
                throw EvidenceError.uploadFailed(error.error.message)
            }
            throw EvidenceError.uploadFailed("Failed to create upload session (Status: \(httpResponse.statusCode))")
        }
        
        return try JSONDecoder().decode(UploadSession.self, from: data)
    }
    
    private func uploadFile(data: Data, to uploadUrl: String, filename: String, onProgress: @escaping (Double) -> Void) async throws {
        print("\n=== Starting Chunked Upload ===")
        print("Total size: \(data.count) bytes")
        
        guard let url = URL(string: uploadUrl) else {
            throw AppError.uploadFailed(NSError(domain: "", code: -1))
        }
        
        // Use 4MB chunks for large files
        let chunkSize = 4 * 1024 * 1024
        let totalChunks = Int(ceil(Double(data.count) / Double(chunkSize)))
        
        print("Uploading in \(totalChunks) chunks")
        
        for chunkIndex in 0..<totalChunks {
            let start = chunkIndex * chunkSize
            let end = min(start + chunkSize, data.count)
            let chunk = data[start..<end]
            
            let contentRange = "bytes \(start)-\(end-1)/\(data.count)"
            print("Uploading chunk \(chunkIndex + 1)/\(totalChunks): \(contentRange)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue(contentRange, forHTTPHeaderField: "Content-Range")
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.httpBody = Data(chunk)
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.uploadFailed(NSError(domain: "", code: -1))
            }
            
            // Check for success (201 Created or 202 Accepted)
            guard httpResponse.statusCode == 201 || httpResponse.statusCode == 202 else {
                print("❌ Chunk upload failed with status: \(httpResponse.statusCode)")
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                throw AppError.uploadFailed(NSError(domain: "", code: httpResponse.statusCode))
            }
            
            let progress = Double(end) / Double(data.count)
            await MainActor.run {
                onProgress(progress)
                self.currentUpload = UploadProgress(
                    filename: filename,
                    progress: progress,
                    status: .uploading
                )
            }
            print("✅ Chunk \(chunkIndex + 1) uploaded successfully (\(Int(progress * 100))%)")
        }
        
        print("✅ File upload completed")
    }
    
    func authenticate() async throws {
        print("\n=== Starting Authentication ===")
        
        // Check for cached valid token
        if let token = cachedToken,
           let expiration = tokenExpirationDate,
           expiration > Date() {
            print("✅ Using cached token")
            self.accessToken = token
            self.isAuthenticated = true
            return
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    guard self.presentingViewController != nil else {
                        throw AppError.authenticationFailed
                    }
                    
                    // Configure OAuth endpoints
                    let authEndpoint = "https://login.microsoftonline.com/\(tenantId)/oauth2/v2.0/authorize"
                    let tokenEndpoint = "https://login.microsoftonline.com/\(tenantId)/oauth2/v2.0/token"
                    
                    // Generate code verifier and challenge
                    let codeVerifier = String((0..<64).map { _ in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()! })
                    let codeChallenge = Data(codeVerifier.utf8)
                        .sha256()
                        .base64EncodedString()
                        .replacingOccurrences(of: "+", with: "-")
                        .replacingOccurrences(of: "/", with: "_")
                        .replacingOccurrences(of: "=", with: "")
                    
                    // Build authorization URL
                    var urlComponents = URLComponents(string: authEndpoint)!
                    urlComponents.queryItems = [
                        URLQueryItem(name: "client_id", value: clientId),
                        URLQueryItem(name: "response_type", value: "code"),
                        URLQueryItem(name: "redirect_uri", value: redirectUri),
                        URLQueryItem(name: "scope", value: "https://graph.microsoft.com/User.Read https://graph.microsoft.com/Files.ReadWrite.All https://graph.microsoft.com/Sites.ReadWrite.All offline_access"),
                        URLQueryItem(name: "prompt", value: "login"),
                        URLQueryItem(name: "code_challenge", value: codeChallenge),
                        URLQueryItem(name: "code_challenge_method", value: "S256")
                    ]
                    
                    let authURL = urlComponents.url!
                    print("Auth URL: \(authURL)")
                    
                    // Create web authentication session
                    let webAuthSession = ASWebAuthenticationSession(
                        url: authURL,
                        callbackURLScheme: "msauth.com.waynewright.ewa-nvq-portfolio1"
                    ) { callbackURL, error in
                        if let error = error {
                            print("❌ Web authentication error: \(error.localizedDescription)")
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let callbackURL = callbackURL,
                              let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true),
                              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                            print("❌ No authorization code received")
                            continuation.resume(throwing: AppError.authenticationFailed)
                            return
                        }
                        
                        // Exchange code for token
                        Task {
                            do {
                                var request = URLRequest(url: URL(string: tokenEndpoint)!)
                                request.httpMethod = "POST"
                                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                                
                                let body = [
                                    "client_id": self.clientId,
                                    "scope": "https://graph.microsoft.com/User.Read https://graph.microsoft.com/Files.ReadWrite.All https://graph.microsoft.com/Sites.ReadWrite.All offline_access",
                                    "code": code,
                                    "redirect_uri": self.redirectUri,
                                    "grant_type": "authorization_code",
                                    "code_verifier": codeVerifier
                                ]
                                
                                request.httpBody = body
                                    .map { "\($0.key)=\($0.value)" }
                                    .joined(separator: "&")
                                    .data(using: .utf8)
                                
                                let (data, response) = try await URLSession.shared.data(for: request)
                                
                                guard let httpResponse = response as? HTTPURLResponse,
                                      httpResponse.statusCode == 200,
                                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                                      let accessToken = json["access_token"] as? String,
                                      let expiresIn = json["expires_in"] as? TimeInterval else {
                                    throw AppError.authenticationFailed
                                }
                                
                                print("✅ Token exchange successful")
                                self.accessToken = accessToken
                                self.isAuthenticated = true
                                self.cachedToken = accessToken
                                self.tokenExpirationDate = Date().addingTimeInterval(expiresIn)
                                continuation.resume(returning: ())
                            } catch {
                                print("❌ Token exchange error: \(error)")
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                    
                    // Set presentation context
                    webAuthSession.presentationContextProvider = webAuthPresenter
                    webAuthSession.prefersEphemeralWebBrowserSession = true
                    
                    // Start authentication
                    print("Starting web authentication...")
                    webAuthSession.start()
                    
                } catch {
                    print("❌ Setup error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func testToken() async {
        print("\n=== Testing Token ===")
        do {
            try await authenticate()
            print("✅ Token test successful")
        } catch {
            print("❌ Token test failed: \(error)")
        }
    }
    
    public func fetchEvidenceMetadata(from url: String) async throws -> EvidenceMetadata {
        print("\n=== Fetching Evidence Metadata ===")
        print("URL: \(url)")
        
        guard let siteUrl = URL(string: url) else {
            throw EvidenceError.uploadFailed("Invalid URL")
        }
        
        // Get the relative path from the URL
        let pathComponents = siteUrl.pathComponents
        guard let evidenceIndex = pathComponents.firstIndex(of: "Evidence") else {
            throw EvidenceError.uploadFailed("Invalid evidence path")
        }
        
        let relativePath = pathComponents[evidenceIndex...].joined(separator: "/")
        print("Relative path: \(relativePath)")
        
        // First get the site ID
        let siteEndpoint = "https://graph.microsoft.com/v1.0/sites/wrightspark625.sharepoint.com:/sites/EWANVQLevel3ElectroTechnical"
        var request = URLRequest(url: URL(string: siteEndpoint)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        print("Fetching site details...")
        let (siteData, siteResponse) = try await URLSession.shared.data(for: request)
        let siteStatusCode = (siteResponse as? HTTPURLResponse)?.statusCode ?? 0
        print("Site response status: \(siteStatusCode)")
        
        guard let siteJson = try? JSONSerialization.jsonObject(with: siteData) as? [String: Any],
              let siteId = siteJson["id"] as? String else {
            throw EvidenceError.uploadFailed("Failed to get site ID")
        }
        
        print("Got site ID: \(siteId)")
        
        // Get the drive ID
        print("Fetching drive details...")
        let driveEndpoint = "https://graph.microsoft.com/v1.0/sites/\(siteId)/drives"
        request = URLRequest(url: URL(string: driveEndpoint)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (driveData, driveResponse) = try await URLSession.shared.data(for: request)
        let driveStatusCode = (driveResponse as? HTTPURLResponse)?.statusCode ?? 0
        print("Drive response status: \(driveStatusCode)")
        
        guard let driveJson = try? JSONSerialization.jsonObject(with: driveData) as? [String: Any],
              let drives = driveJson["value"] as? [[String: Any]],
              let driveId = drives.first?["id"] as? String else {
            throw EvidenceError.uploadFailed("Failed to get drive ID")
        }
        
        print("Got drive ID: \(driveId)")
        
        // Now get the file metadata with expanded fields
        let encodedPath = relativePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? relativePath
        let fileEndpoint = "https://graph.microsoft.com/v1.0/drives/\(driveId)/root:/\(encodedPath)" + 
            "?expand=listItem($select=fields,id)" +
            "&$select=id,name,webUrl,createdDateTime,lastModifiedDateTime,size,file,@microsoft.graph.downloadUrl"
        print("File endpoint:", fileEndpoint)
        
        request = URLRequest(url: URL(string: fileEndpoint)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        print("Fetching file metadata...")
        let (fileData, fileResponse) = try await URLSession.shared.data(for: request)
        let fileStatusCode = (fileResponse as? HTTPURLResponse)?.statusCode ?? 0
        print("File metadata response status: \(fileStatusCode)")
        
        if fileStatusCode == 404 {
            // Try alternate path format
            let alternateEndpoint = "https://graph.microsoft.com/v1.0/drives/\(driveId)/root:\(encodedPath.replacingOccurrences(of: "/", with: "\\"))"
            print("Trying alternate endpoint: \(alternateEndpoint)")
            
            request = URLRequest(url: URL(string: alternateEndpoint)!)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
            
            let (altData, altResponse) = try await URLSession.shared.data(for: request)
            let altStatusCode = (altResponse as? HTTPURLResponse)?.statusCode ?? 0
            
            if altStatusCode != 200 {
                throw EvidenceError.uploadFailed("File metadata fetch failed: The resource could not be found.")
            }
            
            return try await parseFileMetadata(from: altData, siteId: siteId)
        }
        
        if fileStatusCode != 200 {
            throw EvidenceError.uploadFailed("File metadata fetch failed with status: \(fileStatusCode)")
        }
        
        return try await parseFileMetadata(from: fileData, siteId: siteId)
    }
    
    private func parseFileMetadata(from data: Data, siteId: String) async throws -> EvidenceMetadata {
        guard let fileJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw EvidenceError.uploadFailed("Invalid metadata response")
        }
        
        print("Raw metadata response: \(fileJson)")
        
        let dateFormatter = ISO8601DateFormatter()
        let createdDate = dateFormatter.date(from: fileJson["createdDateTime"] as? String ?? "")
        let modifiedDate = dateFormatter.date(from: fileJson["lastModifiedDateTime"] as? String ?? "")
        
        // Get the list item ID first
        if let listItem = fileJson["listItem"] as? [String: Any],
           let listItemId = listItem["id"] as? String {
            let listItemEndpoint = "https://graph.microsoft.com/v1.0/sites/\(siteId)/lists/Documents/items/\(listItemId)?expand=fields"
            if let listItemData = try? await makeGraphRequest(listItemEndpoint),
               let fields = listItemData["fields"] as? [String: Any] {
                print("List item fields:", fields)
                
                // Extract fields - use exact field names from SharePoint
                let rawStatus = (fields["AssessmentStatus"] as? String)?.lowercased() ?? "pending"
                let assessmentStatus: Evidence.AssessmentStatus
                
                // Map SharePoint status to enum - case-insensitive comparison
                switch rawStatus {
                case let status where status.caseInsensitiveCompare("approved") == .orderedSame:
                    assessmentStatus = .approved
                case let status where status.caseInsensitiveCompare("rejected") == .orderedSame:
                    assessmentStatus = .rejected
                default:
                    assessmentStatus = .pending
                }
                
                let assessorFeedback = fields["AssessorFeedback"] as? String
                let assessorName = fields["AssessorName"] as? String
                let assessmentDate = fields["AssessmentDate"] as? String
                
                print("Extracted SharePoint fields:")
                print("- Assessment Status:", rawStatus)
                print("- Mapped Status:", assessmentStatus)
                print("- Assessor Feedback:", assessorFeedback ?? "None")
                print("- Assessor Name:", assessorName ?? "None")
                print("- Assessment Date:", assessmentDate ?? "None")
                
                // Create metadata with mapped status
                return EvidenceMetadata(
                    id: fileJson["id"] as? String,
                    name: fileJson["name"] as? String,
                    webUrl: fileJson["webUrl"] as? String,
                    downloadUrl: fileJson["@microsoft.graph.downloadUrl"] as? String,
                    createdDateTime: createdDate,
                    lastModifiedDateTime: modifiedDate,
                    size: (fileJson["size"] as? Int64).map { Int($0) },
                    mimeType: (fileJson["file"] as? [String: Any])?["mimeType"] as? String,
                    assessmentStatus: assessmentStatus,
                    assessorFeedback: assessorFeedback,
                    assessorName: assessorName,
                    assessmentDate: ISO8601DateFormatter().date(from: assessmentDate ?? "") ?? modifiedDate
                )
            }
        }
        
        // Fallback if we can't get list item fields
        return EvidenceMetadata(
            id: fileJson["id"] as? String,
            name: fileJson["name"] as? String,
            webUrl: fileJson["webUrl"] as? String,
            downloadUrl: fileJson["@microsoft.graph.downloadUrl"] as? String,
            createdDateTime: createdDate,
            lastModifiedDateTime: modifiedDate,
            size: (fileJson["size"] as? Int64).map { Int($0) },
            mimeType: (fileJson["file"] as? [String: Any])?["mimeType"] as? String,
            assessmentStatus: Evidence.AssessmentStatus(rawValue: fileJson["assessmentStatus"] as? String ?? "pending") ?? .pending,
            assessorFeedback: fileJson["assessorFeedback"] as? String,
            assessorName: fileJson["assessorName"] as? String,
            assessmentDate: fileJson["assessmentDate"] as? Date
        )
    }
    
    private func getSiteDriveId() async throws -> String {
        let siteEndpoint = "https://graph.microsoft.com/v1.0/sites/wrightspark625.sharepoint.com:/sites/EWANVQLevel3ElectroTechnical"
        var request = URLRequest(url: URL(string: siteEndpoint)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let driveId = json["id"] as? String else {
            throw EvidenceError.uploadFailed("Failed to get site drive ID")
        }
        
        return driveId
    }
    
    private func parseMetadata(from response: [String: Any]) throws -> EvidenceMetadata {
        print("Raw metadata response:", response)
        
        // Extract listItem fields which contain assessment data
        let listItem = response["listItem"] as? [String: Any]
        let fields = listItem?["fields"] as? [String: Any]
        
        print("List item fields:", fields ?? "No fields found")
        
        // Parse assessment status with better error handling
        let assessmentStatus = fields?["AssessmentStatus"] as? String ?? "pending"
        let assessorFeedback = fields?["AssessorFeedback"] as? String
        let assessorName = fields?["AssessorName"] as? String
        let modifiedDate = response["lastModifiedDateTime"] as? String
        
        return EvidenceMetadata(
            id: response["id"] as? String,
            name: response["name"] as? String,
            webUrl: response["webUrl"] as? String,
            downloadUrl: response["@microsoft.graph.downloadUrl"] as? String,
            createdDateTime: (response["createdDateTime"] as? String).flatMap { ISO8601DateFormatter().date(from: $0) },
            lastModifiedDateTime: modifiedDate.flatMap { ISO8601DateFormatter().date(from: $0) },
            size: response["size"] as? Int,
            mimeType: (response["file"] as? [String: Any])?["mimeType"] as? String,
            assessmentStatus: Evidence.AssessmentStatus(rawValue: assessmentStatus.lowercased()) ?? .pending,
            assessorFeedback: assessorFeedback,
            assessorName: assessorName,
            assessmentDate: modifiedDate.flatMap { ISO8601DateFormatter().date(from: $0) }
        )
    }
    
    private func getDrives() async throws -> [[String: Any]] {
        let drivesUrl = "\(graphEndpoint)/drives"
        var request = URLRequest(url: URL(string: drivesUrl)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let drives = json["value"] as? [[String: Any]] else {
            throw EvidenceError.uploadFailed("Failed to get drives")
        }
        
        return drives
    }
    
    private func verifyUpload(url: String) async throws {
        print("\n=== Verifying Upload ===")
        
        // Extract the drive ID and item ID from the upload URL
        guard let driveId = url.components(separatedBy: "/drives/").last?.components(separatedBy: "/").first,
              let itemId = url.components(separatedBy: "/items/").last?.components(separatedBy: "/").first else {
            throw EvidenceError.uploadFailed("Could not parse upload URL")
        }
        
        // Construct Graph API verification URL
        let verificationUrl = "\(graphEndpoint)/drives/\(driveId)/items/\(itemId)"
        
        print("Verification URL: \(verificationUrl)")
        
        var request = URLRequest(url: URL(string: verificationUrl)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw EvidenceError.uploadFailed("Invalid response during verification")
            }
            
            print("Verification response status: \(httpResponse.statusCode)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Verification response: \(responseString)")
            }
            
            guard httpResponse.statusCode == 200 else {
                if let error = try? JSONDecoder().decode(SharePointError.self, from: data) {
                    throw EvidenceError.uploadFailed("Verification failed: \(error.error.message)")
                }
                throw EvidenceError.uploadFailed("Verification failed with status \(httpResponse.statusCode)")
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("""
                ✅ File verified in SharePoint:
                Name: \(json["name"] as? String ?? "unknown")
                Size: \(json["size"] as? Int ?? 0) bytes
                Web URL: \(json["webUrl"] as? String ?? "unknown")
                """)
            } else {
                throw EvidenceError.uploadFailed("Could not parse file metadata")
            }
        } catch {
            print("❌ Verification failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func getVerifiedUrl(from uploadUrl: String) async throws -> String {
        // Extract IDs from upload URL
        guard let driveId = uploadUrl.components(separatedBy: "/drives/").last?.components(separatedBy: "/").first,
              let itemId = uploadUrl.components(separatedBy: "/items/").last?.components(separatedBy: "/").first else {
            throw EvidenceError.uploadFailed("Could not parse upload URL")
        }
        
        // Get verified URL from Graph API
        let verificationUrl = "\(graphEndpoint)/drives/\(driveId)/items/\(itemId)"
        let request = URLRequest(url: URL(string: verificationUrl)!)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let webUrl = json["webUrl"] as? String {
            return webUrl
        }
        
        throw EvidenceError.uploadFailed("Could not get verified URL")
    }
    
    private func buildFileEndpoint(drivePath: String, relativePath: String) -> String {
        // First normalize any backslashes to forward slashes
        let normalizedPath = relativePath.replacingOccurrences(of: "\\", with: "/")
        
        // Split path into components and encode each one
        let encodedComponents = normalizedPath
            .components(separatedBy: "/")
            .map { component in 
                return component.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? component
            }
        
        // Rejoin with encoded forward slashes
        let encodedPath = encodedComponents.joined(separator: "/")
        
        return "\(graphEndpoint)/\(drivePath)/root:/\(encodedPath)"
    }
    
    private func fetchFileMetadata(driveId: String, relativePath: String) async throws -> EvidenceMetadata {
        // Try first with forward slashes
        let endpoint = buildFileEndpoint(drivePath: "drives/\(driveId)", relativePath: relativePath)
        
        do {
            return try await fetchMetadataFromEndpoint(endpoint)
        } catch {
            // If forward slashes fail, try with backslashes
            let backslashPath = relativePath.replacingOccurrences(of: "/", with: "\\")
            let alternateEndpoint = buildFileEndpoint(drivePath: "drives/\(driveId)", relativePath: backslashPath)
            
            do {
                return try await fetchMetadataFromEndpoint(alternateEndpoint)
            } catch {
                throw EvidenceError.uploadFailed("File metadata fetch failed: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchMetadataFromEndpoint(_ endpoint: String) async throws -> EvidenceMetadata {
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EvidenceError.uploadFailed("Invalid response type")
        }
        
        if httpResponse.statusCode == 404 {
            throw EvidenceError.uploadFailed("The resource could not be found")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw EvidenceError.uploadFailed("HTTP \(httpResponse.statusCode)")
        }
        
        // Parse the SharePoint response
        let metadata = try JSONDecoder().decode(EvidenceMetadata.self, from: data)
        
        // After getting the file metadata, fetch the list item properties
        let listItemEndpoint = "\(endpoint)?expand=listItem"
        request = URLRequest(url: URL(string: listItemEndpoint)!)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let (listData, listResponse) = try await URLSession.shared.data(for: request)
        
        guard let httpListResponse = listResponse as? HTTPURLResponse else {
            throw EvidenceError.uploadFailed("Invalid list item response type")
        }
        
        guard httpListResponse.statusCode == 200 else {
            throw EvidenceError.uploadFailed("List item HTTP \(httpListResponse.statusCode)")
        }
        
        // Parse the list item response
        struct ListItemResponse: Codable {
            let listItem: ListItem
            
            struct ListItem: Codable {
                let fields: Fields
                
                struct Fields: Codable {
                    let assessmentStatus: String?
                    let assessorFeedback: String?
                    let assessorName: String?
                    let assessmentDate: String?
                    
                    enum CodingKeys: String, CodingKey {
                        case assessmentStatus = "AssessmentStatus"
                        case assessorFeedback = "AssessorFeedback"
                        case assessorName = "AssessorName"
                        case assessmentDate = "AssessmentDate"
                    }
                }
            }
        }
        
        let listItemData = try JSONDecoder().decode(ListItemResponse.self, from: listData)
        
        // Map the status string to Evidence.AssessmentStatus enum
        let status: Evidence.AssessmentStatus
        if let statusStr = listItemData.listItem.fields.assessmentStatus {
            status = Evidence.AssessmentStatus(rawValue: statusStr.lowercased()) ?? .pending
        } else {
            status = .pending
        }
        
        // Parse the date if present
        let dateFormatter = ISO8601DateFormatter()
        let assessmentDate = listItemData.listItem.fields.assessmentDate.flatMap { dateFormatter.date(from: $0) }
        
        return EvidenceMetadata(
            id: metadata.id,
            name: metadata.name,
            webUrl: metadata.webUrl,
            downloadUrl: metadata.downloadUrl,
            createdDateTime: metadata.createdDateTime,
            lastModifiedDateTime: metadata.lastModifiedDateTime,
            size: metadata.size,
            mimeType: metadata.mimeType,
            assessmentStatus: status,
            assessorFeedback: listItemData.listItem.fields.assessorFeedback,
            assessorName: listItemData.listItem.fields.assessorName,
            assessmentDate: assessmentDate
        )
    }
    
    // Add this structure to parse SharePoint properties
    private struct SharePointProperties: Codable {
        let assessmentStatus: Evidence.AssessmentStatus?
        let assessorFeedback: String?
        let assessorName: String?
        let assessmentDate: Date?
        
        enum CodingKeys: String, CodingKey {
            case assessmentStatus = "AssessmentStatus"
            case assessorFeedback = "AssessorFeedback"
            case assessorName = "AssessorName"
            case assessmentDate = "AssessmentDate"
        }
    }
    
    func fetchEvidenceMetadata(for evidence: Evidence) async throws -> EvidenceMetadata {
        guard let sharePointUrl = evidence.sharePointUrl else {
            throw EvidenceError.invalidURL
        }
        
        print("\n=== Fetching Evidence Metadata ===")
        print("URL:", sharePointUrl)
        
        // Extract the relative file path from the SharePoint URL
        let relativePath = sharePointUrl
            .replacingOccurrences(of: "https://wrightspark625.sharepoint.com/sites/EWANVQLevel3ElectroTechnical/Shared%20Documents/", with: "")
            .removingPercentEncoding ?? ""
        
        // Get site details first
        let siteEndpoint = "https://graph.microsoft.com/v1.0/sites/wrightspark625.sharepoint.com:/sites/EWANVQLevel3ElectroTechnical"
        
        print("Fetching site details...")
        guard let siteDetails = try await makeGraphRequest(siteEndpoint),
              let siteId = siteDetails["id"] as? String else {
            throw TeamsError.invalidResponse
        }
        
        // Get the drive ID using the site ID
        let driveEndpoint = "https://graph.microsoft.com/v1.0/sites/\(siteId)/drives"
        print("Fetching drive details...")
        
        guard let drivesResponse = try await makeGraphRequest(driveEndpoint),
              let drives = drivesResponse["value"] as? [[String: Any]],
              let documentsDrive = drives.first(where: { ($0["name"] as? String) == "Documents" }),
              let driveId = documentsDrive["id"] as? String else {
            throw TeamsError.invalidResponse
        }
        
        // Use the Graph API to get file metadata with expanded list item
        let encodedPath = relativePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? relativePath
        let fileEndpoint = "https://graph.microsoft.com/v1.0/drives/\(driveId)/root:/\(encodedPath)" + 
            "?expand=listItem($select=fields,id)" +
            "&$select=id,name,webUrl,createdDateTime,lastModifiedDateTime,size,file,@microsoft.graph.downloadUrl"
        
        print("File endpoint:", fileEndpoint)
        guard let fileMetadata = try await makeGraphRequest(fileEndpoint) else {
            throw TeamsError.metadataFetchFailed
        }
        
        return try await parseFileMetadata(from: JSONSerialization.data(withJSONObject: fileMetadata), siteId: siteId)
    }
    
    // Keep existing Graph API method as fallback
    private func fetchMetadataViaGraph(for evidence: Evidence) async throws -> EvidenceMetadata {
        // Existing implementation remains unchanged
        return try await fetchEvidenceMetadata(from: evidence.sharePointUrl ?? "")
    }
    
    // Add SharePoint REST API response structure
    private func updateSharePointListItem(for evidence: Evidence, status: Evidence.AssessmentStatus, feedback: String?) async throws {
        print("\n=== Updating SharePoint List Item ===")
        
        guard let sharePointUrl = evidence.sharePointUrl,
              let url = URL(string: sharePointUrl) else {
            throw EvidenceError.invalidURL
        }
        
        let siteUrl = "https://wrightspark625.sharepoint.com/sites/EWANVQLevel3ElectroTechnical"
        let getItemEndpoint = "\(siteUrl)/_api/web/lists/getbytitle('Evidence')/items"
        let filter = "?$filter=FileLeafRef eq '\(url.lastPathComponent)'"
        
        var request = URLRequest(url: URL(string: "\(getItemEndpoint)\(filter)")!)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json;odata=verbose", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let spResponse = try? JSONDecoder().decode(SharePointResponse.self, from: data),
              let item = spResponse.d.results.first,
              let itemId = item.Id else {
            throw EvidenceError.invalidMetadata
        }
        
        // Update the item
        let updateEndpoint = "\(siteUrl)/_api/web/lists/getbytitle('Evidence')/items(\(itemId))"
        
        var updateRequest = URLRequest(url: URL(string: updateEndpoint)!)
        updateRequest.httpMethod = "POST"
        updateRequest.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        updateRequest.setValue("application/json;odata=verbose", forHTTPHeaderField: "Content-Type")
        updateRequest.setValue("application/json;odata=verbose", forHTTPHeaderField: "Accept")
        updateRequest.setValue("MERGE", forHTTPHeaderField: "X-HTTP-Method")
        updateRequest.setValue("*", forHTTPHeaderField: "If-Match")
        
        let updateBody: [String: Any] = [
            "__metadata": ["type": "SP.Data.EvidenceListItem"],
            "AssessmentStatus": status.rawValue,
            "AssessorFeedback": feedback ?? ""
        ]
        
        updateRequest.httpBody = try JSONSerialization.data(withJSONObject: updateBody)
        
        let (updateData, updateResponse) = try await URLSession.shared.data(for: updateRequest)
        
        guard let updateHttpResponse = updateResponse as? HTTPURLResponse,
              updateHttpResponse.statusCode == 204 else {
            if let errorString = String(data: updateData, encoding: .utf8) {
                print("❌ Update failed: \(errorString)")
            }
            throw EvidenceError.uploadFailed("Failed to update SharePoint item")
        }
        
        print("✅ Successfully updated SharePoint list item")
    }
    
    func refreshEvidenceMetadata(for evidence: Evidence) async throws {
        guard let sharePointUrl = evidence.sharePointUrl else {
            throw EvidenceError.invalidURL
        }
        
        print("Fetching fresh metadata for:", sharePointUrl)
        
        let metadata = try await fetchEvidenceMetadata(for: evidence)
        
        await MainActor.run {
            if let status = metadata.assessmentStatus {
                evidence.assessmentStatus = status
            }
            evidence.assessorFeedback = metadata.assessorFeedback
            evidence.assessorName = metadata.assessorName
            evidence.assessmentDate = metadata.assessmentDate
        }
    }
    
    func fetchMetadataDirectly(_ path: String) async throws -> EvidenceMetadata {
        print("\n=== Fetching Evidence Metadata ===")
        print("URL:", path)
        
        // Extract the server-relative URL
        let serverRelativeUrl = path
            .replacingOccurrences(of: "https://wrightspark625.sharepoint.com", with: "")
            .removingPercentEncoding ?? ""
        
        // Construct the SharePoint REST API endpoint
        let siteUrl = "https://wrightspark625.sharepoint.com/sites/EWANVQLevel3ElectroTechnical"
        let encodedPath = serverRelativeUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Try to get the list item directly using the file's server-relative URL
        let endpoint = "\(siteUrl)/_api/web/getfilebyserverrelativeurl('\(encodedPath)')/listItemAllFields"
        
        print("SharePoint endpoint:", endpoint)
        
        guard let requestUrl = URL(string: endpoint) else {
            throw TeamsError.invalidURL
        }
        
        var request = URLRequest(url: requestUrl)
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json;odata=verbose", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TeamsError.invalidResponse
        }
        
        print("SharePoint response status:", httpResponse.statusCode)
        print("SharePoint response:", String(data: data, encoding: .utf8) ?? "")
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? [String: Any],
               let value = message["value"] as? String {
                print("SharePoint error:", value)
                throw TeamsError.invalidResponse
            }
            throw TeamsError.invalidResponse
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let fields = json["d"] as? [String: Any] else {
            throw TeamsError.invalidResponse
        }
        
        print("SharePoint fields:", fields)
        
        // Map the SharePoint response to EvidenceMetadata
        let status = (fields["Assessment_x0020_Status"] as? String)?.lowercased() ?? "pending"
        let assessmentStatus = Evidence.AssessmentStatus(rawValue: status) ?? .pending
        
        return EvidenceMetadata(
            id: String(describing: fields["ID"] ?? ""),
            name: fields["FileLeafRef"] as? String ?? path.components(separatedBy: "/").last,
            webUrl: path,
            downloadUrl: path,
            createdDateTime: ISO8601DateFormatter().date(from: fields["Created"] as? String ?? ""),
            lastModifiedDateTime: ISO8601DateFormatter().date(from: fields["Modified"] as? String ?? ""),
            size: nil,
            mimeType: nil,
            assessmentStatus: assessmentStatus,
            assessorFeedback: fields["Assessor_x0020_Feedback"] as? String,
            assessorName: fields["Assessor_x0020_Name"] as? String,
            assessmentDate: ISO8601DateFormatter().date(from: fields["Modified"] as? String ?? "")
        )
    }
    
    private func makeGraphRequest(_ endpoint: String) async throws -> [String: Any]? {
        guard let accessToken = self.accessToken else {
            throw TeamsError.notAuthenticated
        }
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TeamsError.invalidResponse
        }
        
        return try JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
    
    enum TeamsError: Error {
        case notAuthenticated
        case invalidURL
        case invalidResponse
        case metadataFetchFailed
    }
}

// Helper extension for SHA256
extension Data {
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash)
    }
}

// Add this structure to parse SharePoint errors
private struct SharePointError: Codable {
    struct ErrorDetails: Codable {
        let code: String
        let message: String
    }
    let error: ErrorDetails
}
