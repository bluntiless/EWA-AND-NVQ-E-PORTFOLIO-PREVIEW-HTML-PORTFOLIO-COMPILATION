import Foundation

@MainActor
class CriteriaEvidenceViewModel: ObservableObject {
    @Published var evidenceItems: [Evidence] = []
    private let criteria: [PerformanceCriteria]
    private let evidenceManager: EvidenceManager
    
    init(criteria: [PerformanceCriteria]) {
        self.criteria = criteria
        self.evidenceManager = EvidenceManager()
        loadEvidence()
    }
    
    func addEvidence(_ evidence: Evidence) {
        evidenceManager.addEvidence(evidence)
        loadEvidence()
    }
    
    func loadEvidence() {
        let criteriaCodes = Set(criteria.map { $0.code })
        evidenceItems = evidenceManager.evidenceItems.filter { evidence in
            let evidenceCodes = Set(evidence.criteriaCode.components(separatedBy: ", "))
            return !evidenceCodes.isDisjoint(with: criteriaCodes)
        }
        objectWillChange.send()
    }
} 