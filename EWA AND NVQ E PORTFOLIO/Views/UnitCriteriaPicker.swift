import SwiftUI

struct UnitCriteriaPicker: View {
    let unit: Unit
    @EnvironmentObject var evidenceManager: EvidenceManager
    
    var allCriteria: [PerformanceCriteria] {
        unit.learningOutcomes.flatMap { $0.performanceCriteria }
    }
    
    var completedCriteria: Int {
        allCriteria.filter { criteria in
            let evidence = evidenceManager.getEvidenceForCriteria(criteria.code)
            return evidence.contains { $0.assessmentStatus == .approved }
        }.count
    }
    
    var body: some View {
        List {
            // Progress bar section
            Section {
                HStack(spacing: 12) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 16)
                                .cornerRadius(8)
                            
                            // Progress
                            if completedCriteria > 0 {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: geometry.size.width * (CGFloat(completedCriteria) / CGFloat(allCriteria.count)))
                                    .frame(height: 16)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                    
                    // Criteria count
                    Text("\(completedCriteria)/\(allCriteria.count)")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .trailing)
                }
                .padding(.horizontal)
            }
            
            // Existing learning outcomes sections
            ForEach(unit.learningOutcomes) { outcome in
                // ... existing outcome section code ...
            }
        }
    }
} 