import SwiftUI
import WebKit
import UIKit

struct PortfolioPreviewView: View {
    let url: URL
    @EnvironmentObject var qualificationStore: QualificationStore
    @State private var selectedUnit = "311"  // Default to first unit
    @State private var loadError: Error?
    @State private var isLoading = true
    @State private var shouldReloadWebView = false
    
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
            "ELTP3-001", "ELTP3-002", "ELTP3-003", 
            "ELTP3-004", "ELTP3-005", "ELTP3-006", 
            "ELTP3-007"
        ]
        
        let level3Units = [
            // Level 3 2357 Units
            "2357-301", "2357-302", "2357-303", "2357-304",
            "2357-305", "2357-306", "2357-307", "2357-308",
            "2357-309", "2357-310", "2357-311", "2357-312"
        ]
        
        return ewaUnits + nvqUnits + level3Units
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Restore the preview menu at top
            HStack {
                Menu {
                    // Preview options
                    ForEach(units, id: \.self) { unitCode in
                        Button(action: {
                            selectedUnit = unitCode
                        }) {
                            Text(getUnitDescription(unitCode))
                        }
                    }
                } label: {
                    HStack {
                        Text("Preview")
                        Image(systemName: "chevron.down")
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // WebView Container
            WebViewContainer(
                url: url,
                selectedUnit: selectedUnit,
                loadError: $loadError,
                isLoading: $isLoading
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            // ELTP3 units already have full codes
            case let code where code.hasPrefix("ELTP3/"): return code
            // RPL units
            case "18ED3 02": return "18ED3-02"
            case "QIT3-001": return "QIT3-001"
            // 2357 Level 3 units
            case "2357-301": return "Unit 301 - LO1-4/PC1-12"
            case "2357-302": return "Unit 302 - LO1-3/PC1-9"
            case "2357-303": return "Unit 303 - LO1-4/PC1-11"
            case "2357-304": return "Unit 304 - LO1-3/PC1-10"
            case "2357-305": return "Unit 305 - LO1-4/PC1-13"
            case "2357-306": return "Unit 306 - LO1-3/PC1-8"
            case "2357-307": return "Unit 307 - LO1-4/PC1-12"
            case "2357-308": return "Unit 308 - LO1-3/PC1-9"
            case "2357-309": return "Unit 309 - LO1-4/PC1-11"
            case "2357-310": return "Unit 310 - LO1-3/PC1-10"
            case "2357-311": return "Unit 311 - LO1-4/PC1-12"
            case "2357-312": return "Unit 312 - LO1-3/PC1-9"
            default: return unitCode
        }
    }
    
    private func convertToNETPFormat(_ unitCode: String) -> String {
        // No conversion needed - use unit codes directly
        return unitCode
    }
    
    private func standardizeUnitCode(_ code: String) -> String {
        switch code {
        case let code where code.hasPrefix("2357-"):
            return code  // Keep 2357 codes as-is
        case let code where code.hasPrefix("NETP3-"):
            return code  // Keep NETP3 codes as-is
        case let code where code.hasPrefix("ELTP3"):
            // Convert all ELTP3 codes to use hyphen format
            return code.replacingOccurrences(of: "/", with: "-")
        case "18ED3 02":
            return "18ED3-02"  // Standard format for RPL
        case "QIT3-001":
            return "QIT3-001"  // Keep QIT3 codes as-is
        case let code where Int(code) != nil:
            // For numeric codes (like "001"), convert to ELTP3 format
            return "ELTP3-\(code.padLeft(toLength: 3, withPad: "0"))"
        default:
            return code
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
            if FileManager.default.fileExists(atPath: previewURL.path) {
                do {
                    let htmlString = try String(contentsOf: previewURL, encoding: .utf8)
                    webView.loadHTMLString(htmlString, baseURL: previewURL.deletingLastPathComponent())
                    print("📄 Loading preview HTML for unit: \(selectedUnit)")
                } catch {
                    loadError = error
                    print("❌ Failed to load preview: \(error)")
                }
            } else {
                // Display a friendly message when preview isn't available
                let noPreviewHTML = """
                    <html>
                    <body style="display: flex; justify-content: center; align-items: center; height: 100vh; font-family: -apple-system, BlinkMacSystemFont, sans-serif; color: #666; text-align: center; margin: 0; padding: 20px;">
                        <div>
                            <h3 style="margin-bottom: 10px;">Preview Not Available</h3>
                            <p>Please compile your portfolio first to generate the preview for Unit \(selectedUnit).</p>
                        </div>
                    </body>
                    </html>
                """
                webView.loadHTMLString(noPreviewHTML, baseURL: nil)
            }
            isLoading = false
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

