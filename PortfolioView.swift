struct PortfolioView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @EnvironmentObject var qualificationStore: QualificationStore
    @State private var selectedEvidence: Evidence?
    @State private var showingPreview = false
    
    var uploadedEvidence: [Evidence] {
        let evidence = evidenceManager.evidenceItems.filter { $0.isUploaded }
        print("Total evidence items: \(evidenceManager.evidenceItems.count)")
        print("Uploaded evidence items: \(evidence.count)")
        print("Evidence items status:")
        evidenceManager.evidenceItems.forEach { item in
            print("- ID: \(item.id)")
            print("  SharePoint URL: \(item.sharePointUrl ?? "None")")
            print("  Is Locally Uploaded: \(item.isLocallyUploaded)")
            print("  Is Uploaded: \(item.isUploaded)")
        }
        return evidence
    }
    
    var body: some View {
        NavigationView {
            List {
                // 1. Evidence Collection
                Section(header: Text("EVIDENCE COLLECTION")) {
                    NavigationLink(destination: EvidenceUploadContainerView(
                        criteriaCode: "General",
                        unitCode: "ALL",
                        criteriaDescription: "General Evidence Upload",
                        onEvidenceUploaded: { evidence in
                            evidenceManager.addEvidence(evidence)
                        }
                    ).environmentObject(evidenceManager)) {
                        Label("Upload Evidence", systemImage: "square.and.arrow.up")
                    }
                }
                
                // 2. Progress View - Force it to be second
                Section(header: Text("PROGRESS")) {
                    NavigationLink(destination: ProgressDetailView(
                        evidenceManager: evidenceManager,
                        qualificationStore: qualificationStore
                    )) {
                        Label("View Progress", systemImage: "chart.bar")
                    }
                }
                .zIndex(1) // Try to force ordering
                
                // 3. Uploaded Evidence
                Section(header: Text("UPLOADED EVIDENCE")) {
                    if evidenceManager.isLoading {
                        ProgressView()
                    } else if uploadedEvidence.isEmpty {
                        Text("No evidence uploaded")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(uploadedEvidence) { evidence in
                            Button {
                                selectedEvidence = evidence
                                showingPreview = true
                            } label: {
                                EvidenceRow(evidence: evidence)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Portfolio")
            .refreshable {
                print("Manual refresh triggered")
                await evidenceManager.loadInitialData()
                await evidenceManager.refreshEvidenceStatus()
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
                    print("PortfolioView appeared - Loading initial data")
                    await evidenceManager.loadInitialData()
                    await evidenceManager.refreshEvidenceStatus()
                }
            }
            .onChange(of: showingPreview) { isShowing in
                if !isShowing {  // When preview is dismissed
                    Task {
                        await evidenceManager.refreshEvidenceStatus()
                    }
                }
            }
            .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
                Task {
                    await evidenceManager.refreshEvidenceStatus()
                }
            }
        }
        .task {
            print("PortfolioView appeared - Loading initial data")
            await evidenceManager.loadInitialData()
            await evidenceManager.refreshEvidenceStatus()
        }
    }
} 