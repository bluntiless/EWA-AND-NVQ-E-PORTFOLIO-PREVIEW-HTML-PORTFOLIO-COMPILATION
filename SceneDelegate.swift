class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Initialize window
        let window = UIWindow(windowScene: windowScene)
        
        // Create and configure root view with splash screen
        let splashView = SplashScreenView()
            .environmentObject(EvidenceManager.shared)
        
        // Set root view controller
        let rootViewController = UIHostingController(rootView: splashView)
        window.rootViewController = rootViewController
        self.window = window
        
        // Make window visible on main thread
        DispatchQueue.main.async {
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when scene is being released
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when scene has moved from inactive to active state
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when scene will move from active to inactive state
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as scene transitions from background to foreground
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as scene transitions from foreground to background
    }
} 