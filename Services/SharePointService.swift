import Foundation

func getEvidencePath(for unit: String, criteria: String, qualificationType: QualificationType) -> String {
    let baseFolder = "Evidence"
    let unitFolder: String
    
    switch qualificationType {
    case .eal:
        // Existing EAL logic
        unitFolder = unit.replacingOccurrences(of: "/", with: "_")
        
    case .cityAndGuilds:
        // Standardize City & Guilds unit folder names
        if unit.hasPrefix("Unit ") {
            // Extract just the number (e.g., "Unit 311" -> "311")
            unitFolder = String(unit.dropFirst(5))
        } else {
            // If it's already just the number, use it as is
            unitFolder = unit
        }
        
        // Validate that we have a valid unit number
        let validPerformanceUnits = ["311", "312", "313", "315", "316", "317", "318", "399"]
        let validKnowledgeUnits = ["601", "602", "603", "604", "605", "606", "607", "608", "609"]
        let allValidUnits = validPerformanceUnits + validKnowledgeUnits
        
        if !allValidUnits.contains(unitFolder) {
            print("⚠️ Warning: Unexpected City & Guilds unit number: \(unitFolder)")
        }
    }
    
    let path = "\(baseFolder)/\(unitFolder)/\(criteria)"
    print("📂 Generated path: \(path) for unit: \(unit)")
    return path
}

// Update the upload function to validate unit codes
func uploadEvidence(unit: String, 
                   criteria: String, 
                   fileURL: URL, 
                   qualificationType: QualificationType) async throws {
    
    let evidencePath = getEvidencePath(for: unit, 
                                     criteria: criteria, 
                                     qualificationType: qualificationType)
    
    // Validate City & Guilds paths before upload
    if qualificationType == .cityAndGuilds {
        let unitNumber = unit.replacingOccurrences(of: "Unit ", with: "")
        let validPerformanceUnits = ["311", "312", "313", "315", "316", "317", "318", "399"]
        let validKnowledgeUnits = ["601", "602", "603", "604", "605", "606", "607", "608", "609"]
        let allValidUnits = validPerformanceUnits + validKnowledgeUnits
        
        guard allValidUnits.contains(unitNumber) else {
            throw SharePointError.invalidUnitCode(
                "Invalid City & Guilds unit number: \(unitNumber)"
            )
        }
    }
    
    print("📁 Uploading to path: \(evidencePath)")
    // ... rest of upload logic ...
}

// Add error type for invalid unit codes
enum SharePointError: Error {
    case invalidUnitCode(String)
    // ... other error cases ...
} 