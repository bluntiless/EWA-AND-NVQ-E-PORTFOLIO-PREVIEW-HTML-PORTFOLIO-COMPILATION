import SwiftUI
import UniformTypeIdentifiers

struct PortfolioView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @EnvironmentObject var qualificationStore: QualificationStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingCompilationSheet = false
    @State private var compilationError: Error?
    @State private var showingError = false
    @State private var isCompiling = false
    @State private var compiledPortfolioURL: URL?
    @State private var showingPreview = false
    
    private var backButton: some View {
        Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                EvidenceTabView()
                    .tabItem {
                        Label("Evidence", systemImage: "doc.text")
                    }
                    .tag(0)
                    .environmentObject(evidenceManager)
                    .environmentObject(qualificationStore)
                
                ProgressTabView()
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                    .environmentObject(evidenceManager)
                    .environmentObject(qualificationStore)
            }
            .task {
                await evidenceManager.loadInitialData()
                await evidenceManager.refreshEvidenceStatus()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if let url = compiledPortfolioURL {
                            Button {
                                showingPreview = true
                            } label: {
                                Image(systemName: "eye")
                            }
                        }
                        
                        Button {
                            showingCompilationSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                Text("Compile Portfolio")
                            }
                        }
                    }
                }
            }
        }
        .fileExporter(
            isPresented: $showingCompilationSheet,
            document: PortfolioDocument(initialDirectory: "Portfolio"),
            contentType: .folder,
            defaultFilename: "Portfolio-\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short).replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-"))"
        ) { result in
            switch result {
            case .success(let url):
                isCompiling = true
                Task {
                    do {
                        try await PortfolioCompilationService.shared.compilePortfolio(
                            evidence: evidenceManager.evidenceItems,
                            to: url
                        )
                        compiledPortfolioURL = url.appendingPathComponent("index.html")
                    } catch {
                        compilationError = error
                        showingError = true
                    }
                    isCompiling = false
                }
            case .failure(let error):
                compilationError = error
                showingError = true
            }
        }
        .navigationTitle("Save Portfolio")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPreview) {
            if let url = compiledPortfolioURL {
                NavigationView {
                    PortfolioPreviewView(url: url)
                        .navigationTitle("Portfolio Preview")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingPreview = false
                                }
                            }
                        }
                }
                .interactiveDismissDisabled(false)
                .presentationDragIndicator(.visible)
            }
        }
        .alert("Compilation Error", isPresented: $showingError, presenting: compilationError) { _ in
            Button("OK") {}
        } message: { error in
            Text(error.localizedDescription)
        }
        .overlay {
            if isCompiling {
                ProgressView("Compiling Portfolio...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
    }
}

struct EvidenceTabView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @EnvironmentObject var qualificationStore: QualificationStore
    
    var body: some View {
        NavigationView {
            EvidenceListView()
                .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
                    Task {
                        await evidenceManager.refreshEvidenceStatus()
                    }
                }
        }
    }
}

struct ProgressTabView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @EnvironmentObject var qualificationStore: QualificationStore
    
    var body: some View {
        NavigationView {
            ProgressDetailView(
                qualificationStore: qualificationStore
            )
        }
    }
}

// Move this before PortfolioDocument struct
extension UTType {
    static var folder: UTType {
        UTType(exportedAs: "com.waynewright.ewa-nvq-portfolio.folder")
    }
}

struct PortfolioDocument: FileDocument {
    let initialDirectory: String
    
    static var readableContentTypes: [UTType] { [.folder] }
    
    init(initialDirectory: String) {
        self.initialDirectory = initialDirectory
    }
    
    init(configuration: ReadConfiguration) throws {
        self.initialDirectory = ""
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(directoryWithFileWrappers: [:])
    }
}