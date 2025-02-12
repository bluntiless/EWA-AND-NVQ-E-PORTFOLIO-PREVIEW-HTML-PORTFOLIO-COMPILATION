private func standardizeUnitCode(_ code: String) -> String {
    // First replace slashes with hyphens
    var formatted = code.replacingOccurrences(of: "/", with: "-")
    // Then replace underscores with hyphens
    formatted = formatted.replacingOccurrences(of: "_", with: "-")
    return formatted
}

// 1. Add 2357 data structures
struct LearningOutcome {
    let number: Int
    let description: String
    let performanceCriteria: [PerformanceCriteria]
}

struct PerformanceCriteria {
    let number: Int
    let description: String
    let isComplete: Bool
}

// 2. Modify generatePreviewHTML to handle 2357 units
private func generatePreviewHTML(for evidence: [Evidence], in unitCode: String) -> String {
    print("🔄 Generating preview HTML for unit: \(unitCode)")
    
    if let unit = getUnit(for: unitCode) {
        var html = generateHTMLHeader(for: unitCode)
        
        // Add unit details
        html += """
            <h2>\(unit.title)</h2>
            <p>\(unit.description)</p>
            <div class="evidence-container">
        """
        
        // Group evidence by Learning Outcome
        let groupedEvidence = Dictionary(grouping: evidence) { $0.learningOutcome }
        
        // Generate tables for each Learning Outcome
        for lo in unit.learningOutcomes {
            let loEvidence = groupedEvidence[lo.number] ?? []
            html += generateLearningOutcomeTable(lo: lo, evidence: loEvidence)
        }
        
        html += "</div></body></html>"
        
        // Verify HTML content
        print("📝 Generated HTML length: \(html.count)")
        return html
    } else {
        print("❌ Failed to get unit: \(unitCode)")
        return generateErrorHTML(for: unitCode)
    }
}

private func generateHTMLHeader(for unitCode: String) -> String {
    return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Unit \(unitCode) Evidence Preview</title>
            <style>
                body { font-family: -apple-system, sans-serif; padding: 20px; }
                table { width: 100%; border-collapse: collapse; margin: 20px 0; }
                th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
                th { background-color: #f5f5f5; }
                .complete { background-color: #e8f5e9; }
                .evidence-container { margin-top: 20px; }
            </style>
        </head>
        <body>
        <h1>Unit \(unitCode) Evidence Preview</h1>
    """
}

private func generateLearningOutcomeTable(lo: LearningOutcome, evidence: [Evidence]) -> String {
    var html = """
        <h2>Learning Outcome \(lo.number): \(lo.title)</h2>
        <table>
            <tr>
                <th>Criteria</th>
                <th>Description</th>
                <th>Evidence</th>
                <th>Status</th>
            </tr>
    """
    
    for pc in lo.performanceCriteria {
        // For 2357 units, match on just the numeric part of the code
        let matchingEvidence = evidence.filter { evidence in
            if pc.code.contains("2357-") {
                // Extract numeric part from both codes for comparison
                let pcNumber = pc.code.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                let evidenceNumber = evidence.criteriaCode.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                return pcNumber == evidenceNumber
            } else {
                return evidence.criteriaCode == pc.code
            }
        }
        
        let isComplete = matchingEvidence.contains { $0.isApproved }
        let rowClass = isComplete ? "complete" : ""
        
        html += """
            <tr class="\(rowClass)">
                <td>\(pc.code)</td>
                <td>\(pc.description)</td>
                <td>\(matchingEvidence.map { $0.id.uuidString }.joined(separator: ", "))</td>
                <td>\(isComplete ? "Complete" : "Incomplete")</td>
            </tr>
        """
    }
    
    html += "</table>"
    return html
}

// 3. Add helper functions
private func generate2357Content(for evidence: [Evidence], unitCode: String) -> String {
    let unitData = get2357UnitData(unitCode)
    var html = ""
    
    // Generate LO and PC content
    // ... implementation details to follow
    
    return html
}

private func get2357UnitData(_ unitCode: String) -> (learningOutcomes: [LearningOutcome], title: String) {
    // ... implementation details to follow
}

private func getFullUnitCode(_ code: String) -> String {
    let standardized = standardizeUnitCode(code)
    if standardized.hasPrefix("NETP3-") {
        return standardized
    }
    // Handle numeric-only codes
    if let number = standardized.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(),
       !number.isEmpty {
        return "NETP3-\(number.padLeft(toLength: 2, withPad: "0"))"
    }
    return standardized
}

// Helper extension for padding numbers
extension String {
    func padLeft(toLength length: Int, withPad pad: String = " ") -> String {
        guard count < length else { return self }
        return String(repeating: pad, count: length - count) + self
    }
}

func compilePortfolio(evidence: [Evidence], to destinationURL: URL) async throws {
    let fileManager = FileManager.default
    
    print("📝 Starting portfolio compilation to: \(destinationURL.path)")
    
    // Create a unique directory name with timestamp
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
    let timestamp = formatter.string(from: Date())
    let portfolioName = "Portfolio-\(timestamp)"
    
    // Create temporary directory
    let tempBaseURL = fileManager.temporaryDirectory
    let tempURL = tempBaseURL.appendingPathComponent(portfolioName)
    
    print("📁 Creating temp directory at: \(tempURL.path)")
    
    do {
        // Create temp directory
        try fileManager.createDirectory(
            at: tempURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        // Generate portfolio content
        let groupedEvidence = Dictionary(grouping: evidence) { $0.unitCode }
        print("📊 Found \(groupedEvidence.count) units to process")
        
        for (unitCode, unitEvidence) in groupedEvidence {
            let standardizedUnitCode = standardizeUnitCode(unitCode)
            print("🔄 Processing unit: \(standardizedUnitCode) with \(unitEvidence.count) evidence items")
            
            let unitURL = tempURL.appendingPathComponent(standardizedUnitCode)
            try fileManager.createDirectory(at: unitURL, withIntermediateDirectories: true)
            
            // Generate preview HTML
            let previewHTML = generatePreviewHTML(for: unitEvidence, in: standardizedUnitCode)
            let previewPath = unitURL.appendingPathComponent("preview.html")
            
            print("💾 Saving preview HTML to: \(previewPath.path)")
            try previewHTML.write(
                to: previewPath,
                atomically: true,
                encoding: .utf8
            )
            
            // Verify the file was created
            if fileManager.fileExists(atPath: previewPath.path) {
                print("✅ Successfully saved preview for unit: \(standardizedUnitCode)")
            } else {
                print("⚠️ Failed to verify preview file for unit: \(standardizedUnitCode)")
            }
        }
        
        // If destination exists, remove it first
        if fileManager.fileExists(atPath: destinationURL.path) {
            print("🗑️ Removing existing portfolio at destination")
            try fileManager.removeItem(at: destinationURL)
        }
        
        // Move compiled portfolio to destination
        print("📦 Moving portfolio to final destination")
        try fileManager.moveItem(at: tempURL, to: destinationURL)
        
        // Verify final structure
        let contents = try fileManager.contentsOfDirectory(atPath: destinationURL.path)
        print("📋 Final portfolio contents: \(contents)")
        
    } catch {
        print("❌ Portfolio compilation failed: \(error)")
        // Clean up temp directory if it exists
        try? fileManager.removeItem(at: tempURL)
        throw error
    }
}

let requiresTwoOccasions = [
    "NETP3-01", 
    "NETP3-03", 
    "NETP3-04", 
    "NETP3-05",
    "NETP3-06", 
    "NETP3-07"
].contains(unitCode)

private func getUnit(for unitCode: String) -> Unit? {
    print("📝 Looking up unit: \(unitCode)")
    
    // Standardize the unit code first
    let standardizedCode = standardizeUnitCode(unitCode)
    
    // Try to find the unit based on its type
    let unit: Unit? = {
        switch standardizedCode {
        case let code where code.hasPrefix("NETP3-"):
            return EALUnits.ewaUnits.first(where: { $0.code == code })
            
        case let code where code.hasPrefix("ELTP3-"):
            return EALUnits.ewaUnits.first(where: { $0.code == code })
            
        case let code where code.hasPrefix("2357-"):
            return cityAndGuilds2357Units.first(where: { $0.code == code })
            
        case let code:
            // Try numeric codes with different prefixes
            if let numericOnly = code.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(),
               !numericOnly.isEmpty {
                // Try 2357 format first
                let code2357 = "2357-\(numericOnly)"
                if let unit = cityAndGuilds2357Units.first(where: { $0.code == code2357 }) {
                    return unit
                }
                
                // Try NETP3 format
                let codeNETP3 = "NETP3-\(numericOnly.padLeft(toLength: 2, withPad: "0"))"
                if let unit = EALUnits.ewaUnits.first(where: { $0.code == codeNETP3 }) {
                    return unit
                }
                
                // Try ELTP3 format
                let codeELTP3 = "ELTP3-\(numericOnly.padLeft(toLength: 3, withPad: "0"))"
                return EALUnits.ewaUnits.first(where: { $0.code == codeELTP3 })
            }
            return nil
        }
    }()
    
    if let unit = unit {
        print("✅ Found unit: \(unit.title)")
        print("📊 Learning Outcomes: \(unit.learningOutcomes.count)")
    } else {
        print("❌ No unit found for code: \(standardizedCode)")
    }
    
    return unit
} 