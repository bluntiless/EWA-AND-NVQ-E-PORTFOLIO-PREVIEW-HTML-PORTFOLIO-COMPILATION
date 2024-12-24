import Foundation
import Combine

class Qualification: Identifiable, ObservableObject {
    let id: UUID
    let code: String
    let title: String
    let description: String
    @Published var units: [Unit]
    @Published private(set) var progress: Double = 0
    
    var cancellables = Set<AnyCancellable>()
    
    init(id: UUID = UUID(), code: String, title: String, description: String, units: [Unit]) {
        self.id = id
        self.code = code
        self.title = title
        self.description = description
        self.units = units
        updateProgress()
        
        // Observe unit changes
        for unit in units {
            unit.objectWillChange
                .sink { [weak self] _ in
                    self?.updateProgress()
                }
                .store(in: &cancellables)
        }
    }
    
    func updateProgress() {
        let totalProgress = units.reduce(into: 0.0) { result, unit in
            result += unit.progress
        }
        progress = units.isEmpty ? 0 : totalProgress / Double(units.count)
    }
}

// List of all available qualifications
let availableQualifications = [
    Qualification(
        code: "EWA",
        title: "Experienced Worker Assessment",
        description: "EAL Level 3 Electrotechnical Experienced Worker Assessment",
        units: EALUnits.ewaUnits
    ),
    Qualification(
        code: "1605",
        title: "Level 3 NVQ Diploma in Installing Electrotechnical Systems and Equipment",
        description: "EAL Level 3 NVQ Diploma in Installing Electrotechnical Systems and Equipment (1605)",
        units: EALUnits.eal1605Units
    ),
    Qualification(
        code: "2357",
        title: "Level 3 NVQ Diploma in Installing Electrotechnical Systems and Equipment",
        description: "City & Guilds 2357 Qualification",
        units: cityAndGuilds2357Units
    )
] 