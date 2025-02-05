import AVFoundation
import QuickLook

extension EvidenceManager {
    func generateThumbnail(for evidence: Evidence) async -> UIImage? {
        guard let url = evidence.resolvedFileURL else { return nil }
        
        switch evidence.type {
        case .video:
            return await generateVideoThumbnail(from: url)
        case .document:
            return await generateDocumentThumbnail(from: url)
        case .photo:
            return UIImage(contentsOfFile: url.path) // Existing photo handling
        case .pdf:
            return generatePDFThumbnail(from: url)
        }
    }
    
    private func generateVideoThumbnail(from url: URL) async -> UIImage? {
        do {
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                size: CGSize(width: 300, height: 300),
                scale: UIScreen.main.scale,
                representationTypes: .thumbnail
            )
            
            let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
            return thumbnail.uiImage
        } catch {
            print("Error generating video thumbnail: \(error)")
            return UIImage(systemName: "video.fill")
        }
    }
    
    private func generateDocumentThumbnail(from url: URL) async -> UIImage? {
        do {
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                size: CGSize(width: 300, height: 300),
                scale: UIScreen.main.scale,
                representationTypes: .thumbnail
            )
            
            let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
            return thumbnail.uiImage
        } catch {
            print("Error generating document thumbnail: \(error)")
            return UIImage(systemName: "doc.fill")
        }
    }
    
    private func generatePDFThumbnail(from url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL),
              let page = document.page(at: 1) else {
            return nil
        }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        let thumbnail = renderer.image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(pageRect)
            
            context.cgContext.translateBy(x: 0, y: pageRect.size.height)
            context.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            context.cgContext.drawPDFPage(page)
        }
        
        return thumbnail
    }
    
    func downloadFile(from sharePointURL: URL) async throws -> URL {
        print("📥 Starting download from SharePoint: \(sharePointURL)")
        
        // Get the download URL using Graph API
        let graphEndpoint = try await getGraphEndpoint(for: sharePointURL)
        let downloadURL = try await getDownloadURL(from: graphEndpoint)
        
        // Setup local file path
        let fileName = sharePointURL.lastPathComponent
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let evidencePath = documentsPath.appendingPathComponent("Evidence", isDirectory: true)
        let localURL = evidencePath.appendingPathComponent(fileName)
        
        print("📥 Got download URL, saving to: \(localURL.path)")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: evidencePath, withIntermediateDirectories: true)
        
        // Download the file using authenticated request
        var request = URLRequest(url: downloadURL)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (tempURL, response) = try await URLSession.shared.download(from: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NSError(domain: "Download", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Download failed"])
        }
        
        // Move to final location
        if FileManager.default.fileExists(atPath: localURL.path) {
            try FileManager.default.removeItem(at: localURL)
        }
        try FileManager.default.moveItem(at: tempURL, to: localURL)
        
        print("📥 Download complete: \(localURL.path)")
        return localURL
    }
    
    private func getGraphEndpoint(for sharePointURL: URL) async throws -> URL {
        // Convert SharePoint URL to Graph API endpoint
        // Example: https://graph.microsoft.com/v1.0/sites/{site-id}/drive/items/{item-id}
        // Implementation details...
    }
    
    private func getDownloadURL(from graphEndpoint: URL) async throws -> URL {
        // Get download URL from Graph API
        // Implementation details...
    }
    
    func refreshEvidenceStatus() async {
        print("Starting evidence status refresh")
        do {
            let updatedItems = try await storageManager.fetchEvidence()
            var modifiedItems = [Evidence]()  // Create new array for modified items
            
            for item in updatedItems {
                var modifiedItem = item  // Create mutable copy
                
                // Use the actual SharePoint URL that was saved during upload
                guard let sharePointUrl = modifiedItem.sharePointUrl else { 
                    print("No SharePoint URL for item")
                    modifiedItems.append(item)  // Keep original if no URL
                    continue 
                }
                
                do {
                    try await TeamsManager.shared.authenticate()
                    
                    // Use the exact URL that was saved during upload
                    print("Fetching metadata for: \(sharePointUrl)")
                    let metadata = try await TeamsManager.shared.fetchEvidenceMetadata(from: sharePointUrl)
                    print("Received metadata: \(metadata)")
                    
                    // Update assessment info
                    modifiedItem.updateAssessmentInfo(from: metadata)
                    
                    // Save to storage
                    try await storageManager.updateEvidence(modifiedItem)
                    modifiedItems.append(modifiedItem)
                } catch {
                    print("Error fetching metadata: \(error)")
                    modifiedItems.append(item)  // Keep original on error
                }
            }
            
            await MainActor.run {
                self.evidenceItems = modifiedItems
            }
        } catch {
            print("Error refreshing evidence status: \(error)")
        }
    }
    
    func verifyFileExists(at sharePointUrl: String) async throws -> Bool {
        do {
            // Create temporary Evidence object for metadata fetch
            let tempEvidence = Evidence(
                id: UUID(),
                criteriaCode: "",
                unitCode: "",
                dateUploaded: Date(),
                type: .photo,
                title: "",
                description: "",
                bookmarkData: nil,
                sharePointUrl: sharePointUrl,
                fileURL: nil,
                uploadDate: nil,
                associatedCriteria: [],
                criteriaDescription: "",
                assessmentStatus: .pending,
                assessorFeedback: nil,
                assessorName: nil,
                assessmentDate: nil,
                isLocallyUploaded: true
            )
            
            // Initial delay to allow SharePoint to process
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 second initial delay
            
            // Use existing metadata fetch with progressive retry
            for attempt in 1...5 {
                do {
                    print("Attempting verification (\(attempt)/5) for: \(sharePointUrl)")
                    _ = try await fetchEvidenceMetadata(for: tempEvidence)  // Changed here
                    print("✅ File verification successful on attempt \(attempt)")
                    return true
                } catch {
                    print("⚠️ Verification attempt \(attempt) failed: \(error)")
                    if attempt == 5 { return false }
                    let delay = UInt64(pow(3.0, Double(attempt)) * 1_000_000_000)
                    try await Task.sleep(nanoseconds: delay)
                }
            }
            return false
        } catch {
            print("❌ File verification failed: \(error)")
            return false
        }
    }
    
    private func formatEvidencePath(_ path: String) -> String {
        // First replace slashes with hyphens
        var formatted = path.replacingOccurrences(of: "/", with: "-")
        // Then replace underscores with hyphens for consistency
        formatted = formatted.replacingOccurrences(of: "_", with: "-")
        return formatted
    }
} 