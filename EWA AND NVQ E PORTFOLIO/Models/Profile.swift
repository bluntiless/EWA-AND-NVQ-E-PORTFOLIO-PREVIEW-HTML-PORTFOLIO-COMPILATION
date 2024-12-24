import Foundation

struct Profile: Codable {
    var id: UUID = UUID()
    var name: String
    var photoURL: URL?
    var previousQualifications: [Qualification]
    var yearsOfExperience: Int
    var jobTitle: String
    var employerName: String
    var contactEmail: String
    
    struct Qualification: Codable, Identifiable {
        var id: UUID = UUID()
        var title: String
        var awardingBody: String
        var yearCompleted: Int
    }
} 