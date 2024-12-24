import SwiftUI

struct TeamsIntegrationView: View {
    @StateObject private var teamsManager = TeamsManager.shared
    
    var body: some View {
        List {
            Section(header: Text("Authentication")) {
                Button(action: {
                    Task {
                        do {
                            print("Testing authentication...")
                            try await teamsManager.authenticate()
                            print("Authentication successful!")
                        } catch {
                            print("Authentication failed: \(error)")
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "key.fill")
                        Text("Test Authentication")
                    }
                }
            }
            
            Section(header: Text("Status")) {
                HStack {
                    Image(systemName: teamsManager.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(teamsManager.isAuthenticated ? .green : .red)
                    Text(teamsManager.isAuthenticated ? "Authenticated" : "Not Authenticated")
                }
            }
        }
        .navigationTitle("Teams Integration")
    }
} 