import Foundation

class UnitRequirements {
    static let shared = UnitRequirements()
    
    private let requirements: [String: UnitRequirement] = [
        "UNIT1": UnitRequirement(minimumEvidence: 2),
        "UNIT2": UnitRequirement(minimumEvidence: 4),
        "UNIT3": UnitRequirement(minimumEvidence: 2),
        // Add other units as needed
    ]
    
    func getRequirements(for unitCode: String) -> UnitRequirement? {
        return requirements[unitCode]
    }
}

struct UnitRequirement {
    let minimumEvidence: Int
} 
