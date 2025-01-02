import SwiftUI
import PDFKit
import AVKit
import UIKit
import QuickLook

struct EvidenceRow: View {
    let evidence: Evidence
    @EnvironmentObject var evidenceManager: EvidenceManager
    
    // Add status icon computed property
    private var statusIcon: some View {
        Image(systemName: evidence.statusDisplayInfo.icon)
            .foregroundColor(evidence.statusDisplayInfo.color)
    }
    
    var body: some View {
        NavigationLink(destination: EvidenceDetailView(evidence: evidence)) {
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
            .onAppear {
                // Refresh metadata when row appears
                if evidence.isUploaded {
                    Task {
                        try? await evidenceManager.refreshEvidenceStatus()
                    }
                }
            }
        }
    }
    
    var statusView: some View {
        HStack {
            statusIcon
            if evidence.isLocallyUploaded {
                Text(evidence.assessmentStatus.rawValue.capitalized)
                    .foregroundColor(evidence.statusDisplayInfo.color)
            }
        }
    }
    
    private func getSharePointPath() -> String {
        return SharePointPathFormatter.formatPath(unitCode: evidence.unitCode, criteriaCode: evidence.criteriaCode)
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
                .frame(width: 44, height: 44)
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
        loadingTask?.cancel()
        loadingTask = Task {
            do {
                // Try local file first
                if let localURL = evidence.resolvedFileURL {
                    print("📸 Loading thumbnail from local URL: \(localURL)")
                    
                    if let image = UIImage(contentsOfFile: localURL.path) {
                        let size = CGSize(width: 88, height: 88)
                        if let thumbnail = await image.byPreparingThumbnail(ofSize: size) {
                            await MainActor.run {
                                self.thumbnailImage = thumbnail
                                self.isLoading = false
                            }
                            return
                        }
                    }
                }
                
                // Try bookmark data if available
                if let bookmarkData = evidence.bookmarkData {
                    var isStale = false
                    if let resolvedURL = try? URL(resolvingBookmarkData: bookmarkData, 
                                                bookmarkDataIsStale: &isStale) {
                        
                        if resolvedURL.startAccessingSecurityScopedResource() {
                            defer { resolvedURL.stopAccessingSecurityScopedResource() }
                            
                            if let image = UIImage(contentsOfFile: resolvedURL.path) {
                                let size = CGSize(width: 88, height: 88)
                                if let thumbnail = await image.byPreparingThumbnail(ofSize: size) {
                                    await MainActor.run {
                                        self.thumbnailImage = thumbnail
                                        self.isLoading = false
                                    }
                                    return
                                }
                            }
                        }
                    }
                }
                
                // If all attempts fail, show placeholder
                await MainActor.run {
                    self.isLoading = false
                }
                
            } catch {
                print("📸 Error loading thumbnail: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
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
