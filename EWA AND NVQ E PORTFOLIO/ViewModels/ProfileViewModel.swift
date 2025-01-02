import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var jobTitle: String = ""
    @Published var employer: String = ""
    @Published var yearsExperience: Int = 0
    
    init() {
        // Load saved values or use defaults
        self.fullName = UserDefaults.standard.string(forKey: "profile_name") ?? ""
        self.jobTitle = UserDefaults.standard.string(forKey: "profile_job") ?? ""
        self.employer = UserDefaults.standard.string(forKey: "profile_employer") ?? ""
        self.yearsExperience = UserDefaults.standard.integer(forKey: "profile_experience")
    }
    
    private func saveProfile() {
        UserDefaults.standard.set(fullName, forKey: "profile_name")
        UserDefaults.standard.set(jobTitle, forKey: "profile_job")
        UserDefaults.standard.set(employer, forKey: "profile_employer")
        UserDefaults.standard.set(yearsExperience, forKey: "profile_experience")
    }
    
    func saveProfileImage(_ data: Data) {
        UserDefaults.standard.set(data, forKey: "profile_image")
    }
    
    func getRequiredEvidenceCount(for unitCode: String) -> Int {
        let requirements = UnitRequirements.shared.getRequirements(for: unitCode)
        return requirements?.minimumEvidence ?? 1
    }
} 