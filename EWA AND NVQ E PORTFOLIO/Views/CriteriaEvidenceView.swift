import SwiftUI

struct CriteriaEvidenceView: View {
    let unit: Unit
    let selectedCriteria: [PerformanceCriteria]
    @StateObject private var viewModel: CriteriaEvidenceViewModel
    @StateObject private var evidenceManager = EvidenceManager()
    @State private var showingUploadSheet = false
    @State private var selectedEvidenceType: Evidence.EvidenceType?
    
    init(unit: Unit, selectedCriteria: [PerformanceCriteria]) {
        self.unit = unit
        self.selectedCriteria = selectedCriteria
        _viewModel = StateObject(wrappedValue: CriteriaEvidenceViewModel(criteria: selectedCriteria))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Selected Criteria Information
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(selectedCriteria) { criteria in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Criteria \(criteria.code)")
                                .font(.headline)
                            Text(criteria.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            // Upload Options
            VStack(spacing: 12) {
                UploadButton(
                    title: "Upload Photos",
                    icon: "camera",
                    color: .blue
                ) {
                    selectedEvidenceType = .photo
                    showingUploadSheet = true
                }
                
                UploadButton(
                    title: "Upload Video",
                    icon: "video",
                    color: .green
                ) {
                    selectedEvidenceType = .video
                    showingUploadSheet = true
                }
                
                UploadButton(
                    title: "Upload Document",
                    icon: "doc",
                    color: .orange
                ) {
                    selectedEvidenceType = .document
                    showingUploadSheet = true
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingUploadSheet, onDismiss: {
            viewModel.loadEvidence()
        }) {
            if let evidenceType = selectedEvidenceType {
                NavigationView {
                    EvidenceUploadView(
                        evidenceType: evidenceType,
                        criteriaCode: selectedCriteria.map { $0.code }.joined(separator: ", "),
                        unitCode: unit.code,
                        criteriaDescription: selectedCriteria.map { $0.description }.joined(separator: "\n"),
                        onEvidenceUploaded: { evidence in
                            evidenceManager.addEvidence(evidence)
                        }
                    )
                }
            }
        }
    }
}

struct UploadButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title3)
            }
            .padding()
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
