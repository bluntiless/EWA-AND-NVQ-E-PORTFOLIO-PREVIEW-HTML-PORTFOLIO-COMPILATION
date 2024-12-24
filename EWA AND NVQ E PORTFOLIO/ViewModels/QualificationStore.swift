import Foundation
import Combine

class QualificationStore: ObservableObject {
    @Published var qualifications: [Qualification]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initialize with all available qualifications
        self.qualifications = [
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
        
        // Set up observation of unit changes
        for qualification in qualifications {
            for unit in qualification.units {
                unit.objectWillChange
                    .sink { [weak self, weak qualification] _ in
                        qualification?.updateProgress()
                        self?.objectWillChange.send()
                    }
                    .store(in: &qualification.cancellables)
            }
        }
    }
    
    // Helper method to get a qualification by code
    func qualification(withCode code: String) -> Qualification? {
        return qualifications.first { $0.code == code }
    }
    
    // Helper method to get all units for a given qualification
    func units(forQualification code: String) -> [Unit] {
        return qualification(withCode: code)?.units ?? []
    }
} 