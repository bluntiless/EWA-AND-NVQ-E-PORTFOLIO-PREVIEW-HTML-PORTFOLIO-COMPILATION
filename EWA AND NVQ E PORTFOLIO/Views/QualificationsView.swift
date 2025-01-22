import SwiftUI

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
                            .tint(.green) // Add green color
                            .frame(height: 8)
                        
                        // Add unit count
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