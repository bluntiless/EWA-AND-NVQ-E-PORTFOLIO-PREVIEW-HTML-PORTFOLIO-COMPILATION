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
            "NETP3-05", "NETP3-06", "NETP3-07",
            // Add RPL units
            "18ED3 02", "QIT3-001"
        ]
        
        let nvqUnits = [
            // NVQ 1605 Units
            "001", "002", "003", "004", "005", "006", "007"
        ]
        
        return ewaUnits + nvqUnits
    }
    
    var body: some View {
        VStack {
            // Preview button at the top
            Button(action: {
                // Existing preview action
            }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")  // Changed from "eye"
                    Text("View Portfolio Evidence")  // Added descriptive label
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .opacity(1)  // Always visible (changed from conditional visibility)
            .padding(.top)
            
            // Unit selector with improved layout
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [GridItem(.fixed(44))], spacing: 8) {
                    ForEach(units, id: \.self) { unitCode in
                        Button(action: {
                            selectedUnit = unitCode
                        }) {
                            Text(getUnitDescription(unitCode))
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedUnit == unitCode ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedUnit == unitCode ? .white : .primary)
                                .cornerRadius(8)
                                .minimumScaleFactor(0.8)
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
        switch unitCode {
            // ELTP3 units should show full codes
            case "001": return "ELTP3/001"
            case "002": return "ELTP3/002"
            case "003": return "ELTP3/003"
            case "004": return "ELTP3/004"
            case "005": return "ELTP3/005"
            case "006": return "ELTP3/006"
            case "007": return "ELTP3/007"
            // RPL units
            case "18ED3 02": return "18ED3-02"
            case "QIT3-001": return "QIT3-001"
            default: return unitCode
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
