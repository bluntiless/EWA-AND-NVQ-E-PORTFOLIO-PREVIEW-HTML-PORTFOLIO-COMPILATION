import SwiftUI
import WebKit

struct PortfolioPreviewView: View {
    let url: URL
    @State private var loadError: Error?
    @State private var showError = false
    
    var body: some View {
        Group {
            WebViewWrapper(url: url, loadError: $loadError)
                .ignoresSafeArea()
        }
        .alert("Preview Error", isPresented: $showError, presenting: loadError) { _ in
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
        .onChange(of: loadError != nil) { hasError in
            showError = hasError
        }
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    @Binding var loadError: Error?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<WebViewWrapper>) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        // Add accessibility support
        webView.isAccessibilityElement = true
        webView.accessibilityLabel = "Portfolio Preview"
        webView.accessibilityTraits = .allowsDirectInteraction
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: UIViewRepresentableContext<WebViewWrapper>) {
        let baseURL = url.deletingLastPathComponent()
        
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async {
            do {
                // Start security-scoped resource access
                guard url.startAccessingSecurityScopedResource() else {
                    loadError = NSError(domain: "PortfolioPreview", code: -1, 
                        userInfo: [NSLocalizedDescriptionKey: "Cannot access preview file"])
                    return
                }
                
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                
                // Verify file exists and is readable
                guard try url.checkResourceIsReachable() else {
                    loadError = NSError(domain: "PortfolioPreview", code: -1, 
                        userInfo: [NSLocalizedDescriptionKey: "Preview file not accessible"])
                    return
                }
                
                // Load the file with proper security scoping
                webView.loadFileURL(url, allowingReadAccessTo: baseURL)
            } catch {
                loadError = error
            }
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewWrapper
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.loadError = error
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.loadError = error
            }
        }
        
        // Add successful load handling
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.body.style.backgroundColor = 'white';")
        }
    }
} 