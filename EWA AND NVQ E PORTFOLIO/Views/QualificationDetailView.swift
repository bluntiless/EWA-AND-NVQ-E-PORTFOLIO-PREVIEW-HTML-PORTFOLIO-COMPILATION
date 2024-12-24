import SwiftUI

struct QualificationDetailView: View {
    @ObservedObject var qualification: Qualification
    
    var body: some View {
        List {
            ForEach(qualification.units) { unit in
                NavigationLink(destination: UnitDetailView(unit: unit)) {
                    VStack(alignment: .leading) {
                        Text(unit.title)
                            .font(.headline)
                        ProgressView(value: unit.progress)
                            .progressViewStyle(.linear)
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
    }
} 