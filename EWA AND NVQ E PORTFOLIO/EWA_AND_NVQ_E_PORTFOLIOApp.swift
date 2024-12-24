//
//  EWA_AND_NVQ_E_PORTFOLIOApp.swift
//  EWA AND NVQ E PORTFOLIO
//
//  Created by WAYNE WRIGHT on 18/12/2024.
//

import SwiftUI
import MSAL

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                    open url: URL,
                    options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("\n=== URL Handling ===")
        print("Received URL: \(url)")
        print("Source application: \(options[.sourceApplication] ?? "unknown")")
        
        guard let sourceApplication = options[.sourceApplication] as? String else {
            return false
        }
        
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: sourceApplication)
    }
}

// Add scene delegate support
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        print("\n=== Scene URL Handling ===")
        print("Received URL in scene: \(url)")
        
        _ = MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: nil)
    }
}

@main
struct EWA_AND_NVQ_E_PORTFOLIOApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var evidenceManager = EvidenceManager()
    @StateObject private var qualificationStore = QualificationStore()
    @StateObject private var teamsManager = TeamsManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(evidenceManager)
                .environmentObject(qualificationStore)
                .onAppear {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        teamsManager.setPresentingViewController(rootViewController)
                    }
                }
                .handlesExternalEvents(
                    preferring: Set(["msauth.com.waynewright.ewa-nvq-portfolio1"]),
                    allowing: Set(["msauth.com.waynewright.ewa-nvq-portfolio1"])
                )
        }
    }
}
