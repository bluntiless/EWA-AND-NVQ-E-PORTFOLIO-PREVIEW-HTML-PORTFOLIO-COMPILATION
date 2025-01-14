import SwiftUI
import PDFKit
import AVKit
import QuickLook

struct EvidencePreviewView: View {
    let evidence: Evidence
    @EnvironmentObject var evidenceManager: EvidenceManager
    @StateObject private var viewModel: EvidencePreviewViewModel
    @State private var previewImage: UIImage?
    @State private var isLoading = true
    @State private var isRefreshing = false
    
    init(evidence: Evidence) {
        self.evidence = evidence
        _viewModel = StateObject(wrappedValue: EvidencePreviewViewModel(evidence: evidence))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Evidence Preview Section
            Group {
                switch evidence.type {
                case .photo:
                    if isLoading {
                        ProgressView()
                    } else if let image = previewImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .frame(height: 200)
                    }
                case .video:
                    if let url = evidence.resolvedFileURL {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 300)
                            .cornerRadius(12)
                    }
                case .document:
                    if let url = evidence.resolvedFileURL {
                        PDFPreview(url: url)
                            .frame(height: 300)
                            .cornerRadius(12)
                    }
                case .audio:
                    if let url = evidence.resolvedFileURL {
                        AudioPlayerView(url: url)
                            .frame(height: 100)
                            .padding()
                    }
                }
            }
            .padding(.horizontal)
            
            // Assessment Details - Using ViewModel
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Assessment Status:")
                        .font(.headline)
                    Text(viewModel.assessmentStatus.displayName)
                        .foregroundColor(viewModel.assessmentStatus.color)
                        .bold()
                }
                
                if let feedback = viewModel.assessorFeedback, !feedback.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Assessor Feedback:")
                            .font(.headline)
                        Text(feedback)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                if let assessor = viewModel.assessorName {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Assessed by:")
                            .font(.headline)
                        Text(assessor)
                    }
                }
                
                if let date = viewModel.assessmentDate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Assessment Date:")
                            .font(.headline)
                        Text(date.formatted(date: .long, time: .shortened))
                    }
                }
                
                // Keep existing refresh functionality
                Button(action: {
                    Task {
                        isRefreshing = true
                        await viewModel.refreshMetadata()
                        isRefreshing = false
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh Status")
                    }
                    .foregroundColor(.blue)
                }
                .disabled(!viewModel.canRefresh || isRefreshing)
                .padding(.top)
            }
            .padding()
        }
        .onAppear {
            loadPreviewImage()
            Task {
                // Refresh status when preview opens
                try? await evidenceManager.updateEvidence(evidence)
            }
        }
        .onChange(of: viewModel.assessmentStatus) { newStatus in
            Task {
                // Refresh when status changes
                try? await evidenceManager.updateEvidence(evidence)
            }
        }
    }
    
    private func loadPreviewImage() {
        guard case .photo = evidence.type else {
            print("📸 Preview: Not a photo type")
            isLoading = false
            return
        }
        
        Task {
            do {
                print("🖼️ Starting preview image load...")
                
                // First try local file if available
                if let localUrl = evidence.resolvedFileURL {
                    print("📍 Trying local file: \(localUrl.path)")
                    if localUrl.startAccessingSecurityScopedResource() {
                        defer { localUrl.stopAccessingSecurityScopedResource() }
                        
                        if let image = UIImage(contentsOfFile: localUrl.path) {
                            print("✅ Loaded from local file")
                            await MainActor.run {
                                self.previewImage = image
                                self.isLoading = false
                            }
                            return
                        }
                    }
                    print("⚠️ Failed to load from local file")
                }
                
                // Try SharePoint URL
                if let sharePointUrl = evidence.sharePointUrl {
                    print("📸 Trying SharePoint URL: \(sharePointUrl)")
                    
                    // Get fresh metadata with download URL
                    let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(for: evidence)
                    
                    // Use TeamsManager to make the authenticated request
                    let urlToUse = metadata.downloadUrl ?? sharePointUrl
                    print("📥 Using URL: \(urlToUse)")
                    
                    // Let TeamsManager handle the authentication
                    let (data, response) = try await TeamsManager.shared.makeAuthenticatedRequest(url: urlToUse)
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        print("📡 Response status: \(httpResponse.statusCode)")
                    }
                    
                    if let image = UIImage(data: data) {
                        print("✅ Loaded from SharePoint")
                        await MainActor.run {
                            self.previewImage = image
                            self.isLoading = false
                        }
                        return
                    }
                    print("⚠️ Failed to load from SharePoint")
                }
                
                print("❌ Failed to load image from any source")
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                print("❌ Error loading image: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// Keep existing ViewModel
class EvidencePreviewViewModel: ObservableObject {
    private let evidence: Evidence
    
    @Published var assessmentStatus: Evidence.AssessmentStatus
    @Published var assessorFeedback: String?
    @Published var assessorName: String?
    @Published var assessmentDate: Date?
    
    var canRefresh: Bool {
        evidence.isUploaded
    }
    
    init(evidence: Evidence) {
        self.evidence = evidence
        self.assessmentStatus = evidence.assessmentStatus
        self.assessorFeedback = evidence.assessorFeedback
        self.assessorName = evidence.assessorName
        self.assessmentDate = evidence.assessmentDate
    }
    
    func refreshMetadata() async {
        do {
            try await TeamsManager.shared.refreshEvidenceMetadata(for: evidence)
            await MainActor.run {
                self.assessmentStatus = evidence.assessmentStatus
                self.assessorFeedback = evidence.assessorFeedback
                self.assessorName = evidence.assessorName
                self.assessmentDate = evidence.assessmentDate
            }
        } catch {
            print("Error refreshing metadata:", error)
        }
    }
}

// Simple Audio Player View
struct AudioPlayerView: View {
    let url: URL
    @State private var isPlaying = false
    
    var body: some View {
        HStack {
            Button(action: {
                isPlaying.toggle()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading) {
                Text("Audio Recording")
                    .font(.headline)
                Text(url.lastPathComponent)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 
