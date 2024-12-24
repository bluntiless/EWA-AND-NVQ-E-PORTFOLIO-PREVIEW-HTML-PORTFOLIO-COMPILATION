import SwiftUI
import PDFKit
import AVKit

struct EvidencePreviewView: View {
    var evidence: Evidence
    @State private var selectedURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if let url = selectedURL {
                switch evidence.type {
                case .document:
                    PDFPreview(url: url)
                case .photo:
                    ImagePreview(url: url)
                case .video:
                    VideoPreview(url: url)
                }
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                var mutableEvidence = evidence
                selectedURL = try mutableEvidence.resolvedFileURL
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
} 
