import SwiftUI

struct EvidenceListView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @State private var showingDeleteAlert = false
    @State private var evidenceToDelete: Evidence?
    @State private var selectedEvidence: Evidence?
    @State private var showingPreview = false
    
    var body: some View {
        List {
            ForEach(evidenceManager.evidenceItems) { evidence in
                Button {
                    selectedEvidence = evidence
                    showingPreview = true
                } label: {
                    EvidenceRow(evidence: evidence)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        evidenceToDelete = evidence
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Evidence")
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
        .onAppear {
            Task {
                await evidenceManager.loadInitialData()
            }
        }
        .refreshable {
            await evidenceManager.loadInitialData()
        }
        .alert("Delete Evidence", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let evidence = evidenceToDelete {
                    Task {
                        await evidenceManager.deleteEvidence(evidence)
                        await evidenceManager.loadInitialData()
                    }
                }
            }
        } message: {
            if let evidence = evidenceToDelete {
                Text("Are you sure you want to delete '\(evidence.title)'? This action cannot be undone.")
            }
        }
    }
} 