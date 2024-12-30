import SwiftUI

struct EvidenceUploadContainerView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    let criteriaCode: String
    let unitCode: String
    let criteriaDescription: String
    let onEvidenceUploaded: (Evidence) -> Void
    
    var body: some View {
        List {
            ForEach(Evidence.EvidenceType.allCases, id: \.self) { type in
                NavigationLink(destination: EvidenceUploadView(
                    evidenceType: type,
                    criteriaCode: criteriaCode,
                    unitCode: unitCode,
                    criteriaDescription: criteriaDescription,
                    onEvidenceUploaded: onEvidenceUploaded
                )) {
                    Label(type.rawValue, systemImage: type.iconName)
                }
            }
        }
        .navigationTitle("Select Evidence Type")
    }
} 