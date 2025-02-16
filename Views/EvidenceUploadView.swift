import SwiftUI

struct EvidenceUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var evidenceManager: EvidenceManager
    @State private var selectedUnit: String = ""
    @State private var selectedCriteria: String = ""
    @State private var fileURL: URL?
    @State private var sharePointService = SharePointService()
    @State private var isViewInitialized = false
    @State private var isLoading = true
    @State private var selectedItems: [PhotosPickerItem] = []
    
    let evidenceType: Evidence.EvidenceType
    let criteriaCode: String
    let unitCode: String
    let criteriaDescription: String
    let onEvidenceUploaded: (Evidence) -> Void
    let selectedCriteria: [PerformanceCriteria]
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading picker...")
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    // Increase delay to match observed timing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isLoading = false
                    }
                }
            } else {
                VStack {
                    switch evidenceType {
                    case .photo:
                        PhotosPicker(selection: $selectedItems,
                                   maxSelectionCount: 5,
                                   matching: .images) {
                            Label("Select Photos", systemImage: "photo")
                        }
                    case .video:
                        PhotosPicker(selection: $selectedItems,
                                   matching: .videos) {
                            Label("Select Video", systemImage: "video")
                        }
                    case .document:
                        DocumentPicker(...)
                    }
                    
                    // Preview area
                    // Upload button
                }
            }
        }
        .navigationTitle("Upload Evidence")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .task {
            if !isViewInitialized {
                isViewInitialized = true
                selectedUnit = unitCode
                selectedCriteria = criteriaCode
            }
        }
    }

    private func uploadEvidence() async {
        guard let fileURL = fileURL else { return }
        do {
            await sharePointService.uploadEvidence(
                unit: selectedUnit,
                criteria: selectedCriteria,
                fileURL: fileURL,
                qualificationType: .ewa
            )
        } catch {
            // Handle error
        }
    }
}

struct EvidenceUploadView_Previews: PreviewProvider {
    static var previews: some View {
        EvidenceUploadView(
            evidenceType: .photo,
            criteriaCode: "",
            unitCode: "",
            criteriaDescription: "",
            onEvidenceUploaded: { _ in },
            selectedCriteria: []
        )
    }
} 