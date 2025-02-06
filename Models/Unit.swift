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

struct LearningOutcome {
    let number: String
    let title: String
    var performanceCriteria: [PerformanceCriteria]
    
    // Add a sorted version of performance criteria
    var sortedPerformanceCriteria: [PerformanceCriteria] {
        performanceCriteria.sorted { pc1, pc2 in
            // Compare numeric parts of codes (e.g., "1.1" < "1.2")
            let pc1Numbers = pc1.code.components(separatedBy: ".")
                .compactMap { Int($0) }
            let pc2Numbers = pc2.code.components(separatedBy: ".")
                .compactMap { Int($0) }
            
            // Compare first number (e.g., 1 vs 2)
            if let first1 = pc1Numbers.first, let first2 = pc2Numbers.first {
                if first1 != first2 {
                    return first1 < first2
                }
            }
            
            // If first numbers are equal, compare second number (e.g., 1.1 vs 1.2)
            if pc1Numbers.count > 1 && pc2Numbers.count > 1 {
                return pc1Numbers[1] < pc2Numbers[1]
            }
            
            // If no second number, shorter code comes first
            return pc1Numbers.count < pc2Numbers.count
        }
    }
} 