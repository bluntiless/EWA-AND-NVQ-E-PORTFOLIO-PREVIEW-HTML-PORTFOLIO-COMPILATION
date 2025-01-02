import SwiftUI
import UIKit
import Foundation

struct EvidenceDetailView: View {
    let evidence: Evidence
    @State private var displayImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Evidence Display
                Group {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else if let image = displayImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, minHeight: 200)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Evidence Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(evidence.title)
                        .font(.headline)
                    Text(evidence.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Assessment Info
                    if evidence.hasAssessment {
                        AssessmentInfoView(evidence: evidence)
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadFullImage()
        }
    }
    
    private func loadFullImage() {
        Task {
            do {
                print("🖼️ Starting image load...")
                
                // Try local file first (same as thumbnail approach)
                if let localPath = evidence.resolvedFileURL?.path {
                    print("📍 Trying local path: \(localPath)")
                    if let image = UIImage(contentsOfFile: localPath) {
                        print("✅ Loaded image from local path")
                        await MainActor.run {
                            self.displayImage = image
                            self.isLoading = false
                        }
                        return
                    }
                    print("⚠️ Failed to load from local path")
                }
                
                print("❌ Failed to load image")
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                print("🚫 Error loading image: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
} 