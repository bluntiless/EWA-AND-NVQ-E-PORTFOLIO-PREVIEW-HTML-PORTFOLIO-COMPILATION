extension Evidence {
    var resolvedFileURL: URL? {
        // First check if we have a local file
        if let localURL = localFileURL,
           FileManager.default.fileExists(atPath: localURL.path) {
            print("📄 Using cached local file: \(localURL.path)")
            return localURL
        }
        
        // If no local file but we have a SharePoint URL, return that for downloading
        if let sharePointURL = sharePointURL {
            print("📄 No local file, will download from: \(sharePointURL)")
            return sharePointURL
        }
        
        print("⚠️ No file URL available")
        return nil
    }
    
    var localFileURL: URL? {
        guard let sharePointURL = sharePointURL else {
            return nil
        }
        
        // Extract filename from SharePoint URL
        let fileName = sharePointURL.lastPathComponent
        
        // Get app's documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Create Evidence subdirectory path
        let evidencePath = documentsPath.appendingPathComponent("Evidence", isDirectory: true)
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: evidencePath, 
                                               withIntermediateDirectories: true)
        
        // Return full local file path
        let localURL = evidencePath.appendingPathComponent(fileName)
        print("📄 Local file path: \(localURL.path)")
        return localURL
    }
} 