import Foundation

class ProfileViewModel: ObservableObject {
    @Published var profile: MSALProfile?
    
    func loadProfile() async {
        // Load profile from Graph API
    }
}

struct MSALProfile: Codable {
    let displayName: String
    let mail: String?
} 