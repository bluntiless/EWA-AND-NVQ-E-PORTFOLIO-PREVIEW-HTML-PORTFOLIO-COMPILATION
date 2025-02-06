import SwiftUI

struct ContentView: View {
    @State private var portfolioURL: URL?

    var body: some View {
        NavigationView {
            VStack {
                // Add to your existing navigation
                NavigationLink {
                    QualificationSelectionView(portfolioURL: portfolioURL)
                } label: {
                    Label("Portfolio Preview", systemImage: "doc.text.magnifyingglass")
                }
            }
        }
    }
}

#Preview {
    ContentView()
} 