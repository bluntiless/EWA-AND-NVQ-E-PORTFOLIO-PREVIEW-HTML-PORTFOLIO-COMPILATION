import SwiftUI
import PhotosUI

enum UploadError: Error {
    case verificationFailed
    case invalidPath
    case uploadFailed(String)
    case insufficientPermissions
}

struct AddEvidenceView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    let criteriaCode: String
    let unitCode: String
    let criteriaDescription: String
    let onEvidenceUploaded: (Evidence) -> Void
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var isUploading = false
    @State private var showRetryAlert = false
    @State private var retryCompletion: CheckedContinuation<Bool, Never>?
    @State private var uploadStatus = ""
    @State private var verificationAttempts = 0
    
    var body: some View {
        VStack {
            photoPickerButton
            
            if isUploading {
                uploadingProgress
            }
            
            imagePreviewScrollView
        }
        .alert("Upload Failed", isPresented: $showRetryAlert) {
            Button("Retry") {
                retryCompletion?.resume(returning: true)
                retryCompletion = nil
            }
            Button("Cancel") {
                retryCompletion?.resume(returning: false)
                retryCompletion = nil
            }
        } message: {
            Text("Some files failed to upload. Would you like to retry?")
        }
    }
    
    private var photoPickerButton: some View {
        PhotosPicker(selection: $selectedItems,
                    maxSelectionCount: 5,
                    matching: .images) {
            Label("Select Evidence", systemImage: "photo.on.rectangle")
                .foregroundColor(.blue)
        }
        .onChange(of: selectedItems) { oldItems, newItems in
            handleSelectedItems(newItems)
        }
    }
    
    private var uploadingProgress: some View {
        ProgressView("Uploading evidence...")
            .padding()
    }
    
    private var imagePreviewScrollView: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 10) {
                ForEach(selectedImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func handleSelectedItems(_ newItems: [PhotosPickerItem]) {
        Task(priority: .userInitiated) {
            selectedImages.removeAll()
            isUploading = true
            uploadStatus = "Starting uploads..."
            
            var _: [Evidence] = []
            var uploadedCount = 0
            
            // First load all images and create evidence objects
            for (index, item) in newItems.enumerated() {
                do {
                    guard let data = try await item.loadTransferable(type: Data.self) else {
                        continue
                    }
                    
                    // Add to preview
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            selectedImages.append(image)
                        }
                    }
                    
                    // Size check
                    guard data.count <= SharePointConfig.maxFileSize else {
                        await MainActor.run {
                            uploadStatus = "⚠️ File \(index + 1) exceeds size limit"
                        }
                        continue
                    }
                    
                    let evidenceId = UUID()
                    let formattedPath = formatSharePointPath(unitCode: unitCode, criteriaCode: criteriaCode)
                    _ = constructSharePointUrl(formattedPath, fileName: "\(evidenceId).jpg", forMetadata: false)
                    let metadataUrl = constructSharePointUrl(formattedPath, fileName: "\(evidenceId).jpg", forMetadata: true)
                    
                    // Create temp file
                    let tempFileURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent("\(evidenceId).jpg")
                    try data.write(to: tempFileURL)
                    
                    let evidence = Evidence(
                        id: evidenceId,
                        criteriaCode: criteriaCode,
                        unitCode: unitCode,
                        dateUploaded: Date(),
                        type: .photo,
                        title: "Photo Evidence",
                        description: criteriaDescription,
                        bookmarkData: nil,
                        sharePointUrl: metadataUrl,
                        fileURL: tempFileURL,
                        uploadDate: Date(),
                        associatedCriteria: [criteriaCode],
                        criteriaDescription: criteriaDescription,
                        assessmentStatus: .pending,
                        assessorFeedback: nil,
                        assessorName: nil,
                        assessmentDate: nil,
                        isLocallyUploaded: true
                    )
                    
                    // Upload each file individually to ensure proper handling
                    do {
                        try await evidenceManager.uploadEvidence(evidence)
                        uploadedCount += 1
                        
                        // Clean up temp file
                        try? FileManager.default.removeItem(at: tempFileURL)
                        
                        await MainActor.run {
                            uploadStatus = "✅ Uploaded \(uploadedCount)/\(newItems.count)"
                        }
                        
                        onEvidenceUploaded(evidence)
                        
                        // Add delay between uploads
                        if index < newItems.count - 1 {
                            try await Task.sleep(nanoseconds: SharePointConfig.delayBetweenUploads)
                        }
                    } catch {
                        print("Failed to upload item \(index + 1): \(error)")
                        await MainActor.run {
                            uploadStatus = "⚠️ Upload \(index + 1) failed: \(error.localizedDescription)"
                        }
                    }
                    
                } catch {
                    print("Failed to prepare item \(index + 1): \(error)")
                }
            }
            
            await MainActor.run {
                isUploading = false
                if uploadedCount == newItems.count {
                    uploadStatus = "✅ All \(uploadedCount) files uploaded"
                    selectedItems = []  // Only clear if all uploads succeeded
                } else {
                    uploadStatus = "Completed \(uploadedCount)/\(newItems.count) uploads"
                }
            }
        }
    }
    
    private func processSelectedItem(_ item: PhotosPickerItem, evidenceItems: inout [Evidence], evidenceDataItems: inout [(Evidence, Data)]) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        
        // Validate file size
        guard data.count <= SharePointConfig.maxFileSize else {
            print("File exceeds size limit of \(SharePointConfig.maxFileSize / 1024 / 1024)MB")
            return
        }
        
        await MainActor.run {
            selectedImages.append(image)
        }
        
        if let evidenceData = image.jpegData(compressionQuality: 0.8) {
            // Create temporary file URL for the image data
            let fileName = "\(UUID().uuidString).jpg"
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                // Write the image data to temporary file
                try evidenceData.write(to: tempFileURL)
                
                let evidence = Evidence(
                    id: UUID(),
                    criteriaCode: criteriaCode,
                    unitCode: unitCode,
                    dateUploaded: Date(),
                    type: .photo,
                    title: "Photo Evidence",
                    description: criteriaDescription,
                    bookmarkData: nil,
                    sharePointUrl: nil,
                    fileURL: tempFileURL,
                    uploadDate: nil,
                    associatedCriteria: [criteriaCode],
                    criteriaDescription: criteriaDescription,
                    assessmentStatus: .pending,
                    assessorFeedback: nil,
                    assessorName: nil,
                    assessmentDate: nil,
                    isLocallyUploaded: true
                )
                
                evidenceItems.append(evidence)
                evidenceDataItems.append((evidence, evidenceData))
            } catch {
                print("Error saving temporary file: \(error)")
            }
        }
    }
    
    // Add SharePoint config with maxFileSize
    private struct SharePointConfig {
        static let maxConcurrentUploads = 3
        static let delayBetweenUploads = UInt64(4_000_000_000) // 4 seconds
        static let maxRetries = 6
        static let initialRetryDelay = UInt64(2_000_000_000) // 2 seconds
        static let maxFileSize = 15 * 1024 * 1024 // 15MB max file size
    }
    
    // Replace semaphore with async/await
    private func uploadEvidenceItems(_ evidenceDataItems: [(Evidence, Data)]) async {
        do {
            print("Starting batch upload of \(evidenceDataItems.count) files")
            
            // Process files with rate limiting
            for (evidence, data) in evidenceDataItems {
                do {
                    // Verify file size
                    guard data.count <= SharePointConfig.maxFileSize else {
                        throw UploadError.uploadFailed("File exceeds size limit")
                    }
                    
                    // Prepare file
                    let fileExtension = evidence.type == .photo ? "jpg" : "pdf"
                    let fileName = "\(evidence.id).\(fileExtension)"
                    let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                    try data.write(to: tempFileURL)
                    
                    // Format paths
                    let formattedPath = formatSharePointPath(
                        unitCode: evidence.unitCode,
                        criteriaCode: evidence.criteriaCode
                    )
                    
                    let sharePointUrl = constructSharePointUrl(formattedPath, fileName: fileName)
                    
                    // Create updated evidence with all required properties
                    let updatedEvidence = Evidence(
                        id: evidence.id,
                        criteriaCode: evidence.criteriaCode,
                        unitCode: evidence.unitCode,
                        dateUploaded: Date(),
                        type: evidence.type,
                        title: evidence.title,
                        description: evidence.description,
                        bookmarkData: nil,
                        sharePointUrl: sharePointUrl,
                        fileURL: tempFileURL,
                        uploadDate: Date(),
                        associatedCriteria: evidence.associatedCriteria,
                        criteriaDescription: evidence.criteriaDescription,
                        assessmentStatus: .pending,
                        assessorFeedback: nil,
                        assessorName: nil,
                        assessmentDate: nil,
                        isLocallyUploaded: true
                    )
                    
                    // Upload with retry
                    try await evidenceManager.uploadEvidence(updatedEvidence)
                    
                    // Add delay between files
                    try await Task.sleep(nanoseconds: SharePointConfig.delayBetweenUploads)
                    
                    // Handle success
                    await MainActor.run {
                        onEvidenceUploaded(updatedEvidence)
                    }
                    
                } catch {
                    print("Upload failed: \(error)")
                }
            }
        }
    }
    
    private func formatSharePointPath(unitCode: String, criteriaCode: String) -> String {
        return SharePointPathFormatter.formatPath(unitCode: unitCode, criteriaCode: criteriaCode)
    }
    
    private func constructSharePointUrl(_ path: String, fileName: String, forMetadata: Bool = false) -> String {
        return SharePointPathFormatter.constructUrl(
            path: path, 
            fileName: fileName,
            format: forMetadata ? .metadata : .relative
        )
    }
    
    private func sanitizePathComponent(_ component: String) -> String {
        return component
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
    }
    
    // Update verification to use proper error handling
    private func verifyUpload(evidence: Evidence) async throws -> Bool {
        guard let sharePointUrl = evidence.sharePointUrl else {
            throw UploadError.invalidPath
        }
        
        do {
            // Wait for SharePoint processing
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return try await evidenceManager.verifyFileExists(at: sharePointUrl)
        } catch {
            print("Verification failed: \(error)")
            return false
        }
    }
    
    private func shouldRetryFailedUploads() async -> Bool {
        await withCheckedContinuation { continuation in
            retryCompletion = continuation
            Task { @MainActor in
                showRetryAlert = true
            }
        }
    }
    
    private func handleUploadResult(_ result: Bool, for evidence: Evidence) {
        if result {
            uploadStatus = "✅ Upload verified"
            onEvidenceUploaded(evidence)
        } else {
            uploadStatus = "⚠️ Upload needs verification"
            // Add retry logic for metadata
            Task {
                try? await Task.sleep(for: .seconds(1))
                await evidenceManager.refreshEvidenceStatus()
            }
        }
    }
}
