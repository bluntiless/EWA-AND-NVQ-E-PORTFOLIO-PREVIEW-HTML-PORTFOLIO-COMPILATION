import SwiftUI

struct ProgressDetailView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    let qualificationStore: QualificationStore
    
    var body: some View {
        List {
            ForEach(qualificationStore.qualifications) { qualification in
                Section(header: Text(qualification.title)) {
                    ForEach(qualification.units) { unit in
                        UnitProgressRow(unit: unit)
                    }
                }
            }
        }
        .navigationTitle("Progress")
    }
}

private struct UnitProgressRow: View {
    let unit: Unit
    @EnvironmentObject var evidenceManager: EvidenceManager
    
    var approvedProgress: Double {
        let approved = evidenceManager.getApprovedEvidenceCount(for: unit.code)
        
        // Special handling for Health & Safety unit
        if unit.code == "HSE" { // Assuming "HSE" is the code for Health & Safety unit
            // Cap at 50% if only one observation is approved
            return Double(min(approved, 2)) / 2.0  // 2 observations required
        }
        
        return Double(approved) / Double(max(1, evidenceManager.getTotalEvidenceCount(for: unit.code)))
    }
    
    var pendingProgress: Double {
        let pendingCount = evidenceManager.getTotalEvidenceCount(for: unit.code) - 
                          evidenceManager.getApprovedEvidenceCount(for: unit.code)
        
        // Special handling for Health & Safety unit
        if unit.code == "HSE" {
            let approved = evidenceManager.getApprovedEvidenceCount(for: unit.code)
            return approved >= 2 ? 0 : 0.5 // Show 50% pending if not fully complete
        }
        
        return Double(pendingCount) / Double(max(1, evidenceManager.getTotalEvidenceCount(for: unit.code)))
    }
    
    var progressText: String {
        let approved = evidenceManager.getApprovedEvidenceCount(for: unit.code)
        
        // Special handling for Health & Safety unit
        if unit.code == "HSE" {
            let percentage = (Double(min(approved, 2)) / 2.0) * 100
            return String(format: "%.0f%%", percentage)
        }
        
        let total = evidenceManager.getTotalEvidenceCount(for: unit.code)
        let percentage = (Double(approved) / Double(max(1, total))) * 100
        return String(format: "%.0f%%", percentage)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(unit.title)
                .font(.headline)
            
            HStack(spacing: 12) {
                // Progress Bar Container
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                    
                    // Pending Progress (Yellow)
                    if pendingProgress > 0 {
                        Capsule()
                            .fill(Color.yellow)
                            .frame(maxWidth: .infinity)
                            .frame(height: 16)
                    }
                    
                    // Approved Progress (Green)
                    if approvedProgress > 0 {
                        Capsule()
                            .fill(Color.green)
                            .frame(width: UIScreen.main.bounds.width * 0.6 * approvedProgress)
                            .frame(height: 16)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Percentage Text
                Text(progressText)
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .trailing)
            }
            .frame(height: 24)
        }
        .padding(.vertical, 8)
    }
} 