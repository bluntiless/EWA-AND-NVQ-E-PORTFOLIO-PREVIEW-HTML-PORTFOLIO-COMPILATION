import Foundation

struct LearningOutcome: Identifiable {
    let id = UUID()
    let number: String
    let title: String
    var performanceCriteria: [PerformanceCriteria]
}

class Unit: Identifiable, ObservableObject {
    let id: UUID
    let code: String
    let eltCode: String
    let reference: String
    let title: String
    let description: String
    let unitType: UnitType
    let creditValue: Int
    let glh: Int
    let startDate: Date
    let endDate: Date
    @Published var learningOutcomes: [LearningOutcome]
    let allowedAssessmentMethods: [AssessmentMethod]
    @Published var progress: Double = 0.0
    
    init(id: UUID = UUID(), code: String, eltCode: String, reference: String, title: String, description: String, unitType: UnitType, creditValue: Int, glh: Int, startDate: Date, endDate: Date, learningOutcomes: [LearningOutcome], allowedAssessmentMethods: [AssessmentMethod]) {
        self.id = id
        self.code = code
        self.eltCode = eltCode
        self.reference = reference
        self.title = title
        self.description = description
        self.unitType = unitType
        self.creditValue = creditValue
        self.glh = glh
        self.startDate = startDate
        self.endDate = endDate
        self.learningOutcomes = learningOutcomes
        self.allowedAssessmentMethods = allowedAssessmentMethods
        updateProgress()
    }
    
    func updateProgress() {
        let completedCriteria = learningOutcomes.flatMap { $0.performanceCriteria }.filter { $0.isCompleted }.count
        progress = learningOutcomes.isEmpty ? 0 : Double(completedCriteria) / Double(learningOutcomes.flatMap { $0.performanceCriteria }.count)
    }
}

enum UnitType: String, Codable {
    case performance
    case knowledge
}

enum AssessmentMethod: String, Codable {
    case directObservation = "Direct Observation"
    case productEvidence = "Product Evidence"
    case workRecords = "Work Records"
    case professionalDiscussion = "Professional Discussion"
    case witness = "Witness Testimony"
}

class PerformanceCriteria: Identifiable, ObservableObject {
    let id: UUID
    let code: String
    let description: String
    @Published var isCompleted: Bool
    
    init(code: String, description: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.code = code
        self.description = description
        self.isCompleted = isCompleted
    }
} 