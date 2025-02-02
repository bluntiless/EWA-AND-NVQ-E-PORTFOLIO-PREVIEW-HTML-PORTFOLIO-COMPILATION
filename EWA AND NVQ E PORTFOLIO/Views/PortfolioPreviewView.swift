import SwiftUI
import WebKit

struct PortfolioPreviewView: View {
    let url: URL
    @EnvironmentObject var qualificationStore: QualificationStore
    @State private var selectedUnit = "311"  // Default to first unit
    @State private var loadError: Error?
    @State private var isLoading = true
    
    // Get all units - both performance and knowledge
    var units: [String] {
        let ewaUnits = [
            // EWA Units (NETP3 series)
            "NETP3-01", "NETP3-03", "NETP3-04", 
            "NETP3-05", "NETP3-06", "NETP3-07"
        ]
        
        let nvqUnits = [
            // NVQ 1605 Units
            "001", "002", "003", "004", "005", "006", "007"
        ]
        
        return ewaUnits + nvqUnits
    }
    
    var body: some View {
        VStack {
            // Unit selector with improved layout
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(44))], spacing: 8) {
                    ForEach(units, id: \.self) { unitCode in
                        Button(action: {
                            selectedUnit = unitCode
                        }) {
                            Text(getUnitDescription(unitCode))
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(selectedUnit == unitCode ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedUnit == unitCode ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 50)
            
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
    
    private func getUnitDescription(_ unitCode: String) -> String {
        if unitCode.starts(with: "NETP") {
            return unitCode  // Keep full NETP3-XX format
        } else {
            return "NVQ \(unitCode)"  // Shows "NVQ 001" etc.
        }
    }
    
    private func convertToNETPFormat(_ unitCode: String) -> String {
        // No conversion needed - use unit codes directly
        return unitCode
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
