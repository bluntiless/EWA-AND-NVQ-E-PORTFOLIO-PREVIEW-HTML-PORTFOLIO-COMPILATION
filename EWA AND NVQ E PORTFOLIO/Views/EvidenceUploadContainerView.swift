import SwiftUI

struct EvidenceUploadContainerView: View {
    @ObservedObject var evidenceManager: EvidenceManager
    @State private var selectedEvidenceType: Evidence.EvidenceType = .photo
    
    var body: some View {
        VStack {
            Picker("Evidence Type", selection: $selectedEvidenceType) {
                Text("Photo").tag(Evidence.EvidenceType.photo)
                Text("Video").tag(Evidence.EvidenceType.video)
                Text("Document").tag(Evidence.EvidenceType.document)
            }
            .pickerStyle(.segmented)
            .padding()
            
            EvidenceUploadView(
                criteriaCode: "PC1",
                unitCode: "UNIT1",
                criteriaDescription: "Performance Criteria 1",
                evidenceType: selectedEvidenceType,
                onEvidenceUploaded: { evidence in
                    evidenceManager.addEvidence(evidence)
                }
            )
        }
        .navigationTitle("Upload Evidence")
    }
} 