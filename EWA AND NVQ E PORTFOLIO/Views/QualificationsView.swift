import SwiftUI

struct QualificationsView: View {
    @EnvironmentObject var qualificationStore: QualificationStore
    
    var body: some View {
        List(qualificationStore.qualifications) { qualification in
            NavigationLink(destination: QualificationDetailView(qualification: qualification)) {
                VStack(alignment: .leading) {
                    Text(qualification.title)
                        .font(.headline)
                    Text(qualification.description)
                        .font(.subheadline)
                    ProgressView(value: qualification.progress)
                }
            }
        }
        .navigationTitle("Qualifications")
    }
} 