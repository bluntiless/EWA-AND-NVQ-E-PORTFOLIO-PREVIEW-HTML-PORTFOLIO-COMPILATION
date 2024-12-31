import SwiftUI
import PDFKit
import AVKit
import QuickLook

struct EvidencePreviewView: View {
    let evidence: Evidence
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
        }
    }
    
    private func loadPreviewImage() {
        guard case .photo = evidence.type else {
            print("📸 Preview: Not a photo type")
            isLoading = false
            return
        }
        
        // Try to get local file using existing resolvedFileURL
        if let localUrl = evidence.resolvedFileURL {
            print("📸 Preview: Loading from local file: \(localUrl.path)")
            
            // Ensure we can access the file
            if localUrl.startAccessingSecurityScopedResource() {
                defer { localUrl.stopAccessingSecurityScopedResource() }
                
                if let image = UIImage(contentsOfFile: localUrl.path) {
                    self.previewImage = image
                    self.isLoading = false
                    return
                }
            }
            
            print("📸 Preview: Failed to load from local file")
        }
        
        print("📸 Preview: No local file available")
        isLoading = false
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
