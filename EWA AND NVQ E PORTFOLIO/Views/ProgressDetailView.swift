import SwiftUI

// Helper view for displaying evidence items
private struct EvidenceItemView: View {
    let evidence: Evidence
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .imageScale(.small)
            
            Text(evidence.title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer()
            
            Text(evidence.formattedAssessmentDate ?? "")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// Helper view for progress bar and stats
private struct ProgressStatsView: View {
    let progress: Double
    let approvedCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
                .animation(.easeInOut, value: progress)
                .tint(.blue)
            
            HStack {
                Text("\(Int(progress * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(approvedCount) Approved")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
    }
}

// Helper view for recent evidence list
private struct RecentEvidenceView: View {
    let evidence: [Evidence]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(evidence) { item in
                EvidenceItemView(evidence: item)
            }
        }
        .padding(.top, 4)
    }
}

// Helper view for unit progress
private struct UnitProgressView: View {
    let unit: Unit
    @ObservedObject var evidenceManager: EvidenceManager
    
    private var approvedCount: Int {
        evidenceManager.getApprovedEvidenceCount(for: unit.code)
    }
    
    private var recentEvidence: [Evidence]? {
        evidenceManager.getRecentApprovedEvidence(for: unit.code)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(unit.title)
                .font(.headline)
            
            ProgressStatsView(
                progress: unit.progress,
                approvedCount: approvedCount
            )
            
            if let recentEvidence = recentEvidence {
                RecentEvidenceView(evidence: recentEvidence)
            }
        }
        .padding(.vertical, 4)
    }
}

// Helper view for qualification section
private struct QualificationSectionView: View {
    let qualification: Qualification
    @ObservedObject var evidenceManager: EvidenceManager
    
    var body: some View {
        Section(header: Text(qualification.title)) {
            ForEach(qualification.units) { unit in
                UnitProgressView(
                    unit: unit,
                    evidenceManager: evidenceManager
                )
            }
        }
    }
}

struct ProgressDetailView: View {
    @StateObject var evidenceManager: EvidenceManager
    @StateObject var qualificationStore: QualificationStore
    
    var body: some View {
        List {
            ForEach(qualificationStore.qualifications) { qualification in
                QualificationSectionView(
                    qualification: qualification,
                    evidenceManager: evidenceManager
                )
            }
        }
        .navigationTitle("Progress")
        .animation(.easeInOut, value: qualificationStore.qualifications.map { $0.id })
    }
}

#Preview {
    NavigationView {
        ProgressDetailView(
            evidenceManager: EvidenceManager(),
            qualificationStore: QualificationStore()
        )
    }
} 