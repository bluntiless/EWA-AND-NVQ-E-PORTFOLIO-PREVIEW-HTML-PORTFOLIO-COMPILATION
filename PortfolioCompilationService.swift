private func standardizeUnitCode(_ code: String) -> String {
    // First replace slashes with hyphens
    var formatted = code.replacingOccurrences(of: "/", with: "-")
    // Then replace underscores with hyphens
    formatted = formatted.replacingOccurrences(of: "_", with: "-")
    return formatted
}

private func generatePreviewHTML(for evidence: [Evidence], in unitCode: String) -> String {
    // Standardize the unit code first
    let standardizedUnitCode = standardizeUnitCode(unitCode)
    
    // Update the HTML title generation
    let fullUnitCode = getFullUnitCode(standardizedUnitCode)
    var html = """
        <html>
        <head>
            <style>
                // ... existing styles ...
            </style>
        </head>
        <body>
        <h1>Unit \(fullUnitCode) Evidence Preview</h1>
    """
    
    // Rest of the preview generation code using standardizedUnitCode
    let learningOutcomes = getUnitLearningOutcomes(for: standardizedUnitCode)
    // ...
    
    html += "</body></html>"
    return html
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