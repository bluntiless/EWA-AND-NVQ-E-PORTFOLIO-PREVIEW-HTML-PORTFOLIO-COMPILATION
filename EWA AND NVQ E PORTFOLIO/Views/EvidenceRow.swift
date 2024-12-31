import SwiftUI
import PDFKit
import AVKit
import UIKit
import QuickLook

struct EvidenceRow: View {
    let evidence: Evidence
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Enhanced thumbnail preview
                ThumbnailView(evidence: evidence)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 0.5)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(evidence.title)
                        .font(.headline)
                    
                    // Unit and criteria reference
                    Text("Unit \(evidence.unitCode) - \(evidence.criteriaCode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // New status badge
                StatusBadge(evidence: evidence)
            }
            
            // Description
            if !evidence.description.isEmpty {
                Text(evidence.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Assessment Info
            if evidence.hasAssessment {
                AssessmentInfoView(evidence: evidence)
            }
            
            // Upload Date
            Text("Uploaded \(evidence.dateUploaded.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

// Status Badge Component
struct StatusBadge: View {
    let evidence: Evidence
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: evidence.statusDisplayInfo.icon)
            Text(evidence.statusDisplayInfo.text)
                .font(.caption.bold())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(evidence.statusDisplayInfo.color.opacity(0.2))
        .foregroundColor(evidence.statusDisplayInfo.color)
        .cornerRadius(8)
        .accessibilityLabel(evidence.currentStatus.accessibilityDescription)
    }
}

// Assessment Info Component
struct AssessmentInfoView: View {
    let evidence: Evidence
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let date = evidence.formattedAssessmentDate {
                Text("Assessed \(date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let assessor = evidence.assessorName {
                Text("Assessor: \(assessor)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if evidence.hasFeedback {
                Text(evidence.feedbackSummary)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

// Separate thumbnail view component
struct ThumbnailView: View {
    let evidence: Evidence
    @State private var thumbnailImage: UIImage?
    @State private var isLoading = true
    @State private var loadingTask: Task<Void, Never>?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.7)
                    .onAppear {
                        if evidence.resolvedFileURL == nil {
                            isLoading = false
                        }
                    }
            } else {
                Group {
                    switch evidence.type {
                    case .photo:
                        if let image = thumbnailImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } else {
                            Image(systemName: "photo")
                                .imageScale(.large)
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                        }
                    case .video:
                        ZStack {
                            if let image = thumbnailImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                            } else {
                                Image(systemName: "video.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                    .frame(width: 24, height: 24)
                            }
                            if thumbnailImage != nil {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                            }
                        }
                    case .document, .audio:
                        Image(systemName: evidence.type == .document ? "doc.fill" : "waveform")
                            .font(.system(size: 24))
                            .foregroundColor(evidence.type == .document ? .blue : .purple)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            loadThumbnail()
        }
        .onDisappear {
            loadingTask?.cancel()
        }
    }
    
    private func loadThumbnail() {
        guard let url = evidence.resolvedFileURL else {
            print("📸 No URL available for thumbnail")
            isLoading = false
            return
        }
        
        print("📸 Loading thumbnail from: \(url)")
        
        guard url.startAccessingSecurityScopedResource() else {
            print("📸 Failed to access security scoped resource")
            isLoading = false
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
            print("📸 Stopped accessing security scoped resource")
        }
        
        loadingTask?.cancel()
        loadingTask = Task {
            do {
                switch evidence.type {
                case .photo:
                    print("📸 Loading photo thumbnail")
                    if let image = UIImage(contentsOfFile: url.path) {
                        print("📸 Successfully loaded image")
                        let size = CGSize(width: 88, height: 88)
                        if let thumbnail = await image.byPreparingThumbnail(ofSize: size) {
                            print("📸 Successfully generated thumbnail")
                            await MainActor.run {
                                self.thumbnailImage = thumbnail
                                self.isLoading = false
                            }
                        } else {
                            print("📸 Failed to generate thumbnail")
                            await MainActor.run { self.isLoading = false }
                        }
                    } else {
                        print("📸 Failed to load image from path")
                        await MainActor.run { self.isLoading = false }
                    }
                    
                case .video:
                    let asset = AVAsset(url: url)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    imageGenerator.appliesPreferredTrackTransform = true
                    imageGenerator.maximumSize = CGSize(width: 88, height: 88)
                    
                    do {
                        let cgImage = try await withTimeout(seconds: 3.0) {
                            try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                        }
                        let image = UIImage(cgImage: cgImage)
                        if let thumbnail = await image.byPreparingThumbnail(ofSize: CGSize(width: 88, height: 88)) {
                            await MainActor.run {
                                self.thumbnailImage = thumbnail
                                self.isLoading = false
                            }
                        }
                    } catch {
                        print("Video thumbnail generation failed: \(error)")
                        await MainActor.run { self.isLoading = false }
                    }
                    
                default:
                    await MainActor.run { self.isLoading = false }
                }
            } catch {
                print("Error loading thumbnail: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(for: .seconds(seconds))
                throw CancellationError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

#Preview {
    List {
        // Preview with photo
        EvidenceRow(evidence: Evidence(
            criteriaCode: "1.1",
            unitCode: "UNIT1",
            type: .photo,
            title: "Sample Photo Evidence",
            description: "Test description for photo",
            associatedCriteria: ["1.1"],
            criteriaDescription: "Test criteria",
            assessmentStatus: .approved,
            assessorFeedback: "Great work!",
            assessorName: "John Doe",
            assessmentDate: Date()
        ))
        
        // Preview with document
        EvidenceRow(evidence: Evidence(
            criteriaCode: "1.2",
            unitCode: "UNIT1",
            type: .document,
            title: "Sample Document",
            description: "Test description for document",
            associatedCriteria: ["1.2"],
            criteriaDescription: "Test criteria",
            assessmentStatus: .pending,
            assessorFeedback: nil,
            assessorName: nil,
            assessmentDate: nil
        ))
        
        // Preview with video
        EvidenceRow(evidence: Evidence(
            criteriaCode: "1.3",
            unitCode: "UNIT1",
            type: .video,
            title: "Sample Video Evidence",
            description: "Test description for video",
            associatedCriteria: ["1.3"],
            criteriaDescription: "Test criteria",
            assessmentStatus: .needsRevision,
            assessorFeedback: "Please resubmit with better lighting",
            assessorName: "Jane Smith",
            assessmentDate: Date()
        ))
    }
    .padding()
}
