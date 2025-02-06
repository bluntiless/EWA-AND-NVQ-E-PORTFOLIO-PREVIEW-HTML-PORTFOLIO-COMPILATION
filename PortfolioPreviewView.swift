import SwiftUI
import WebKit

struct PortfolioPreviewView: View {
    let url: URL
    let qualificationType: QualificationType
    @EnvironmentObject var qualificationStore: QualificationStore
    @State private var selectedUnit = "NETP3-01"  // Updated default unit
    @State private var loadError: Error?
    @State private var isLoading = true
    @State private var shouldReloadWebView = false  // Add this state
    
    // Update units to handle both qualification types
    var units: [String] {
        switch qualificationType {
        case .eal:
            let ewaUnits = EALUnits.ewaUnits.map { $0.displayCode }
            let nvqUnits = EALUnits.nvqUnits.map { $0.displayCode }
            let rplUnits = EALUnits.rplUnits.map { $0.displayCode }
            return ewaUnits + nvqUnits + rplUnits
            
        case .cityAndGuilds:
            return [
                "Unit 311",
                "Unit 312",
                "Unit 313",
                "Unit 315",
                "Unit 316",
                "Unit 317",
                "Unit 318",
                "Unit 399"
            ]
        }
    }
    
    private func getUnitDescription(_ unitCode: String) -> String {
        // Handle both NETP3 and ELTP3 formats
        switch unitCode {
        // NETP3 cases
        case "001", "01": return "NETP3-01"
        case "002", "02": return "NETP3-02"
        case "003", "03": return "NETP3-03"
        case "004", "04": return "NETP3-04"
        case "005", "05": return "NETP3-05"
        case "006", "06": return "NETP3-06"
        case "007", "07": return "NETP3-07"
        // ELTP3 cases
        case "ELTP3/001", "ELTP3-001": return "ELTP3-001"
        case "ELTP3/002", "ELTP3-002": return "ELTP3-002"
        case "ELTP3/003", "ELTP3-003": return "ELTP3-003"
        case "ELTP3/004", "ELTP3-004": return "ELTP3-004"
        case "ELTP3/005", "ELTP3-005": return "ELTP3-005"
        case "ELTP3/006", "ELTP3-006": return "ELTP3-006"
        case "ELTP3/007", "ELTP3-007": return "ELTP3-007"
        // RPL cases
        case "18ED3 02": return "18ED3-02"
        case "QIT3-001": return "QIT3-001"
        default: 
            if unitCode.hasPrefix("NETP3-") { return unitCode }
            if unitCode.hasPrefix("ELTP3") { 
                // Ensure consistent format for ELTP3 codes
                let number = unitCode.filter { $0.isNumber }
                return "ELTP3-\(number.padLeft(toLength: 3, withPad: "0"))"
            }
            return "NETP3-\(unitCode)"
        }
    }
    
    private func standardizeUnitCode(_ displayCode: String) -> String {
        switch qualificationType {
        case .eal:
            return EALUnits.getUnit(byCode: displayCode)?.code ?? displayCode
            
        case .cityAndGuilds:
            return CityAndGuildsUnits.getUnit(byCode: displayCode)?.code ?? displayCode
        }
    }
    
    private func loadContent(_ webView: WKWebView) {
        let standardizedUnit = standardizeUnitCode(selectedUnit)
        
        // Use different base paths for different qualification types
        let qualificationPath = qualificationType == .eal ? "EAL" : "CityAndGuilds"
        let previewURL = url.appendingPathComponent(qualificationPath)
                           .appendingPathComponent(standardizedUnit)
                           .appendingPathComponent("preview.html")
        
        print("📱 Loading preview for unit: \(selectedUnit) -> \(standardizedUnit)")
        print("📂 Preview URL: \(previewURL.path)")
        
        guard FileManager.default.fileExists(atPath: previewURL.path) else {
            print("⚠️ Preview file not found at path: \(previewURL.path)")
            isLoading = false
            return
        }
        
        do {
            let htmlString = try String(contentsOf: previewURL, encoding: .utf8)
            let wrappedHTML = """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1">
                    <style>
                        body { margin: 20px; font-family: system-ui; }
                        img { max-width: 100%; height: auto; }
                    </style>
                </head>
                <body>
                    \(htmlString)
                </body>
                </html>
                """
            webView.loadHTMLString(wrappedHTML, baseURL: previewURL.deletingLastPathComponent())
        } catch {
            print("❌ Failed to load preview: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    private func getFullUnitTitle(_ unitCode: String) -> String {
        switch unitCode {
        case "01", "001": return "NETP3-01"
        case "02", "002": return "NETP3-02"
        case "03", "003": return "NETP3-03"
        case "04", "004": return "NETP3-04"
        case "05", "005": return "NETP3-05"
        case "06", "006": return "NETP3-06"
        case "07", "007": return "NETP3-07"
        default: return unitCode.hasPrefix("NETP3-") ? unitCode : "NETP3-\(unitCode)"
        }
    }
    
    init(qualificationType: QualificationType, url: URL) {
        self.qualificationType = qualificationType
        self.url = url
        
        // Set appropriate default unit based on qualification type
        let defaultUnit = qualificationType == .eal ? "NETP3-01" : "Unit 311"
        _selectedUnit = State(initialValue: defaultUnit)
        
        print("Initialized with qualification type: \(qualificationType), default unit: \(defaultUnit)")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text(qualificationType == .eal ? "EAL Portfolio" : "City & Guilds Portfolio")
                .font(.headline)
            
            // Unit Selection Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(units, id: \.self) { unit in
                        Button(action: {
                            selectedUnit = unit
                            isLoading = true
                            print("Selected unit: \(unit)")
                        }) {
                            Text(unit)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedUnit == unit ? Color.blue : Color(.systemGray5))
                                .foregroundColor(selectedUnit == unit ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // View Portfolio Evidence Button
            Button(action: {
                isLoading = true
                shouldReloadWebView.toggle()
            }) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                    Text("View Portfolio Evidence")
                }
                .padding()
                .background(isLoading ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoading)
            
            // WebView
            WebView(loadContent: loadContent, isLoading: $isLoading)
                .id(shouldReloadWebView)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            print("PortfolioPreviewView appeared")
            print("Qualification Type: \(qualificationType)")
            print("Available units: \(units)")
            print("Selected unit: \(selectedUnit)")
        }
    }
}

// WebView struct to handle the preview
struct WebView: UIViewRepresentable {
    let loadContent: (WKWebView) -> Void
    @Binding var isLoading: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        loadContent(webView)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                print("❌ WebView failed: \(error.localizedDescription)")
            }
        }
    }
}

// Add this enum to define qualification types
enum QualificationType {
    case eal
    case cityAndGuilds
} 