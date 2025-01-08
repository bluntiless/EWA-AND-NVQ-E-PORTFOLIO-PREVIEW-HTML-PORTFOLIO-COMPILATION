import SwiftUI

struct EvidenceListView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @State private var selectedEvidence: Evidence?
    @State private var showingPreview = false
    @State private var showingHidden = false
    
    var body: some View {
        List {
            ForEach(evidenceManager.evidenceItems.filter { !$0.isHidden }) { evidence in
                Button {
                    selectedEvidence = evidence
                    showingPreview = true
                } label: {
                    EvidenceRow(evidence: evidence)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        withAnimation {
                            evidenceManager.hideEvidence(evidence)
                        }
                    } label: {
                        Label("Hide", systemImage: "eye.slash")
                    }
                    .tint(.orange)
                }
            }
        }
        .accessibilityIdentifier("EvidenceList")
        .navigationTitle("Evidence")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingHidden.toggle()
                } label: {
                    Label("Hidden Items", systemImage: "eye.slash")
                }
            }
        }
        .sheet(isPresented: $showingHidden) {
            NavigationView {
                List {
                    ForEach(evidenceManager.evidenceItems.filter { $0.isHidden }) { evidence in
                        EvidenceRow(evidence: evidence)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    evidenceManager.unhideEvidence(evidence)
                                } label: {
                                    Label("Unhide", systemImage: "eye")
                                }
                                .tint(.blue)
                            }
                    }
                }
                .accessibilityIdentifier("HiddenList")
                .navigationTitle("Hidden Items")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingHidden = false
                        }
                    }
                }
            }
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
        .onAppear {
            Task {
                await evidenceManager.loadInitialData()
            }
        }
        .refreshable {
            await evidenceManager.loadInitialData()
        }
    }
} 