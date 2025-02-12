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
    @EnvironmentObject var evidenceManager: EvidenceManager
    let unit: Unit
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var approvedProgress: Double {
        let approved = evidenceManager.getApprovedEvidenceCount(for: unit.code)
        let total = getTotalRequiredCriteria(for: unit.code)
        print("Progress calculation for \(unit.code)")
        print("Approved: \(approved)")
        print("Total: \(total)")
        return Double(approved) / Double(max(1, total))
    }
    
    var pendingProgress: Double {
        let pending = evidenceManager.getPendingEvidenceCount(for: unit.code)
        let total = getTotalRequiredCriteria(for: unit.code)
        print("Pending: \(pending)")
        return Double(pending) / Double(max(1, total))
    }
    
    var progressText: String {
        let approved = evidenceManager.getApprovedEvidenceCount(for: unit.code)
        let total = getTotalRequiredCriteria(for: unit.code)
        let percentage = (Double(approved) / Double(max(1, total))) * 100
        return String(format: "%.0f%%", min(percentage, 100))
    }
    
    private func getTotalRequiredCriteria(for unitCode: String) -> Int {
        if let unit = evidenceManager.getUnit(withCode: unitCode) {
            return unit.learningOutcomes.flatMap { $0.performanceCriteria }.count
        }
        return 20 // Fallback default
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(unit.title)
                .font(.headline)
            
            HStack(spacing: 12) {
                // Progress Bar Container
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 16)
                        
                        // Pending Progress (Yellow)
                        if pendingProgress > 0 {
                            Capsule()
                                .fill(Color.yellow)
                                .frame(width: geometry.size.width * min(pendingProgress, 1.0))
                                .frame(height: 16)
                        }
                        
                        // Approved Progress (Green)
                        if approvedProgress > 0 {
                            Capsule()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * min(approvedProgress, 1.0))
                                .frame(height: 16)
                        }
                    }
                }
                .frame(height: 16)
                
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