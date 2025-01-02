@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Move heavy initialization to background
        DispatchQueue.global(qos: .userInitiated).async {
            // Initialize SharePoint client
            // Setup MSAL
            // Load initial data
            
            DispatchQueue.main.async {
                // Update UI if needed
            }
        }
        
        return true
    }
} 