import SwiftUI

struct ProgressDetailView: View {
    let evidenceManager: EvidenceManager
    let qualificationStore: QualificationStore
    
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
    }
}

// Helper view for qualification section
private struct QualificationSectionView: View {
    let qualification: Qualification
    let evidenceManager: EvidenceManager
    
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

// Helper views for progress tracking
private struct UnitProgressView: View {
    let unit: Unit
    let evidenceManager: EvidenceManager
    
    private var approvedCount: Int {
        evidenceManager.getApprovedEvidenceCount(for: unit.code)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(unit.title)
                .font(.headline)
            ProgressView(value: unit.progress)
                .progressViewStyle(.linear)
            Text("\(approvedCount) Approved")
                .font(.caption)
        }
    }
} 