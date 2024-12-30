import SwiftUI

struct UploadedEvidenceView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @State private var selectedEvidence: Evidence?
    @State private var showingPreview = false
    @State private var filteredEvidence: [Evidence] = []
    
    let unitCode: String
    let criteriaCode: String
    
    func updateFilteredEvidence() {
        filteredEvidence = evidenceManager.evidenceItems.filter { evidence in
            evidence.isUploaded && 
            evidence.unitCode == unitCode &&
            evidence.criteriaCode == criteriaCode
        }
    }
    
    var body: some View {
        Group {
            if evidenceManager.isLoading {
                ProgressView()
            } else if filteredEvidence.isEmpty {
                Text("No evidence uploaded for this criteria")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(filteredEvidence) { evidence in
                    Button {
                        selectedEvidence = evidence
                        showingPreview = true
                    } label: {
                        EvidenceRow(evidence: evidence)
                    }
                }
            }
        }
        .task {
            updateFilteredEvidence()
        }
        .onReceive(evidenceManager.$evidenceItems) { _ in
            updateFilteredEvidence()
        }
        .sheet(isPresented: $showingPreview) {
            if let evidence = selectedEvidence {
                NavigationStack {
                    EvidencePreviewView(evidence: evidence)
                        .navigationTitle(evidence.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingPreview = false
                                }
                            }
                        }
                }
            }
        }
    }
} 