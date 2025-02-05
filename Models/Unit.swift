import Foundation

class Unit: ObservableObject, Identifiable {
    let id: String
    let code: String
    let title: String
    let creditValue: Int
    let glh: Int
    @Published var progress: Double = 0.0
    
    var displayCode: String {
        // Format the code consistently
        switch code {
        case "01", "001": return "NETP3-01"
        case "02", "002": return "NETP3-02"
        case "03", "003": return "NETP3-03"
        case "04", "004": return "NETP3-04"
        case "05", "005": return "NETP3-05"
        case "06", "006": return "NETP3-06"
        case "07", "007": return "NETP3-07"
        default: return code.hasPrefix("NETP3-") ? code : "NETP3-\(code)"
        }
    }
    
    init(id: String, code: String, title: String, creditValue: Int, glh: Int) {
        self.id = id
        self.code = code
        self.title = title
        self.creditValue = creditValue
        self.glh = glh
    }
    
    func updateProgressWithEvidence(_ evidenceManager: EvidenceManager) async {
        // Implementation for updating progress
    }
} 