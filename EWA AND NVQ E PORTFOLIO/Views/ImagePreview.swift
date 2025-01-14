import SwiftUI

struct ImagePreview: View {
    let evidence: Evidence
    @ObservedObject var evidenceManager: EvidenceManager
    @State private var image: UIImage?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                VStack {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text(errorMessage ?? "Unable to load preview")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .task {
            await loadPreview()
        }
    }
    
    private func loadPreview() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let sharePointUrl = evidence.sharePointUrl else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No SharePoint URL"])
            }
            
            // Ensure we're authenticated
            try await TeamsManager.shared.authenticate()
            
            // First refresh metadata to get latest status
            let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
            
            // Update evidence status through EvidenceManager to ensure persistence
            await MainActor.run {
                var updatedEvidence = evidence
                updatedEvidence.updateAssessmentInfo(from: metadata)
                // Preserve hidden state
                updatedEvidence.isHidden = evidence.isHidden
                
                // Update through EvidenceManager to persist changes
                Task {
                    try? await evidenceManager.updateEvidence(updatedEvidence)
                }
            }
            
            // Try to get preview URL with fallbacks
            let url = try await getDownloadUrl(from: sharePointUrl, metadata: metadata)
            
            // Download and display the image
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = uiImage
                    self.isLoading = false
                }
            } else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
            }
        } catch {
            print("❌ Preview load failed:", error)
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Could not load preview.\nTap to open in SharePoint."
            }
        }
    }
    
    private func getDownloadUrl(from sharePointUrl: String, metadata: EvidenceMetadata? = nil) async throws -> URL {
        // Try multiple approaches to get the download URL
        do {
            // First try: Use provided metadata or fetch new
            let meta: EvidenceMetadata
            if let existingMetadata = metadata {
                meta = existingMetadata
            } else {
                meta = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
            }
            
            if let downloadUrl = meta.downloadUrl,
               let url = URL(string: downloadUrl) {
                print("✅ Using download URL from metadata")
                return url
            }
            
            // Second try: Use SharePoint web URL with rendering parameters
            if let webUrl = URL(string: sharePointUrl) {
                let renderUrl = webUrl.absoluteString + "?web=1"
                print("✅ Using web render URL")
                return URL(string: renderUrl)!
            }
            
            // Third try: Use original URL with direct access token
            if let originalUrl = URL(string: sharePointUrl) {
                print("✅ Using original URL")
                return originalUrl
            }
            
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not construct valid URL"])
        } catch {
            print("⚠️ URL fetch attempts failed, using fallback")
            // If all attempts fail, try using the original URL
            if let fallbackUrl = URL(string: sharePointUrl) {
                return fallbackUrl
            }
            throw error
        }
    }
} 