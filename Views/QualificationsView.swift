import SwiftUI

// Add Qualification model if not already defined
class Qualification: Identifiable, ObservableObject {
    let id: String
    let title: String
    let description: String
    @Published var units: [Unit]
    @Published var progress: Double = 0.0
    
    init(id: String, title: String, description: String, units: [Unit]) {
        self.id = id
        self.title = title
        self.description = description
        self.units = units
    }
    
    func updateProgress() {
        let completedUnits = units.filter { $0.progress >= 1.0 }.count
        progress = Double(completedUnits) / Double(units.count)
    }
}

// Add QualificationStore if not already defined
class QualificationStore: ObservableObject {
    @Published var qualifications: [Qualification]
    
    init(qualifications: [Qualification] = []) {
        self.qualifications = qualifications
    }
}

struct QualificationsView: View {
    @EnvironmentObject var qualificationStore: QualificationStore
    
    var body: some View {
        List(qualificationStore.qualifications) { qualification in
            NavigationLink(destination: QualificationDetailView(qualification: qualification)) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(qualification.title)
                        .font(.headline)
                    Text(qualification.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Progress bar with count
                    HStack {
                        ProgressView(value: qualification.progress)
                            .progressViewStyle(.linear)
                            .tint(.green)
                            .frame(height: 8)
                        
                        Text("\(Int(qualification.progress * Double(qualification.units.count)))/\(qualification.units.count) Units")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Qualifications")
    }
} 