import Foundation

struct Unit: Identifiable, Hashable {
    let id = UUID()
    let code: String          // For internal use (e.g., "ELTP3-001")
    let displayCode: String   // For UI display (e.g., "ELTP3/001")
    let reference: String     // Full reference
    let title: String
    let type: UnitType
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Unit, rhs: Unit) -> Bool {
        lhs.id == rhs.id
    }
}

enum UnitType {
    case ewa    // NETP3 units
    case nvq    // ELTP3 units
    case rpl    // RPL units
}

struct EALUnits {
    static let ewaUnits = [
        Unit(code: "NETP3-01", displayCode: "NETP3-01", reference: "NETP3-01", 
             title: "Apply Health and Safety Legislation and Working Practices", type: .ewa),
        Unit(code: "NETP3-03", displayCode: "NETP3-03", reference: "NETP3-03", 
             title: "Apply Environmental Legislation and Working Practices", type: .ewa),
        Unit(code: "NETP3-04", displayCode: "NETP3-04", reference: "NETP3-04", 
             title: "Install Electrical Equipment and Systems", type: .ewa),
        Unit(code: "NETP3-05", displayCode: "NETP3-05", reference: "NETP3-05", 
             title: "Terminate and Connect Conductors", type: .ewa),
        Unit(code: "NETP3-06", displayCode: "NETP3-06", reference: "NETP3-06", 
             title: "Inspect and Test Electrical Installations", type: .ewa),
        Unit(code: "NETP3-07", displayCode: "NETP3-07", reference: "NETP3-07", 
             title: "Diagnose and Correct Electrical Faults", type: .ewa)
    ]
    
    static let nvqUnits = [
        Unit(code: "ELTP3-001", displayCode: "ELTP3/001", reference: "ELTP3-001", 
             title: "Apply Health and Safety Legislation and Working Practices", type: .nvq),
        Unit(code: "ELTP3-002", displayCode: "ELTP3/002", reference: "ELTP3-002", 
             title: "Apply Environmental Protection Measures", type: .nvq),
        Unit(code: "ELTP3-003", displayCode: "ELTP3/003", reference: "ELTP3-003", 
             title: "Maintain Effective Working Relationships", type: .nvq),
        Unit(code: "ELTP3-004", displayCode: "ELTP3/004", reference: "ELTP3-004", 
             title: "Install Electrical Systems and Equipment", type: .nvq),
        Unit(code: "ELTP3-005", displayCode: "ELTP3/005", reference: "ELTP3-005", 
             title: "Terminate and Connect Conductors", type: .nvq),
        Unit(code: "ELTP3-006", displayCode: "ELTP3/006", reference: "ELTP3-006", 
             title: "Inspect and Test Electrical Systems", type: .nvq),
        Unit(code: "ELTP3-007", displayCode: "ELTP3/007", reference: "ELTP3-007", 
             title: "Diagnose and Correct Electrical Faults", type: .nvq)
    ]
    
    static let rplUnits = [
        Unit(code: "18ED3-02", displayCode: "18ED3-02", reference: "18ED3-02", 
             title: "RPL Unit 1", type: .rpl),
        Unit(code: "QIT3-001", displayCode: "QIT3-001", reference: "QIT3-001", 
             title: "RPL Unit 2", type: .rpl)
    ]
    
    static let allUnits = ewaUnits + nvqUnits + rplUnits
    
    static func getUnit(byCode code: String) -> Unit? {
        allUnits.first { 
            $0.code == code || 
            $0.displayCode == code || 
            $0.reference == code 
        }
    }
} 