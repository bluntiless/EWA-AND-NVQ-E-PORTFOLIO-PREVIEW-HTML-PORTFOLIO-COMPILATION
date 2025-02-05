import SwiftUI
import WebKit

struct PortfolioPreviewView: View {
    let url: URL
    @EnvironmentObject var qualificationStore: QualificationStore
    @State private var selectedUnit = "NETP3-01"  // Updated default unit
    @State private var loadError: Error?
    @State private var isLoading = true
    
    // Get all units - both performance and knowledge
    var units: [String] {
        let ewaUnits = [
            // EWA Units (NETP3 series) - Already in correct format
            "NETP3-01", "NETP3-03", "NETP3-04", 
            "NETP3-05", "NETP3-06", "NETP3-07",
            // Add RPL units
            "18ED3-02", "QIT3-001"  // Standardized format
        ]
        
        let nvqUnits = [
            // NVQ 1605 Units - Convert to NETP3 format
            "NETP3-01", "NETP3-02", "NETP3-03", 
            "NETP3-04", "NETP3-05", "NETP3-06", "NETP3-07"
        ]
        
        return ewaUnits + nvqUnits
    }
    
    private func getUnitDescription(_ unitCode: String) -> String {
        // Standardize all unit codes to NETP3 format
        switch unitCode {
        case "001", "01": return "NETP3-01"
        case "002", "02": return "NETP3-02"
        case "003", "03": return "NETP3-03"
        case "004", "04": return "NETP3-04"
        case "005", "05": return "NETP3-05"
        case "006", "06": return "NETP3-06"
        case "007", "07": return "NETP3-07"
        case "18ED3 02": return "18ED3-02"
        case "QIT3-001": return "QIT3-001"
        default: return unitCode.hasPrefix("NETP3-") ? unitCode : "NETP3-\(unitCode)"
        }
    }
    
    private func standardizeUnitCode(_ code: String) -> String {
        let description = getUnitDescription(code)
        return description.replacingOccurrences(of: "/", with: "-")
    }
    
    private func loadContent(_ webView: WKWebView) {
        // Standardize the unit code before creating the URL
        let standardizedUnit = standardizeUnitCode(selectedUnit)
        let previewURL = url.appendingPathComponent(standardizedUnit)
                           .appendingPathComponent("preview.html")
        
        print("📂 Loading preview from: \(previewURL.path)")
        
        DispatchQueue.main.async {
            do {
                let htmlString = try String(contentsOf: previewURL, encoding: .utf8)
                print("✅ Successfully loaded HTML content")
                webView.loadHTMLString(htmlString, baseURL: previewURL.deletingLastPathComponent())
            } catch {
                print("❌ Failed to load preview: \(error)")
                loadError = error
                isLoading = false
            }
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
} 