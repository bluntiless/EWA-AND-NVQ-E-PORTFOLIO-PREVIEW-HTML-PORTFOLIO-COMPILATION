import SwiftUI

struct QualificationSelectionView: View {
    @EnvironmentObject var qualificationStore: QualificationStore
    let portfolioURL: URL
    
    var body: some View {
        List {
            Section(header: Text("Select Qualification")) {
                NavigationLink {
                    PortfolioPreviewView(qualificationType: .eal, url: portfolioURL)
                        .environmentObject(qualificationStore)
                        .onAppear {
                            print("EAL Preview View appeared")
                        }
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("EAL Level 3")
                        Text("(NETP3/ELTP3)")
                            .foregroundColor(.secondary)
                    }
                }
                
                NavigationLink {
                    PortfolioPreviewView(qualificationType: .cityAndGuilds, url: portfolioURL)
                        .environmentObject(qualificationStore)
                        .onAppear {
                            print("City & Guilds Preview View appeared")
                        }
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("City & Guilds")
                        Text("(2357)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Portfolio Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        QualificationSelectionView(portfolioURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
            .environmentObject(QualificationStore())
    }
} 