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
            
            // First occasion status
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
            
            // Second occasion if required
            if requiresTwoOccasions {
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
            }
            
            // Complete status - only mark complete if we have enough approved evidence
            let isComplete = approvedEvidence.count >= (requiresTwoOccasions ? 2 : 1)
            row += """
                <td class="complete-box \(isComplete ? "approved" : "")">
                    \(isComplete ? "✓" : "")
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
        """
        
        // Always add second occasion for core units
        if requiresTwoOccasions {
            tableHeaders += "<th class=\"evidence-box\">Second Occasion</th>"
        }
        tableHeaders += "<th class=\"complete-box\">Complete</th></tr>"
        
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
                    }
                    .evidence-box.pending {
                        background-color: #fff3cd;
                        color: #856404;
                    }
                    .evidence-box.approved {
                        background-color: #d4edda;
                        color: #155724;
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
        let learningOutcomes = getUnitLearningOutcomes(for: unitCode)
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
        switch unitCode {
            case "NETP3-01":
                return [
                    ("01-1", "Be able to apply relevant health and safety legislation in the workplace", [
                        ("01-1.1", "Identify which workplace health and safety procedures are relevant to the working environment and comply with their duties and obligations"),
                        ("01-1.2", "Produce a risk assessment and method statement in accordance with organisational procedures"),
                        ("01-1.3", "Work within the requirements of:"),
                        ("01-1.3a", "Risk assessments"),
                        ("01-1.3b", "Method statements"),
                        ("01-1.3c", "Safe systems of work")
                    ]),
                    ("01-2", "Be able to assess the work environment for hazards", [
                        ("01-2.1", "Identify unsafe situations and conditions and take remedial actions"),
                        ("01-2.2", "Assess work environment & revise practices taking account of hazards:"),
                        ("01-2.2a", "Materials"),
                        ("01-2.2b", "Tools"),
                        ("01-2.2c", "Equipment"),
                        ("01-2.3", "Identify any hazards which may present a high risk and report their presence to relevant persons"),
                        ("01-2.4", "Apply measures to control health and safety hazards"),
                        ("01-2.5", "Select and use correct personal protective equipment")
                    ]),
                    ("01-3", "Be able to apply methods and procedures to ensure work on site is in accordance with health and safety legislation", [
                        ("01-3.1", "Demonstrate personal conduct and behaviour within the workplace"),
                        ("01-3.2", "Apply procedures to ensure safe use, maintenance & storage of equipment:"),
                        ("01-3.2a", "Workplace policies (company and site)"),
                        ("01-3.2b", "Supplier information"),
                        ("01-3.2c", "Manufacturer's instructions"),
                        ("01-3.3", "Comply with hazard warning, mandatory instruction and prohibition notices"),
                        ("01-3.4", "Apply procedures to ensure safety through correct use of guards and notices"),
                        ("01-3.5", "Use access equipment correctly:"),
                        ("01-3.5a", "Ladder"),
                        ("01-3.5b", "Tower scaffold or MEWP"),
                        ("01-3.5c", "Stepladder"),
                        ("01-3.5d", "Platform")
                    ]),
                    ("01-4", "Be able to work in accordance with environmental legislation", [
                        ("01-4.1", "Apply procedures for safe handling, storing & disposal of hazardous materials:"),
                        ("01-4.1a", "Environmental Protection Act"),
                        ("01-4.1b", "Hazardous Waste Regulations"),
                        ("01-4.1c", "Pollution Prevention and Control Act"),
                        ("01-4.1d", "Control of Pollution Act"),
                        ("01-4.1e", "Control of Noise at Work Regulations"),
                        ("01-4.1f", "Environment Act")
                    ])
                ]
            case "NETP3-03":
                return [
                    ("03-1", "Be able to provide technical and functional information", [
                        ("03-1.1", "Evaluate information requirements for:"),
                        ("03-1.1a", "System operation"),
                        ("03-1.1b", "Equipment functionality"),
                        ("03-1.1c", "Safety requirements"),
                        ("03-1.2", "Identify required technical information"),
                        ("03-1.3", "Provide information professionally"),
                        ("03-1.4", "Follow organizational procedures")
                    ]),
                    ("03-2", "Be able to oversee Health and Safety", [
                        ("03-2.1", "Produce and revise risk assessments for:"),
                        ("03-2.1a", "Own work activities"),
                        ("03-2.1b", "Team activities"),
                        ("03-2.1c", "Other operatives in area"),
                        ("03-2.2", "Implement safety monitoring procedures"),
                        ("03-2.3", "Ensure compliance with:"),
                        ("03-2.3a", "Health and Safety legislation"),
                        ("03-2.3b", "Industry standards"),
                        ("03-2.3c", "Company procedures")
                    ]),
                    ("03-3", "Be able to coordinate work activities", [
                        ("03-3.1", "Coordinate with other workers/contractors"),
                        ("03-3.2", "Resolve work-related issues"),
                        ("03-3.3", "Monitor work progress"),
                        ("03-3.4", "Report issues outside scope of responsibility")
                    ]),
                    ("03-4", "Be able to organize and monitor work", [
                        ("03-4.1", "Organize operatives by allocating duties based on competence"),
                        ("03-4.2", "Monitor work to ensure compliance with:"),
                        ("03-4.2a", "Programme of work"),
                        ("03-4.2b", "Cost effectiveness"),
                        ("03-4.2c", "Industry working practices"),
                        ("03-4.2d", "Health and safety requirements"),
                        ("03-4.3", "Apply procedures when non-compliance identified")
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
}

// Add safe array access extension
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 

