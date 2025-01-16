import SwiftUI

struct UploadedEvidenceView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @State private var selectedEvidence: Evidence?
    @State private var showingPreview = false
    @State private var filteredEvidence: [Evidence] = []
    
    let unitCode: String
    let criteriaCode: String
    
    func updateFilteredEvidence() {
        print("Updating filtered evidence for criteria: \(criteriaCode)")
        filteredEvidence = evidenceManager.evidenceItems.filter { evidence in
            evidence.isUploaded && 
            evidence.unitCode == unitCode &&
            (evidence.criteriaArray.contains(criteriaCode) || 
             evidence.associatedCriteria.contains(criteriaCode))
        }
        print("Found \(filteredEvidence.count) matching evidence items")
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
            print("Evidence items updated, refreshing view")
            updateFilteredEvidence()
        }
        .onChange(of: evidenceManager.lastUploadTimestamp) { _ in
            print("Upload timestamp changed, refreshing view")
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