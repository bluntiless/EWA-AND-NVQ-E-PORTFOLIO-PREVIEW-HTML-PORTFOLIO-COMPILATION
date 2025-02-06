import Foundation
import SwiftUI

// Add this to handle file operations more safely
enum FileOperationError: Error {
    case fileNotFound
    case accessDenied
    case invalidDestination
}

enum PortfolioCompilationError: Error {
    case directoryCreationFailed
    case fileCopyFailed(String)
    case indexWriteFailed
    case fileOperationError(FileOperationError)
}

extension PortfolioCompilationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .directoryCreationFailed:
            return "Failed to create portfolio directory"
        case .fileCopyFailed(let filename):
            return "Failed to copy file: \(filename)"
        case .indexWriteFailed:
            return "Failed to create index file"
        case .fileOperationError(let error):
            switch error {
            case .fileNotFound:
                return "Source file not found"
            case .accessDenied:
                return "Access denied to file location"
            case .invalidDestination:
                return "Invalid destination location"
            }
        }
    }
}

// Alternative fix if Evidence is in the same module:
// Move these from Evidence.swift if needed

class PortfolioCompilationService {
    static let shared = PortfolioCompilationService()
    
    private func getLearningOutcome(from criteriaCode: String) -> String {
        // Extract learning outcome number from criteria code (e.g., "1" from "1.1" or "1.1a")
        let components = criteriaCode.split(separator: ".")
        return String(components.first ?? "")
    }
    
    // Move these to class level
    private func getStatusDisplay(status: Evidence.AssessmentStatus) -> (class: String, text: String) {
        switch status {
        case .approved:
            return ("approved", "Approved")
        case .needsRevision:
            return ("revision", "Needs Revision")
        case .rejected:
            return ("rejected", "Rejected")
        case .pending:
            return ("pending", "No Evidence")
        }
    }
    
    private func getStatusText(for status: Evidence.AssessmentStatus) -> String {
        switch status {
        case .approved: return "✓ Approved"
        case .needsRevision: return "⚠️ Revision"
        case .rejected: return "✗ Rejected"
        case .pending: return "⏳ Pending"
        }
    }
    
    private func getStatusClass(for status: Evidence.AssessmentStatus) -> String {
        switch status {
        case .approved: return "approved"
        case .needsRevision: return "revision"
        case .rejected: return "rejected"
        case .pending: return "pending"
        }
    }
    
    private func generatePreviewHTML(for evidence: [Evidence], in unitCode: String) -> String {
        print("🔄 Generating preview HTML for unit: \(unitCode)")
        
        // Get learning outcomes first to verify we have content
        let learningOutcomes = getUnitLearningOutcomes(for: unitCode)
        if learningOutcomes.isEmpty {
            print("⚠️ No learning outcomes found for unit: \(unitCode)")
        } else {
            print("✅ Found \(learningOutcomes.count) learning outcomes")
        }
        
        // Create a cache of approved evidence to maintain consistency
        let approvedEvidenceCache = NSCache<NSString, NSNumber>()
        
        // Group evidence by criteria code and maintain approved status
        let evidenceByCriteria = Dictionary(grouping: evidence) { evidence in
            // Cache approved status when found
            if evidence.effectiveStatus == .approved {
                approvedEvidenceCache.setObject(true, forKey: evidence.id.uuidString as NSString)
            }
            return evidence.criteriaCode
        }
        
        #if DEBUG
        print("\n=== Evidence Mapping Debug ===")
        print("Unit: \(unitCode)")
        print("Total Evidence Items: \(evidence.count)")
        #endif
        
        let requiresTwoOccasions = ["NETP3-01", "NETP3-03", "NETP3-04", "NETP3-06", "NETP3-07"].contains(unitCode)
        
        // Get approved criteria directly from evidence
        let approvedCriteria = evidenceByCriteria.filter { _, items in
            let approvedCount = items.filter { $0.effectiveStatus == .approved }.count
            return approvedCount >= (requiresTwoOccasions ? 2 : 1)
        }
        
        #if DEBUG
        print("\n=== Evidence Status Debug ===")
        print("Unit: \(unitCode)")
        print("Total Evidence: \(evidence.count)")
        print("Approved Criteria: \(approvedCriteria.count) of \(evidenceByCriteria.count)")
        #endif
        
        func generateTableRow(code: String, description: String, criteriaEvidence: [Evidence]) -> String {
            // Get all evidence that matches this criteria code
            let matchingEvidence = evidence.filter { evidence in
                let shortCode = code.split(separator: "-").last?.description ?? code
                let unitPrefix = code.split(separator: "-").first?.description ?? ""
                
                return evidence.criteriaArray.contains(shortCode) || 
                       evidence.criteriaCode == shortCode ||
                       evidence.criteriaArray.contains("\(unitPrefix)-\(shortCode)") ||
                       evidence.criteriaArray.contains(code)
            }
            
            let sortedEvidence = matchingEvidence.sorted { $0.uploadDate ?? Date() < $1.uploadDate ?? Date() }
            
            // Only count evidence that is actually approved
            let approvedEvidence = sortedEvidence.filter { evidence in
                evidence.assessmentStatus == .approved
            }
            
            var row = """
                <tr>
                    <td class="criteria-number">\(code)</td>
                    <td class="criteria-desc">\(description)</td>
            """
            
            // First occasion
            if let firstEvidence = approvedEvidence.first {
                row += """
                    <td class="evidence-box approved">
                        Approved
                    </td>
                """
            } else {
                row += """
                    <td class="evidence-box pending">
                        No Evidence
                    </td>
                """
            }
            
            // Second occasion - always show this column
            if let secondEvidence = approvedEvidence.dropFirst().first {
                row += """
                    <td class="evidence-box approved">
                        Approved
                    </td>
                """
            } else {
                row += """
                    <td class="evidence-box pending">
                        No Evidence
                    </td>
                """
            }
            
            // Complete status
            let isComplete = approvedEvidence.count >= (requiresTwoOccasions ? 2 : 1)
            row += """
                <td class="complete-box \(isComplete ? "approved" : "")">
                    \(isComplete ? "Complete" : "")
                </td>
            """
            
            return row + "</tr>"
        }
        
        // HTML table headers - always show both columns for core units
        var tableHeaders = """
            <tr>
                <th class="criteria-number">Criteria</th>
                <th class="criteria-desc">Description</th>
                <th class="evidence-box">First Occasion</th>
                <th class="evidence-box">Second Occasion</th>
                <th class="complete-box">Complete</th>
            </tr>
        """
        
        // Generate the HTML with consistent styling
        var html = """
            <html>
            <head>
                <style>
                    body { 
                        font-family: Arial, sans-serif;
                        margin: 40px;
                        font-size: 11px;
                    }
                    table {
                        width: 100%;
                        border-collapse: collapse;
                        margin-bottom: 20px;
                    }
                    td {
                        border: 1px solid black;
                        padding: 8px;
                        vertical-align: middle;
                    }
                    .learning-outcome {
                        font-weight: bold;
                        margin-top: 30px;
                        margin-bottom: 10px;
                    }
                    .criteria-number {
                        width: 100px;
                        padding-left: 8px;
                    }
                    .criteria-desc {
                        padding: 8px 15px;
                    }
                    .evidence-box {
                        width: 80px;
                        min-height: 40px;
                        text-align: center;
                    }
                    .complete-box {
                        width: 80px;
                        text-align: center;
                        font-size: 11px;
                    }
                    .complete-box.approved {
                        background-color: #d4edda;
                        color: #155724;
                    }
                    .evidence-box.pending {
                        background-color: #fff3cd;
                        color: #856404;
                    }
                    .evidence-box.revision {
                        background-color: #f8d7da;
                        color: #721c24;
                    }
                    .evidence-box.rejected {
                        background-color: #dc3545;
                        color: #ffffff;
                    }
                </style>
            </head>
            <body>
            <h1>Unit \(unitCode) Evidence Preview</h1>
            <div class="status-summary">
                <p>Approved Criteria: \(approvedCriteria.count) of \(evidenceByCriteria.count)</p>
            </div>
        """
        
        // Generate tables for each learning outcome
        for (outcome, title, criteria) in learningOutcomes {
            html += """
                <div class="learning-outcome">Learning Outcome \(outcome): \(title)</div>
                <table>
                \(tableHeaders)
            """
            
            for (code, description) in criteria {
                let criteriaEvidence = evidenceByCriteria[code] ?? []
                html += generateTableRow(code: code, description: description, criteriaEvidence: criteriaEvidence)
            }
            
            html += "</table>"
        }
        
        return html + "</body></html>"
    }
    
    // Helper function to get unit-specific learning outcomes
    private func getUnitLearningOutcomes(for unitCode: String) -> [(outcome: String, title: String, criteria: [(code: String, description: String)])] {
        print("📝 Getting learning outcomes for unit: \(unitCode)")
        
        // Don't standardize the code - use it as is
        switch unitCode {
            case "NETP3-01", "01":
                print("✅ Matched NETP3-01")
                return [
                    ("1", "Be able to apply relevant health and safety legislation in the workplace", [
                        ("1.1", "Identify which workplace health and safety procedures are relevant to the working environment"),
                        ("1.2", "Produce a risk assessment and method statement in accordance with organisational procedures"),
                        ("1.3", "Work within the requirements of:"),
                        ("1.3a", "Risk assessments"),
                        ("1.3b", "Method statements"),
                        ("1.3c", "Safe systems of work")
                    ]),
                    ("2", "Be able to assess the work environment for hazards", [
                        ("2.1", "Identify unsafe situations and conditions and take remedial actions"),
                        ("2.2", "Assess work environment & revise practices taking account of hazards"),
                        ("2.2a", "Materials"),
                        ("2.2b", "Tools"),
                        ("2.2c", "Equipment"),
                        ("2.3", "Identify hazards which may present a high risk and report to relevant persons"),
                        ("2.4", "Apply measures to control health and safety hazards"),
                        ("2.5", "Select and use correct personal protective equipment")
                    ]),
                    ("3", "Be able to apply methods and procedures to ensure work on site is in accordance with health and safety legislation", [
                        ("3.1", "Demonstrate personal conduct and behaviour within the workplace"),
                        ("3.2", "Apply procedures to ensure safe use, maintenance & storage of equipment"),
                        ("3.2a", "Workplace policies"),
                        ("3.2b", "Supplier information"),
                        ("3.2c", "Manufacturer's instructions"),
                        ("3.3", "Comply with hazard warning, mandatory instruction and prohibition notices"),
                        ("3.4", "Apply procedures to ensure safety through correct use of guards and notices"),
                        ("3.5", "Use access equipment correctly")
                    ])
                ]
            case "NETP3-03", "03":
                print("✅ Matched NETP3-03")
                return [
                    ("1", "Be able to provide technical and functional information", [
                        ("1.1", "Evaluate information requirements for:"),
                        ("1.1a", "System operation"),
                        ("1.1b", "Equipment functionality"),
                        ("1.1c", "Safety requirements"),
                        ("1.2", "Identify required technical information"),
                        ("1.3", "Provide information professionally"),
                        ("1.4", "Follow organizational procedures")
                    ]),
                    ("2", "Be able to oversee Health and Safety", [
                        ("2.1", "Produce and revise risk assessments for:"),
                        ("2.1a", "Own work activities"),
                        ("2.1b", "Team activities"),
                        ("2.1c", "Other operatives in area"),
                        ("2.2", "Implement safety monitoring procedures"),
                        ("2.3", "Ensure compliance with:"),
                        ("2.3a", "Health and Safety legislation"),
                        ("2.3b", "Industry standards"),
                        ("2.3c", "Company procedures")
                    ]),
                    ("3", "Be able to coordinate work activities", [
                        ("3.1", "Coordinate with other workers/contractors"),
                        ("3.2", "Resolve work-related issues"),
                        ("3.3", "Monitor work progress"),
                        ("3.4", "Report issues outside scope of responsibility")
                    ]),
                    ("4", "Be able to organize and monitor work", [
                        ("4.1", "Organize operatives by allocating duties based on competence"),
                        ("4.2", "Monitor work to ensure compliance with:"),
                        ("4.2a", "Programme of work"),
                        ("4.2b", "Cost effectiveness"),
                        ("4.2c", "Industry working practices"),
                        ("4.2d", "Health and safety requirements"),
                        ("4.3", "Apply procedures when non-compliance identified")
                    ])
                ]
            case "ELTP3-001", "ELTP3/001":
                print("✅ Matched ELTP3-001")
                return [
                    ("1", "Be able to apply relevant health and safety legislation in the workplace", [
                        ("1.1", "Identify which workplace health and safety procedures are relevant to the working environment"),
                        ("1.2", "Produce a risk assessment and method statement in accordance with organisational procedures"),
                        ("1.3", "Work within the requirements of:"),
                        ("1.3a", "Risk assessments"),
                        ("1.3b", "Method statements"),
                        ("1.3c", "Safe systems of work")
                    ]),
                    ("2", "Be able to assess the work environment for hazards", [
                        ("2.1", "Identify unsafe situations and conditions and take remedial actions"),
                        ("2.2", "Assess work environment & revise practices taking account of hazards:"),
                        ("2.2a", "Materials"),
                        ("2.2b", "Tools"),
                        ("2.2c", "Equipment"),
                        ("2.3", "Identify any hazards which may present a high risk and report their presence to relevant persons"),
                        ("2.4", "Apply measures to control health and safety hazards"),
                        ("2.5", "Select and use correct personal protective equipment")
                    ]),
                    ("3", "Be able to apply methods and procedures to ensure work on site is in accordance with health and safety legislation", [
                        ("3.1", "Demonstrate personal conduct and behaviour within the workplace"),
                        ("3.2", "Apply procedures to ensure safe use, maintenance & storage of equipment:"),
                        ("3.2a", "Workplace policies (company and site)"),
                        ("3.2b", "Supplier information"),
                        ("3.2c", "Manufacturer's instructions"),
                        ("3.3", "Comply with hazard warning, mandatory instruction and prohibition notices"),
                        ("3.4", "Apply procedures to ensure safety through correct use of guards and notices"),
                        ("3.5", "Use access equipment correctly:"),
                        ("3.5a", "Ladder"),
                        ("3.5b", "Tower scaffold or MEWP"),
                        ("3.5c", "Stepladder"),
                        ("3.5d", "Platform")
                    ]),
                    ("4", "Be able to work in accordance with environmental legislation", [
                        ("4.1", "Apply procedures for safe handling, storing & disposal of hazardous materials:"),
                        ("4.1a", "Environmental Protection Act"),
                        ("4.1b", "Hazardous Waste Regulations"),
                        ("4.1c", "Pollution Prevention and Control Act"),
                        ("4.1d", "Control of Pollution Act"),
                        ("4.1e", "Control of Noise at Work Regulations"),
                        ("4.1f", "Environment Act")
                    ])
                ]
            case "ELTP3/002", "ELTP3-002":  // Handle both formats
                return [
                    ("1", "Be able to apply environmental protection measures", [
                        ("1.1", "Apply environmental protection measures in the workplace"),
                        ("1.2", "Implement waste management procedures"),
                        ("1.3", "Follow environmental legislation requirements")
                    ]),
                    ("2", "Be able to handle and store materials and equipment", [
                        ("2.1", "Handle and store materials in accordance with:"),
                        ("2.1a", "Environmental Protection Act"),
                        ("2.1b", "Hazardous Waste Regulations"),
                        ("2.1c", "Control of Pollution Act"),
                        ("2.1d", "Control of Noise at Work Regulations"),
                        ("2.1e", "WEEE Regulations")
                    ]),
                    ("3", "Be able to apply environmental technology systems", [
                        ("3.1", "Provide information on environmental technology systems:"),
                        ("3.1a", "Solar photovoltaic"),
                        ("3.1b", "Wind energy"),
                        ("3.1c", "Micro hydro"),
                        ("3.1d", "Heat pumps"),
                        ("3.1e", "Grey water recycling"),
                        ("3.1f", "Rainwater harvesting"),
                        ("3.1g", "Biomass heating"),
                        ("3.1h", "Solar thermal hot water heating"),
                        ("3.1i", "Combined heat and power (CHP)")
                    ])
                ]
            case "ELTP3/003", "ELTP3-003":  // Handle both formats
                return [
                    ("1", "Be able to provide technical and functional information", [
                        ("1.1", "Identify relevant people that need technical/functional information"),
                        ("1.2", "Identify additional information required"),
                        ("1.2a", "Health and safety information"),
                        ("1.2b", "Isolation procedures"),
                        ("1.2c", "Contact details for further advice"),
                        ("1.3", "Liaise with relevant people to determine information needs"),
                        ("1.4", "Identify appropriate technical and functional information"),
                        ("1.5", "Provide information professionally and according to procedures")
                    ]),
                    ("2", "Be able to oversee health and safety", [
                        ("2.1", "Produce risk assessments and method statements"),
                        ("2.2", "Follow procedures that work complies with health and safety legislation")
                    ]),
                    ("3", "Be able to coordinate work activities", [
                        ("3.1", "Coordinate effectively with other workers/contractors"),
                        ("3.2", "Apply clear and accurate communication techniques")
                    ])
                ]
            case "ELTP3/004", "ELTP3-004":  // Handle both formats
                return [
                    ("1", "Be able to prepare for installation of wiring systems and enclosures", [
                        ("1.1", "Ensure health and safety of self and others in work location"),
                        ("1.2", "Select and use appropriate PPE"),
                        ("1.3", "Complete preparatory work for installation:"),
                        ("1.3a", "Interpret installation specifications"),
                        ("1.3b", "Select compatible materials and equipment"),
                        ("1.3c", "Identify suitable methods and procedures"),
                        ("1.3d", "Confirm site readiness"),
                        ("1.3e", "Verify secure storage facilities"),
                        ("1.3f", "Confirm safe isolation if required"),
                        ("1.3g", "Complete risk assessment")
                    ]),
                    ("2", "Be able to install wiring systems and enclosures", [
                        ("2.1", "Install cables according to specifications:"),
                        ("2.1a", "Single core cables"),
                        ("2.1b", "Multicore cables"),
                        ("2.1c", "PVC/PVC flat profile"),
                        ("2.1d", "Steel wire armoured"),
                        ("2.1e", "Fire resistant cables"),
                        ("2.2", "Install containment systems:"),
                        ("2.2a", "PVC conduit"),
                        ("2.2b", "Metal conduit"),
                        ("2.2c", "PVC trunking"),
                        ("2.2d", "Metal trunking"),
                        ("2.2e", "Cable tray"),
                        ("2.2f", "Cable basket")
                    ]),
                    ("3", "Be able to confirm quality of completed installation", [
                        ("3.1", "Verify installations meet requirements:"),
                        ("3.1a", "Correct type and fit for purpose"),
                        ("3.1b", "Compliance with BS 7671"),
                        ("3.1c", "Meet installation specifications"),
                        ("3.1d", "Follow manufacturer instructions")
                    ])
                ]
            case "ELTP3/005", "ELTP3-005":  // Handle both formats
                return [
                    ("1", "Be able to prepare for termination and connection", [
                        ("1.1", "Carry out safe isolation procedures"),
                        ("1.2", "Select appropriate tools and equipment"),
                        ("1.3", "Verify materials are correct and undamaged"),
                        ("1.4", "Confirm work area is safe and ready")
                    ]),
                    ("2", "Be able to terminate and connect conductors", [
                        ("2.1", "Terminate and connect cables:"),
                        ("2.1a", "Single core cables"),
                        ("2.1b", "Multicore cables"),
                        ("2.1c", "PVC/PVC flat profile"),
                        ("2.1d", "MICC"),
                        ("2.1e", "Fire resistant cables"),
                        ("2.1f", "Steel wire armoured"),
                        ("2.1g", "Data cables"),
                        ("2.2", "Connect to electrical equipment:"),
                        ("2.2a", "Isolators/switches"),
                        ("2.2b", "Socket outlets"),
                        ("2.2c", "Distribution boards"),
                        ("2.2d", "Consumer units"),
                        ("2.2e", "Luminaires"),
                        ("2.2f", "Control equipment")
                    ]),
                    ("3", "Be able to inspect and test completed connections", [
                        ("3.1", "Verify terminations are electrically sound"),
                        ("3.2", "Check mechanical security of connections"),
                        ("3.3", "Complete required documentation")
                    ])
                ]
            case "ELTP3/006", "ELTP3-006":  // Handle both formats
                return [
                    ("1", "Be able to prepare for inspection and testing", [
                        ("1.1", "Carry out safe isolation procedures"),
                        ("1.2", "Select appropriate test instruments"),
                        ("1.3", "Verify test instruments are calibrated"),
                        ("1.4", "Complete risk assessment for testing")
                    ]),
                    ("2", "Be able to carry out inspection", [
                        ("2.1", "Complete visual inspection to BS 7671"),
                        ("2.2", "Record inspection results accurately"),
                        ("2.3", "Identify and report non-compliant items")
                    ]),
                    ("3", "Be able to test installations", [
                        ("3.1", "Perform tests in correct sequence:"),
                        ("3.1a", "Continuity testing"),
                        ("3.1b", "Insulation resistance"),
                        ("3.1c", "Polarity"),
                        ("3.1d", "Earth fault loop impedance"),
                        ("3.1e", "RCD operation"),
                        ("3.1f", "Functional testing"),
                        ("3.2", "Record test results accurately"),
                        ("3.3", "Compare results with required values")
                    ]),
                    ("4", "Be able to complete documentation", [
                        ("4.1", "Complete electrical installation certificates"),
                        ("4.2", "Complete inspection schedules"),
                        ("4.3", "Complete test result schedules"),
                        ("4.4", "Provide documentation to relevant persons")
                    ])
                ]
            case "ELTP3/007", "ELTP3-007":  // Handle both formats
                return [
                    ("1", "Be able to prepare for fault diagnosis", [
                        ("1.1", "Gather information about reported faults"),
                        ("1.2", "Select appropriate test instruments"),
                        ("1.3", "Carry out safe isolation procedures"),
                        ("1.4", "Complete risk assessment")
                    ]),
                    ("2", "Be able to diagnose faults", [
                        ("2.1", "Use logical fault finding procedures"),
                        ("2.2", "Select appropriate test methods"),
                        ("2.3", "Interpret test results correctly"),
                        ("2.4", "Identify fault locations"),
                        ("2.5", "Record findings accurately")
                    ]),
                    ("3", "Be able to rectify faults", [
                        ("3.1", "Select appropriate repair methods"),
                        ("3.2", "Obtain required replacement parts"),
                        ("3.3", "Repair or replace faulty items"),
                        ("3.4", "Test repaired circuits"),
                        ("3.5", "Restore supply safely"),
                        ("3.6", "Complete required documentation")
                    ])
                ]
            case "NETP3-04":
                return [
                    ("04-1", "Prepare to install wiring systems, enclosures and associated equipment", [
                        ("04-1.1", "Assess and apply appropriate procedures to include:"),
                        ("04-1.1a", "Adopting appropriate PPE"),
                        ("04-1.1b", "Following a safe system of work"),
                        ("04-1.1c", "Selecting appropriate tools/equipment for the task"),
                        ("04-1.2", "Prepare to install wiring systems, enclosures & equipment:"),
                        ("04-1.2a", "Confirm secure site storage facilities for tools, equipment, materials and components"),
                        ("04-1.2b", "Select materials (equipment and components) in accordance with the installation specification"),
                        ("04-1.2c", "Report any pre-work damage/defects to existing or building features, to the relevant person"),
                        ("04-1.2d", "Confirm site readiness for installation work to begin"),
                        ("04-1.2e", "Confirm authorisation for the installation work to start"),
                        ("04-1.3", "Use documentation to confirm materials and equipment is correct quantity and free from damage"),
                        ("04-1.4", "Ensure planned locations are compatible with other building services"),
                        ("04-1.5", "Check the planned locations for the wiring system in terms of:"),
                        ("04-1.5a", "Cosmetic appearance"),
                        ("04-1.5b", "External influences")
                    ]),
                    ("04-2", "Interpret appropriate information for installation", [
                        ("04-2.1", "Use sources of information to enable the installation of wiring systems:"),
                        ("04-2.1a", "Specifications"),
                        ("04-2.1b", "Work schedules/programmes"),
                        ("04-2.1c", "Manufacturer instructions"),
                        ("04-2.1d", "Layout Drawings"),
                        ("04-2.1e", "Other appropriate source of information (e.g BS 7671, other plans or diagrams 'approved documents', building regulations)")
                    ]),
                    ("04-3", "Install wiring systems and equipment", [
                        ("04-3.1", "Use appropriate measuring and marking out techniques"),
                        ("04-3.2", "Install cables in accordance with BS7671:"),
                        ("04-3.2a", "Single core (singles)"),
                        ("04-3.2b", "Multicore insulated"),
                        ("04-3.2c", "PVC - PVC flat profile cable"),
                        ("04-3.2d", "MICC"),
                        ("04-3.2e", "Fire performance"),
                        ("04-3.2f", "SWA cable"),
                        ("04-3.2g", "GSWB galvanised steel wire braid"),
                        ("04-3.2h", "Data"),
                        ("04-3.3", "Install the following in accordance with BS7671:"),
                        ("04-3.3a", "PVC Conduit"),
                        ("04-3.3b", "Metallic Conduit"),
                        ("04-3.3c", "PVC Trunking"),
                        ("04-3.3d", "Metallic Trunking"),
                        ("04-3.3e", "Cable Tray"),
                        ("04-3.3f", "Cable Basket"),
                        ("04-3.3g", "Ladder systems"),
                        ("04-3.3h", "Ducting"),
                        ("04-3.3i", "Modular wiring systems"),
                        ("04-3.3j", "Busbar systems or Powertrack"),
                        ("04-3.4", "Install in accordance to installation spec, manufacturers' instructions:"),
                        ("04-3.4a", "Isolators /switches"),
                        ("04-3.4b", "Socket-outlets"),
                        ("04-3.4c", "Distribution-boards / consumer control units"),
                        ("04-3.4d", "Overcurrent protective devices"),
                        ("04-3.4e", "Luminaires"),
                        ("04-3.4f", "Data socket outlets"),
                        ("04-3.4g", "Other appropriate equipment"),
                        ("04-3.5", "Communicate with others professionally during installation"),
                        ("04-3.6", "Dispose of waste materials in accordance with requirements")
                    ]),
                    ("04-4", "Confirm quality of completed work", [
                        ("04-4.1", "Ensure installed wiring system/s & enclosure/s meet specified requirements:"),
                        ("04-4.1a", "Are the correct type and fit for purpose"),
                        ("04-4.1b", "Are installed in accordance with BS 7671"),
                        ("04-4.1c", "Meet the installation specification/other relevant plans/instructions"),
                        ("04-4.1d", "Are installed in accordance with any relevant manufacturer instructions")
                    ])
                ]
            case "NETP3-05":
                return [
                    ("05-1", "Preparation and Safety", [
                        ("05-1.1", "Evaluate and apply appropriate procedures to include:"),
                        ("05-1.1a", "Selecting appropriate tools/equipment to enable termination and connection"),
                        ("05-1.1b", "Adopting appropriate PPE"),
                        ("05-1.1c", "Following a safe system of work (e.g. risk assessment, method statement, permit to work procedure)"),
                        ("05-1.2", "Assess/confirm it is safe to complete termination & connection in terms of:"),
                        ("05-1.2a", "Checking for presence of supply/carrying out safe isolation"),
                        ("05-1.2b", "Mechanical soundness of the electrical equipment to be connected to"),
                        ("05-1.2c", "Checking for unsafe situations")
                    ]),
                    ("05-2", "Termination and Connection", [
                        ("05-2.1", "Terminate/connect cables/conductors according to instructions/18th/specs:"),
                        ("05-2.1a", "Single core cable (singles)"),
                        ("05-2.1b", "Multicore insulated cable"),
                        ("05-2.1c", "PVC / PVC flat profile cable (twin and earth)"),
                        ("05-2.1d", "MICC cable"),
                        ("05-2.1e", "Fire performance (such as FP 200 etc.)"),
                        ("05-2.1f", "SWA cable"),
                        ("05-2.1g", "GSWB galvanised steel wire braid"),
                        ("05-2.1h", "Data cable"),
                        ("05-2.2", "Connect equipment according to instructions/18th/drawings/specs:"),
                        ("05-2.2a", "Isolators /switches"),
                        ("05-2.2b", "Socket outlets"),
                        ("05-2.2c", "Distribution-boards / consumer control units"),
                        ("05-2.2d", "Luminaires"),
                        ("05-2.2e", "Electric motors / motor control equipment"),
                        ("05-2.2f", "Overcurrent protective devices"),
                        ("05-2.2g", "Earthing terminals"),
                        ("05-2.2h", "Control panels"),
                        ("05-2.2i", "Data socket outlets or data connections"),
                        ("05-2.2j", "Fire detection/alarm components"),
                        ("05-2.2k", "Other appropriate equipment (such as: heating system components etc.)"),
                        ("05-2.3", "Terminate and connect conductors, using appropriate methods:"),
                        ("05-2.3a", "Screwing"),
                        ("05-2.3b", "Crimping"),
                        ("05-2.3c", "Soldering"),
                        ("05-2.3d", "Non-screw compression"),
                        ("05-2.3e", "Insulation displacement")
                    ])
                ]
            case "NETP3-06":
                return [
                    ("06-1", "Be able to confirm safety of the system and equipment prior to completion of inspection, testing and commissioning", [
                        ("06-1.1", "Carry out safe isolation procedures in accordance with regulatory requirements"),
                        ("06-1.2", "Ensure the health and safety of themselves and others within the work location"),
                        ("06-1.3", "Check the safety of electrical systems prior to inspection, testing and commissioning")
                    ]),
                    ("06-2", "Be able to inspect electrical systems and equipment", [
                        ("06-2.1", "Assess whether the safe system of work is appropriate to the work activity"),
                        ("06-2.2", "Carry out visual inspection in accordance with BS 7671 and IET Guidance Note 3"),
                        ("06-2.3", "Complete a schedule of inspections in accordance with BS 7671 and IET Guidance Note 3")
                    ]),
                    ("06-3", "Be able to test and commission electrical systems and equipment", [
                        ("06-3.1", "Select the correct test instruments and accessories for tests"),
                        ("06-3.2", "Test according to installation specification & BS 7671 & instructions:"),
                        ("06-3.2a", "Continuity"),
                        ("06-3.2b", "Insulation resistance"),
                        ("06-3.2c", "Polarity"),
                        ("06-3.2d", "Earth fault loop impedance/earth electrode"),
                        ("06-3.2e", "Prospective fault current"),
                        ("06-3.2f", "RCD operation"),
                        ("06-3.2g", "Functional testing"),
                        ("06-3.3", "Analyse & Verify test results to relevant persons:"),
                        ("06-3.3a", "Representatives of other services/colleagues"),
                        ("06-3.3b", "Customers/clients"),
                        ("06-3.4", "Complete in accordance with BS7671 and IET Guidance note 3:"),
                        ("06-3.4a", "Electrical Installation Certificate (+ Schedule of Inspections and Schedule of Test Results)"),
                        ("06-3.4b", "Minor Electrical Installation Works Certificate")
                    ])
                ]
            case "NETP3-07":
                return [
                    ("07-1", "Prepare to carry out fault diagnosis", [
                        ("07-1.1", "Check it is safe to carry out fault diagnosis"),
                        ("07-1.2", "Inform relevant personnel of the fault diagnosis work"),
                        ("07-1.3", "Carry out the safe isolation procedure"),
                        ("07-1.4", "Evaluate and apply appropriate methods to ensure safety")
                    ]),
                    ("07-2", "Carry out fault diagnosis", [
                        ("07-2.1", "Communicate effectively with relevant personnel to ascertain fault nature"),
                        ("07-2.2", "Select and interpret appropriate documents for electrical systems"),
                        ("07-2.3", "Assess and communicate potential disruption from fault diagnosis"),
                        ("07-2.4", "Carry out relevant inspections analyzing findings"),
                        ("07-2.5", "Confirm test instruments are fit for purpose and calibrated"),
                        ("07-2.6", "Suitable diagnostic test to identify fault:"),
                        ("07-2.6a", "Loss of supply"),
                        ("07-2.6b", "Overload"),
                        ("07-2.6c", "Short-circuit"),
                        ("07-2.6d", "Earth fault"),
                        ("07-2.6e", "Incorrect phase rotation"),
                        ("07-2.6f", "High resistance joints/loose terminations"),
                        ("07-2.6g", "Component, accessory or equipment faults"),
                        ("07-2.6h", "Open circuit"),
                        ("07-2.6i", "Signal faults"),
                        ("07-2.7", "Use appropriate methods for locating faults:"),
                        ("07-2.7a", "Using a logical approach"),
                        ("07-2.7b", "Using safe working practices"),
                        ("07-2.7c", "Interpretation of test readings"),
                        ("07-2.8", "Use appropriate instruments for fault diagnosis:"),
                        ("07-2.8a", "Voltage indicator"),
                        ("07-2.8b", "Low resistance ohm meter"),
                        ("07-2.8c", "Insulation resistance tester"),
                        ("07-2.8d", "EFLI and PFC tester"),
                        ("07-2.8e", "RCD tester"),
                        ("07-2.8f", "Ammeter"),
                        ("07-2.8g", "Phase rotation tester"),
                        ("07-2.8h", "Other appropriate instrument")
                    ]),
                    ("07-3", "Carry out fault rectification", [
                        ("07-3.1", "Assess repairs/removals/replacements/implications to:"),
                        ("07-3.1a", "Other workers/colleagues"),
                        ("07-3.1b", "Customers/clients"),
                        ("07-3.2", "Perform fault correction procedures correctly and safely"),
                        ("07-3.3", "Assess & verify replacement components & associated equipment maintain:"),
                        ("07-3.3a", "Ease of access for future maintenance"),
                        ("07-3.3b", "Compliance with relevant regulations"),
                        ("07-3.3c", "Compliance with manufacturer's instructions/procedures"),
                        ("07-3.4", "Apply procedures to ensure electrical equipment is left safe"),
                        ("07-3.5", "Establish and perform appropriate inspection and testing procedure"),
                        ("07-3.6", "Record test results & other appropriate info regarding fault correction:"),
                        ("07-3.6a", "Other workers/colleagues"),
                        ("07-3.6b", "Customers/clients"),
                        ("07-3.6c", "Representatives of other services")
                    ])
                ]
            default:
                print("⚠️ No match found for unit code: \(unitCode)")
                print("⚠️ Available cases: NETP3-01, 01, NETP3-03, 03, ELTP3-001, ELTP3/001, etc.")
                return []
        }
    }
    
    func compilePortfolio(evidence: [Evidence], to destinationURL: URL) async throws {
        let fileManager = FileManager.default
        
        // Create a unique directory name with timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        let portfolioName = "Portfolio-\(timestamp)"
        
        // Create temporary directory
        let tempBaseURL = fileManager.temporaryDirectory
        let tempURL = tempBaseURL.appendingPathComponent(portfolioName)
        
        do {
            // Create temp directory
            try fileManager.createDirectory(
                at: tempURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            // Generate portfolio content
            let groupedEvidence = Dictionary(grouping: evidence) { $0.unitCode }
            
            for (unitCode, unitEvidence) in groupedEvidence {
                let unitURL = tempURL.appendingPathComponent(unitCode)
                try fileManager.createDirectory(at: unitURL, withIntermediateDirectories: true)
                
                // Generate preview HTML
                let previewHTML = generatePreviewHTML(for: unitEvidence, in: unitCode)
                try previewHTML.write(
                    to: unitURL.appendingPathComponent("preview.html"),
                    atomically: true,
                    encoding: .utf8
                )
            }
            
            // If destination exists, remove it first
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            // Move compiled portfolio to destination
            try fileManager.moveItem(at: tempURL, to: destinationURL)
            
        } catch {
            // Clean up temp directory if it exists
            try? fileManager.removeItem(at: tempURL)
            throw error
        }
    }
    
    // Add function to upload to SharePoint when complete
    func uploadToSharePoint(portfolioURL: URL) async throws {
        // This would need to be implemented with your SharePoint authentication and upload logic
        // You'll need to use your existing SharePoint service to handle this
        throw PortfolioCompilationError.fileOperationError(.accessDenied)
    }
    
    private func standardizeUnitCode(_ code: String) -> String {
        // First standardize the format
        var formatted = code
        
        if formatted.contains("ELTP3") {
            // Handle ELTP3 format
            formatted = formatted.replacingOccurrences(of: "/", with: "-")
            formatted = formatted.replacingOccurrences(of: "_", with: "-")
            
            // Extract the number portion
            if let range = formatted.range(of: "ELTP3[/-]?\\d+", options: .regularExpression) {
                let numberPart = formatted[range].filter { $0.isNumber }
                return "ELTP3-\(numberPart.padLeft(toLength: 3, withPad: "0"))"
            }
        } else if formatted.contains("NETP3") || formatted.matches("^\\d{1,2}$") {
            // Handle NETP3 format and plain numbers (which should be NETP3)
            formatted = formatted.replacingOccurrences(of: "/", with: "-")
            formatted = formatted.replacingOccurrences(of: "_", with: "-")
            
            // If it's just a number, add NETP3 prefix
            if formatted.matches("^\\d{1,2}$") {
                return "NETP3-\(formatted.padLeft(toLength: 2, withPad: "0"))"
            }
            
            // If it already has NETP3 prefix, ensure correct format
            if formatted.hasPrefix("NETP3") {
                let numberPart = formatted.filter { $0.isNumber }
                return "NETP3-\(numberPart.padLeft(toLength: 2, withPad: "0"))"
            }
        }
        
        return formatted
    }
}

// Add safe array access extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// Add helper extension for regex matching
extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression) != nil
    }
} 

