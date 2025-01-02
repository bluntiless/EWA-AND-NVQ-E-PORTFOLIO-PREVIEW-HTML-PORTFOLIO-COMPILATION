//
//  ContentView.swift
//  EWA AND NVQ E PORTFOLIO
//
//  Created by WAYNE WRIGHT on 18/12/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var evidenceManager = EvidenceManager()
    @StateObject private var qualificationStore = QualificationStore()
    @State private var isLoading = true
    @StateObject private var teamsManager = TeamsManager.shared
    
    var body: some View {
        TabView {
            // Qualifications Tab
            NavigationView {
                List(qualificationStore.qualifications) { qualification in
                    NavigationLink(destination: QualificationDetailView(qualification: qualification)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(qualification.title)
                                .font(.headline)
                            Text(qualification.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                            
                            // Progress Summary
                            VStack(alignment: .leading, spacing: 4) {
                                ProgressView(value: qualification.progress)
                                    .progressViewStyle(.linear)
                                    .frame(height: 4)
                                HStack {
                                    Text("\(Int(qualification.progress * 100))% Complete")
                                    Spacer()
                                    Text("\(completedUnits(for: qualification))/\(qualification.units.count) Units")
                                }
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("Qualifications")
            }
            .tabItem {
                Label("Qualifications", systemImage: "book.fill")
            }
            
            // Portfolio Tab
            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "folder.fill")
                }
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
            
            // Teams Integration Tab
            NavigationView {
                TeamsIntegrationView()
            }
            .tabItem {
                Label("Teams", systemImage: "person.2.fill")
            }
        }
        .environmentObject(evidenceManager)
        .environmentObject(qualificationStore)
        .task {
            await evidenceManager.loadInitialData()
            isLoading = false
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
        
        Button("Test Token") {
            Task {
                await teamsManager.testToken()
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
    
    func completedUnits(for qualification: Qualification) -> Int {
        qualification.units.filter { $0.progress == 1.0 }.count
    }
}

#Preview {
    ContentView()
}
