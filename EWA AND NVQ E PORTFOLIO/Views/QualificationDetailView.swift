import SwiftUI

struct QualificationDetailView: View {
    @ObservedObject var qualification: Qualification
    @EnvironmentObject var evidenceManager: EvidenceManager
    
    var body: some View {
        List {
            ForEach(qualification.units) { unit in
                NavigationLink(destination: UnitDetailView(unit: unit)) {
                    VStack(alignment: .leading) {
                        Text(unit.title)
                            .font(.headline)
                        ProgressView(value: unit.progress)
                            .progressViewStyle(.linear)
                            .tint(progressColor(for: unit))
                            .frame(height: 8)
                    }
                }
            }
        }
        .navigationTitle(qualification.title)
        .onReceive(qualification.units.publisher.flatMap { unit in
            unit.objectWillChange
        }) { _ in
            qualification.updateProgress()
        }
        .task {
            for unit in qualification.units {
                await unit.updateProgressWithEvidence(evidenceManager)
            }
        }
    }
    
    private func progressColor(for unit: Unit) -> Color {
        if unit.code == "NETP3-03" {
            return .yellow
        }
        return .green
    }
} 