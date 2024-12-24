import SwiftUI

struct UnitDetailView: View {
    let unit: Unit
    @State private var selectedCriteria: Set<String> = []
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Unit Details Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        DetailRow(label: "Code", value: unit.code)
                        DetailRow(label: "Title", value: unit.title)
                        DetailRow(label: "Credit Value", value: "\(unit.creditValue)")
                        DetailRow(label: "GLH", value: "\(unit.glh)")
                    }
                    .padding()
                }
                .padding()
                
                // Progress Section
                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(value: unit.progress)
                        Text("\(Int(unit.progress * 100))% Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding()
                
                // Learning Outcomes Sections
                ForEach(getLearningOutcomes(), id: \.self) { outcome in
                    LearningOutcomeSection(
                        outcome: outcome,
                        criteria: getCriteria(for: outcome),
                        selectedCriteria: $selectedCriteria,
                        isCompleted: isOutcomeCompleted(outcome)
                    )
                }
            }
        }
        .navigationTitle("Unit \(unit.code)")
        .toolbar {
            if !selectedCriteria.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink("Upload Evidence (\(selectedCriteria.count))") {
                        CriteriaEvidenceView(
                            unit: unit,
                            selectedCriteria: getSelectedCriteria()
                        )
                    }
                }
            }
        }
    }
    
    private func getLearningOutcomes() -> [String] {
        let outcomes = unit.learningOutcomes.flatMap { outcome in
            outcome.performanceCriteria.map { criteria in
                String(criteria.code.prefix(1))
            }
        }
        return Array(Set(outcomes)).sorted()
    }
    
    private func getCriteria(for outcome: String) -> [PerformanceCriteria] {
        unit.learningOutcomes.flatMap { $0.performanceCriteria }.filter { $0.code.hasPrefix(outcome) }
    }
    
    private func getSelectedCriteria() -> [PerformanceCriteria] {
        unit.learningOutcomes.flatMap { $0.performanceCriteria }.filter { selectedCriteria.contains($0.code) }
    }
    
    private func isOutcomeCompleted(_ outcome: String) -> Bool {
        let criteria = getCriteria(for: outcome)
        return !criteria.isEmpty && criteria.allSatisfy { $0.isCompleted }
    }
}

struct LearningOutcomeSection: View {
    let outcome: String
    let criteria: [PerformanceCriteria]
    @Binding var selectedCriteria: Set<String>
    let isCompleted: Bool
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Learning Outcome \(outcome.dropFirst())")  // Remove "O" prefix
                        .font(.headline)
                    Spacer()
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                ForEach(criteria) { criterion in
                    CriteriaRow(
                        criterion: criterion,
                        isSelected: selectedCriteria.contains(criterion.code)
                    ) {
                        toggleSelection(criterion)
                    }
                    Divider()
                }
            }
            .padding()
        }
        .padding()
    }
    
    private func toggleSelection(_ criterion: PerformanceCriteria) {
        if selectedCriteria.contains(criterion.code) {
            selectedCriteria.remove(criterion.code)
        } else {
            selectedCriteria.insert(criterion.code)
        }
    }
}

struct CriteriaRow: View {
    let criterion: PerformanceCriteria
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(criterion.code)
                        .font(.subheadline.bold())
                    Text(criterion.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}

// Add description property to AssessmentMethod
extension AssessmentMethod: CustomStringConvertible {
    var description: String {
        switch self {
        case .directObservation:
            return "Direct Observation"
        case .productEvidence:
            return "Product Evidence"
        case .professionalDiscussion:
            return "Professional Discussion"
        case .workRecords:
            return "Work Records"
        case .witness:
            return "Witness Testimony"
        }
    }
} 