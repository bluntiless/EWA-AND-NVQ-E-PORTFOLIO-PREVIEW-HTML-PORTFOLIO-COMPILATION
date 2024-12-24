import SwiftUI

struct AuthenticationView: View {
    @StateObject private var teamsManager = TeamsManager.shared
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Button("Sign in with Microsoft") {
                Task {
                    do {
                        try await teamsManager.authenticate()
                    } catch {
                        errorMessage = error.localizedDescription
                        showingError = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .alert("Authentication Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
} 
