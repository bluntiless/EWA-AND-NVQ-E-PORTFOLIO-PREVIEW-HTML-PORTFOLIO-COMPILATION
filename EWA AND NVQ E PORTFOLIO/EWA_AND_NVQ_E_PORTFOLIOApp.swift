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
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Set the window for authentication
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        TeamsManager.shared.setPresentingViewController(window.rootViewController!)
                    }
                }
        }
    }
}

// MODIFICATION PROTOCOLS
/*
 CHANGE CONTROL:
 - All changes require explicit approval
 - No UI/UX modifications without review
 - Preserve existing functionality
 - Document all impacts before changes
*/
