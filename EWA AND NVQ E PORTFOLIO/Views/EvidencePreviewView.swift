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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
                        if let sharePointUrl = evidence.sharePointUrl {
                            VideoPreviewView(evidence: evidence, evidenceManager: evidenceManager)
                                .frame(height: 300)
                                .cornerRadius(12)
                        }
                    case .document:
                        if let sharePointUrl = evidence.sharePointUrl {
                            DocumentPreviewView(evidence: evidence, evidenceManager: evidenceManager)
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
                    
                    // Update criteria display
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Associated Criteria:")
                            .font(.headline)
                        Text(evidence.displayCriteriaCode)
                            .padding(.horizontal)
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
        }
        .onAppear {
            viewModel.setEvidenceManager(evidenceManager)
            loadPreviewImage()
        }
        .onChange(of: viewModel.assessmentStatus) { _ in
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
    private var evidenceManager: EvidenceManager?
    private var isUpdating = false  // Add guard against recursive updates
    
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
    
    func setEvidenceManager(_ manager: EvidenceManager) {
        self.evidenceManager = manager
    }
    
    func refreshMetadata() async {
        guard !isUpdating else { return }  // Prevent recursive updates
        isUpdating = true
        defer { isUpdating = false }
        
        do {
            let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(for: evidence)
            
            await MainActor.run {
                if let status = metadata.assessmentStatus {
                    // Update view model
                    self.assessmentStatus = status
                    self.assessorFeedback = metadata.assessorFeedback
                    self.assessorName = metadata.assessorName
                    self.assessmentDate = metadata.assessmentDate
                    
                    // Create updated evidence preserving hidden state
                    var updatedEvidence = evidence
                    let wasHidden = evidence.isHidden
                    updatedEvidence.assessmentStatus = status
                    updatedEvidence.assessorFeedback = metadata.assessorFeedback
                    updatedEvidence.assessorName = metadata.assessorName
                    updatedEvidence.assessmentDate = metadata.assessmentDate
                    updatedEvidence.isHidden = wasHidden  // Explicitly preserve hidden state
                    
                    // Single update to evidence manager
                    Task {
                        try? await evidenceManager?.updateEvidence(updatedEvidence)
                    }
                }
            }
        } catch {
            print("❌ Error refreshing metadata: \(error)")
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

// Add this new view struct
struct VideoPreviewView: View {
    let evidence: Evidence
    let evidenceManager: EvidenceManager
    @State private var player: AVPlayer?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player)
            }
            
            if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            loadVideo()
        }
    }
    
    private func loadVideo() {
        Task {
            do {
                print("🎥 Starting video load...")
                
                // Attempt to construct the correct URL for the SharePoint file
                guard let sharePointUrl = evidence.sharePointUrl?.replacingOccurrences(of: "\\", with: "/"),
                      let url = URL(string: sharePointUrl) else {
                    print("Invalid URL format")
                    return
                }
                
                print("🎬 Trying SharePoint video URL: \(sharePointUrl)")
                
                // Fetch metadata using the corrected URL
                let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(for: evidence)
                
                // First try download URL if available
                if let downloadUrl = metadata.downloadUrl,
                   let downloadURL = URL(string: downloadUrl) {
                    print("📥 Using direct download URL: \(downloadUrl)")
                    await MainActor.run {
                        self.player = AVPlayer(url: downloadURL)
                        self.isLoading = false
                    }
                    return
                }
                
                // Fallback to webUrl if download URL not available
                if let webUrl = metadata.webUrl,
                   let videoURL = URL(string: webUrl) {
                    print("📥 Using web URL: \(webUrl)")
                    // Use TeamsManager to make authenticated request
                    let (_, response) = try await TeamsManager.shared.makeAuthenticatedRequest(url: webUrl)
                    if let httpResponse = response as? HTTPURLResponse,
                       let streamUrl = httpResponse.url {
                        await MainActor.run {
                            self.player = AVPlayer(url: streamUrl)
                            self.isLoading = false
                        }
                    }
                } else {
                    print("❌ No valid URL available for video")
                }
            } catch {
                print("❌ Failed to load video: \(error)")
                isLoading = false
            }
        }
    }
}

// Add this new view struct
struct DocumentPreviewView: View {
    let evidence: Evidence
    let evidenceManager: EvidenceManager
    @State private var pdfUrl: URL?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let url = pdfUrl {
                PDFPreview(url: url)
            }
            
            if isLoading {
                ProgressView()
            }
        }
        .frame(height: 300)
        .cornerRadius(12)
        .onAppear {
            loadDocument()
        }
    }
    
    private func loadDocument() {
        Task {
            do {
                print("📄 Starting document load...")
                
                // Attempt to construct the correct URL for the SharePoint file
                guard let sharePointUrl = evidence.sharePointUrl?.replacingOccurrences(of: "\\", with: "/") else {
                    print("Invalid URL format")
                    return
                }
                
                print("📑 Trying SharePoint document URL: \(sharePointUrl)")
                
                // Fetch metadata using the corrected URL
                let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(for: evidence)
                
                // First try download URL if available
                if let downloadUrl = metadata.downloadUrl {
                    print("📥 Using direct download URL: \(downloadUrl)")
                    let (data, _) = try await TeamsManager.shared.makeAuthenticatedRequest(url: downloadUrl)
                    
                    // Save data to temporary file
                    let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
                    try data.write(to: tempUrl)
                    
                    await MainActor.run {
                        self.pdfUrl = tempUrl
                        self.isLoading = false
                    }
                    return
                }
                
                // Fallback to webUrl if download URL not available
                if let webUrl = metadata.webUrl {
                    print("📥 Using web URL: \(webUrl)")
                    let (data, _) = try await TeamsManager.shared.makeAuthenticatedRequest(url: webUrl)
                    
                    // Save data to temporary file
                    let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
                    try data.write(to: tempUrl)
                    
                    await MainActor.run {
                        self.pdfUrl = tempUrl
                        self.isLoading = false
                    }
                } else {
                    print("❌ No valid URL available for document")
                }
            } catch {
                print("❌ Failed to load document: \(error)")
                isLoading = false
            }
        }
    }
} 
