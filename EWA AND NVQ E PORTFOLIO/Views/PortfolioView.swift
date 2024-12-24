import SwiftUI

struct PortfolioView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @EnvironmentObject var qualificationStore: QualificationStore
    @State private var showingUploadSheet = false
    @State private var selectedEvidenceType: Evidence.EvidenceType = .photo
    @State private var selectedEvidence: Evidence?
    @State private var showingPreview = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Evidence Collection")) {
                    NavigationLink {
                        EvidenceUploadContainerView(
                            evidenceManager: evidenceManager
                        )
                    } label: {
                        Label("Upload Evidence", systemImage: "square.and.arrow.up")
                    }
                }
                
                Section(header: Text("Uploaded Evidence")) {
                    if evidenceManager.evidenceItems.isEmpty {
                        Text("No evidence uploaded")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(evidenceManager.evidenceItems) { evidence in
                            Button {
                                selectedEvidence = evidence
                                showingPreview = true
                            } label: {
                                EvidenceRow(evidence: evidence)
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
                
                Section(header: Text("Progress")) {
                    NavigationLink(destination: ProgressDetailView()) {
                        Label("View Progress", systemImage: "chart.bar")
                    }
                }
            }
            .navigationTitle("Portfolio")
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
        .task {
            await evidenceManager.loadInitialData()
        }
    }
} 