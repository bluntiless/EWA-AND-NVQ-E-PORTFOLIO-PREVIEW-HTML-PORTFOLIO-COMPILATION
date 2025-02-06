import Foundation

// Create a new file for City & Guilds units
struct CityAndGuildsUnit: Identifiable, Hashable {
    let id = UUID()
    let code: String        // Internal code (e.g., "311")
    let displayCode: String // Display code (e.g., "Unit 311")
    let title: String
    let isPerformanceUnit: Bool
    
    func hash(into hasher: &Hasher) {
        hasher.combine(code)
    }
    
    static func == (lhs: CityAndGuildsUnit, rhs: CityAndGuildsUnit) -> Bool {
        lhs.code == rhs.code
    }
}

enum CityAndGuildsUnits {
    // Performance Units for 2357
    static let performanceUnits: [CityAndGuildsUnit] = [
        CityAndGuildsUnit(
            code: "311",
            displayCode: "Unit 311",
            title: "Understanding and Applying Electrical Installation Design",
            isPerformanceUnit: true
        ),
        CityAndGuildsUnit(
            code: "312",
            displayCode: "Unit 312",
            title: "Installation of Electrical Equipment",
            isPerformanceUnit: true
        ),
        CityAndGuildsUnit(
            code: "313",
            displayCode: "Unit 313",
            title: "Electrical Cable Installation",
            isPerformanceUnit: true
        ),
        CityAndGuildsUnit(
            code: "315",
            displayCode: "Unit 315",
            title: "Inspection, Testing and Commissioning",
            isPerformanceUnit: true
        ),
        CityAndGuildsUnit(
            code: "316",
            displayCode: "Unit 316",
            title: "Diagnosing and Correcting Electrical Faults",
            isPerformanceUnit: true
        ),
        CityAndGuildsUnit(
            code: "317",
            displayCode: "Unit 317",
            title: "Electrical Systems Design",
            isPerformanceUnit: true
        ),
        CityAndGuildsUnit(
            code: "318",
            displayCode: "Unit 318",
            title: "Electric Vehicle Charging Equipment",
            isPerformanceUnit: true
        ),
        CityAndGuildsUnit(
            code: "399",
            displayCode: "Unit 399",
            title: "Electrotechnical Occupational Competence (RPL)",
            isPerformanceUnit: true
        )
    ]
    
    // Knowledge Units for 2357
    static let knowledgeUnits: [CityAndGuildsUnit] = [
        CityAndGuildsUnit(
            code: "601",
            displayCode: "Unit 601",
            title: "Health and Safety in Building Services Engineering",
            isPerformanceUnit: false
        ),
        CityAndGuildsUnit(
            code: "602",
            displayCode: "Unit 602",
            title: "Understanding Environmental Protection Methods",
            isPerformanceUnit: false
        ),
        CityAndGuildsUnit(
            code: "603",
            displayCode: "Unit 603",
            title: "Understanding Scientific Principles",
            isPerformanceUnit: false
        ),
        CityAndGuildsUnit(
            code: "604",
            displayCode: "Unit 604",
            title: "Understanding Planning Methods",
            isPerformanceUnit: false
        ),
        CityAndGuildsUnit(
            code: "605",
            displayCode: "Unit 605",
            title: "Understanding Maintenance Methods",
            isPerformanceUnit: false
        ),
        CityAndGuildsUnit(
            code: "606",
            displayCode: "Unit 606",
            title: "Understanding Installation Methods",
            isPerformanceUnit: false
        ),
        CityAndGuildsUnit(
            code: "607",
            displayCode: "Unit 607",
            title: "Understanding Termination Methods",
            isPerformanceUnit: false
        ),
        CityAndGuildsUnit(
            code: "608",
            displayCode: "Unit 608",
            title: "Understanding Inspection and Testing",
            isPerformanceUnit: false
        ),
        CityAndGuildsUnit(
            code: "609",
            displayCode: "Unit 609",
            title: "Understanding Fault Diagnosis and Rectification",
            isPerformanceUnit: false
        )
    ]
    
    // Combined units for UI display
    static let units2357: [CityAndGuildsUnit] = performanceUnits + knowledgeUnits
    
    static func getUnit(byCode code: String) -> CityAndGuildsUnit? {
        // Handle both formats: "311" and "Unit 311"
        let searchCode = code.replacingOccurrences(of: "Unit ", with: "")
        return units2357.first { $0.code == searchCode || $0.displayCode == code }
    }
} 