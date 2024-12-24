import SwiftUI

struct ProgressDetailView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @EnvironmentObject var qualificationStore: QualificationStore
    
    var body: some View {
        List {
            ForEach(qualificationStore.qualifications) { qualification in
                Section(header: Text(qualification.title)) {
                    ForEach(qualification.units) { unit in
                        VStack(alignment: .leading) {
                            Text(unit.title)
                                .font(.headline)
                            ProgressView(value: unit.progress)
                                .progressViewStyle(.linear)
                            Text("\(Int(unit.progress * 100))% Complete")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Progress")
    }
}

#Preview {
    NavigationView {
        ProgressDetailView()
            .environmentObject(EvidenceManager())
            .environmentObject(QualificationStore())
    }
} 