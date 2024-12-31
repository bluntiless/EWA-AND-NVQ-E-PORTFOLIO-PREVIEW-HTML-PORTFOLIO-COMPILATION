import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    init() {}
    
    func fetchEvidence() async throws -> [Evidence] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let evidenceURL = documentsURL.appendingPathComponent("evidence.json")
        
        if let data = try? Data(contentsOf: evidenceURL) {
            let decoder = JSONDecoder()
            return try decoder.decode([Evidence].self, from: data)
        }
        return []
    }
    
    func updateEvidence(_ evidence: Evidence) async throws {
        var items = try await fetchEvidence()
        if let index = items.firstIndex(where: { $0.id == evidence.id }) {
            items[index] = evidence
        } else {
            items.append(evidence)
        }
        try await saveEvidence(items)
    }
    
    func deleteEvidence(_ evidence: Evidence) async throws {
        var items = try await fetchEvidence()
        items.removeAll { $0.id == evidence.id }
        try await saveEvidence(items)
        
        if let localURL = getLocalFileURL(for: evidence.id, filename: evidence.id.uuidString) {
            try? FileManager.default.removeItem(at: localURL)
        }
    }
    
    private func saveEvidence(_ items: [Evidence]) async throws {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let evidenceURL = documentsURL.appendingPathComponent("evidence.json")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(items)
        try data.write(to: evidenceURL)
    }
    
    func getLocalFileURL(for evidenceId: UUID, filename: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(evidenceId.uuidString)
    }
} 
