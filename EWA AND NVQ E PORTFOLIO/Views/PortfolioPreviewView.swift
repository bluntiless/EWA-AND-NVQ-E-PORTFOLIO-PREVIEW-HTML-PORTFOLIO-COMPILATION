import SwiftUI
import WebKit

struct PortfolioPreviewView: View {
    let url: URL
    @State private var selectedUnit = "NETP3-01"
    @State private var loadError: Error?
    @State private var isLoading = true
    
    // All available units
    let units = ["NETP3-01", "NETP3-03", "NETP3-04", "NETP3-05", "NETP3-06", "NETP3-07"]
    
    var body: some View {
        VStack {
            // Unit selector
            ScrollView(.horizontal, showsIndicators: false) {
                Picker("Unit", selection: $selectedUnit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
            
            // Preview content
            ZStack {
                WebViewContainer(
                    url: url,
                    selectedUnit: selectedUnit,
                    loadError: $loadError,
                    isLoading: $isLoading
                )
                
                if isLoading {
                    ProgressView("Loading preview...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
        }
        .alert("Preview Error", isPresented: .constant(loadError != nil)) {
            Button("OK", role: .cancel) {
                loadError = nil
            }
        } message: {
            Text(loadError?.localizedDescription ?? "Failed to load preview")
        }
    }
}

struct WebViewContainer: UIViewRepresentable {
    let url: URL
    let selectedUnit: String
    @Binding var loadError: Error?
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        
        loadContent(webView)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        loadContent(webView)
    }
    
    private func loadContent(_ webView: WKWebView) {
        let previewURL = url.appendingPathComponent(selectedUnit)
                           .appendingPathComponent("preview.html")
        
        DispatchQueue.main.async {
            do {
                let htmlString = try String(contentsOf: previewURL, encoding: .utf8)
                webView.loadHTMLString(htmlString, baseURL: previewURL.deletingLastPathComponent())
            } catch {
                loadError = error
                isLoading = false
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewContainer
        
        init(_ parent: WebViewContainer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            webView.evaluateJavaScript("""
                document.body.style.backgroundColor = 'white';
                document.documentElement.style.backgroundColor = 'white';
            """)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadError = error
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.loadError = error
            parent.isLoading = false
        }
    }
} 