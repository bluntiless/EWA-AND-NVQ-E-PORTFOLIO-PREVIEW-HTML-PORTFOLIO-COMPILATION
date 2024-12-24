import Foundation
import MSAL
import UIKit
import AuthenticationServices
import CommonCrypto

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
            let updatedEvidence = try await uploadToSharePoint(evidence: evidence)
            updatedItems.append(updatedEvidence)
        }
        
        return updatedItems
    }
    
    private func uploadToSharePoint(evidence: Evidence) async throws -> Evidence {
        print("\n=== Starting SharePoint Upload ===")
        
        var updatedEvidence = evidence
        
        // 1. Get and validate file URL
        let fileURL: URL
        do {
            guard let resolvedURL = try updatedEvidence.resolvedFileURL else {
                throw AppError.fileAccessError(NSError(domain: "", code: -1, 
                    userInfo: [NSLocalizedDescriptionKey: "Could not resolve file URL"]))
            }
            fileURL = resolvedURL
            print("✅ File URL resolved successfully")
        } catch {
            print("❌ Error accessing file URL: \(error)")
            throw error
        }
        
        // 2. Load and validate file data
        let fileData: Data
        do {
            try validateFile(fileURL)
            fileData = try Data(contentsOf: fileURL)
            print("✅ File validation passed")
            print("- Size: \(ByteCountFormatter.string(fromByteCount: Int64(fileData.count), countStyle: .file))")
        } catch {
            print("❌ File validation failed: \(error)")
            throw error
        }
        
        // 3. Create upload session
        let session = try await createUploadSession(for: updatedEvidence, fileURL: fileURL)
        updatedEvidence.setSharePointUrl(session.uploadUrl)
        print("✅ Upload session created")
        
        // 4. Upload file in chunks with progress tracking
        try await uploadFile(
            data: fileData,
            to: session.uploadUrl,
            onProgress: { progress in
                print("📤 Upload progress: \(Int(progress * 100))%")
                self.currentUpload = UploadProgress(
                    filename: fileURL.lastPathComponent,
                    progress: progress,
                    status: .uploading
                )
            }
        )
        
        // 5. Update evidence metadata
        updatedEvidence.setUploadDate(Date())
        print("✅ Upload completed successfully")
        
        return updatedEvidence
    }
    
    private func createUploadSession(for evidence: Evidence, fileURL: URL) async throws -> UploadSession {
        let fileName = fileURL.lastPathComponent
        
        // Include all associated criteria in the path
        let criteriaPath = evidence.associatedCriteria.isEmpty ? 
            evidence.criteriaCode.replacingOccurrences(of: ", ", with: "_") :
            evidence.associatedCriteria.joined(separator: "_")
        
        let safePath = "Evidence/\(evidence.unitCode)/\(criteriaPath)/\(fileName)"
            .replacingOccurrences(of: " ", with: "_")
        
        let siteId = "wrightspark625.sharepoint.com,77f748ac-6618-4f8d-ae7b-1e927fad2fea,f7a8aba3-0493-4888-8d22-00685d8072ae"
        let endpoint = "\(graphEndpoint)/sites/\(siteId)/drive/root:/\(safePath):/createUploadSession"
        
        guard let url = URL(string: endpoint) else {
            throw AppError.networkError(NSError(domain: "", code: -1))
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["item": ["@microsoft.graph.conflictBehavior": "rename"]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AppError.uploadFailed(NSError(domain: "", code: -1))
        }
        
        return try JSONDecoder().decode(UploadSession.self, from: data)
    }
    
    private func uploadFile(data: Data, to uploadUrl: String, onProgress: @escaping (Double) -> Void) async throws {
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
            onProgress(progress)
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
                    guard let presentingViewController = self.presentingViewController,
                          let webAuthPresenter = self.webAuthPresenter else {
                        print("❌ No presenting view controller or window")
                        continuation.resume(throwing: AppError.authenticationFailed)
                        return
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
