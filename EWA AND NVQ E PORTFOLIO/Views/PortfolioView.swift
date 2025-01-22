import SwiftUI
import MSAL

struct PortfolioView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @EnvironmentObject var qualificationStore: QualificationStore
    @State private var selectedTab = 0
    
    var body: some View {
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