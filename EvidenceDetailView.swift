import SwiftUI
import QuickLook

struct EvidenceDetailView: UIViewControllerRepresentable {
    let evidence: Evidence
    @State private var localURL: URL?
    @State private var isLoading = true
    @StateObject private var evidenceManager = EvidenceManager.shared
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        
        Task {
            do {
                // Check if we already have the file locally
                if let localFile = evidence.localFileURL,
                   FileManager.default.fileExists(atPath: localFile.path) {
                    print("📄 Preview: Using cached file: \(localFile.path)")
                    await MainActor.run {
                        self.localURL = localFile
                        self.isLoading = false
                        controller.reloadData()
                    }
                    return
                }
                
                // If not local, download from SharePoint
                if let sharePointURL = evidence.sharePointURL {
                    print("📄 Preview: Downloading from SharePoint...")
                    let downloadedURL = try await evidenceManager.downloadFile(from: sharePointURL)
                    
                    // Verify the file was downloaded
                    guard FileManager.default.fileExists(atPath: downloadedURL.path) else {
                        throw NSError(domain: "Preview", code: -1, 
                                    userInfo: [NSLocalizedDescriptionKey: "Downloaded file not found"])
                    }
                    
                    await MainActor.run {
                        print("📄 Preview: File downloaded to: \(downloadedURL.path)")
                        self.localURL = downloadedURL
                        self.isLoading = false
                        controller.reloadData()
                    }
                }
            } catch {
                print("⚠️ Preview failed: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {
        if localURL != nil {
            uiViewController.reloadData()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(evidence: evidence, localURL: $localURL, isLoading: $isLoading)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let evidence: Evidence
        @Binding var localURL: URL?
        @Binding var isLoading: Bool
        
        init(evidence: Evidence, localURL: Binding<URL?>, isLoading: Binding<Bool>) {
            self.evidence = evidence
            self._localURL = localURL
            self._isLoading = isLoading
            super.init()
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return isLoading ? 0 : (localURL != nil ? 1 : 0)
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            guard let url = localURL else {
                fatalError("No URL available for preview")
            }
            print("📄 Previewing file at: \(url)")
            return url as QLPreviewItem
        }
    }
} 