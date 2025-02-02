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
                                HStack {
                                    Image(systemName: "doc.text.magnifyingglass")
                                    Text("View Evidence")
                                }
                                .foregroundColor(.blue)
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
            contentType: .portfolio,
            defaultFilename: "Portfolio-\(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short).replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: ":", with: "-"))",
            onCompletion: { result in
                switch result {
                case .success(let url):
                    isCompiling = true
                    Task {
                        do {
                            try await PortfolioCompilationService.shared.compilePortfolio(
                                evidence: evidenceManager.evidenceItems,
                                to: url
                            )
                            compiledPortfolioURL = url
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
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .navigationTitle("Portfolio")
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
                .refreshable {  // Add pull-to-refresh
                    await evidenceManager.refreshEvidenceStatus()
                }
                .onReceive(Timer.publish(every: 10, on: .main, in: .common).autoconnect()) { _ in
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

struct PortfolioPreview: View {
    @ObservedObject var qualification: Qualification
    @State private var selectedUnit: Unit?
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(qualification.units) { unit in
                        Button(action: {
                            selectedUnit = unit
                        }) {
                            Text(unit.displayCode)
                                .padding()
                                .background(selectedUnit?.id == unit.id ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            
            if let unit = selectedUnit {
                VStack(alignment: .leading) {
                    Text("Unit \(unit.displayCode) Evidence Preview")
                        .font(.headline)
                    Text("Approved Criteria: \(unit.learningOutcomes.flatMap { $0.performanceCriteria }.filter { $0.isCompleted }.count) of \(unit.learningOutcomes.flatMap { $0.performanceCriteria }.count)")
                    
                    ForEach(unit.learningOutcomes) { outcome in
                        VStack(alignment: .leading) {
                            Text("Learning Outcome \(outcome.number): \(outcome.title)")
                                .font(.subheadline)
                                .padding(.vertical, 4)
                            
                            ForEach(outcome.performanceCriteria) { criteria in
                                HStack {
                                    Text(criteria.code)
                                        .foregroundColor(.secondary)
                                    Text(criteria.description)
                                    Spacer()
                                    if criteria.isCompleted {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}