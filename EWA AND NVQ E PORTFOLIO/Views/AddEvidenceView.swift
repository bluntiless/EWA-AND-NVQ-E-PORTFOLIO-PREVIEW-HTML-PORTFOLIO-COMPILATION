import SwiftUI
import PhotosUI
import PDFKit
import AVKit

struct AddEvidenceView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    let criteriaCode: String
    let unitCode: String
    let criteriaDescription: String
    let onEvidenceUploaded: (Evidence) -> Void
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideos: [AVPlayer] = []
    @State private var selectedPDFUrls: [URL] = []
    @State private var isUploading = false
    @State private var uploadProgress: Double = 0
    @State private var currentlyUploadingItem: String?
    @State private var failedUploads: [String] = []
    @State private var showErrorAlert = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            photoPickerButton
            if isUploading {
                uploadingProgress
            }
            filePreviewScrollView
        }
    }

    private var photoPickerButton: some View {
        PhotosPicker(selection: $selectedItems,
                     maxSelectionCount: 5,
                     matching: .images) {
            Label("Select Evidence", systemImage: "photo.on.rectangle")
                .foregroundColor(.blue)
        }
        .onChange(of: selectedItems) { _, newItems in
            handleSelectedItems(newItems)
        }
    }

    private var uploadingProgress: some View {
        VStack {
            ProgressView(value: uploadProgress, total: 100) {
                Text("Uploading: \(currentlyUploadingItem ?? "")")
            }
            .padding()
            
            if !failedUploads.isEmpty {
                Text("Failed uploads: \(failedUploads.count)")
                    .foregroundColor(.red)
            }
        }
        .alert("Upload Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }

    private var filePreviewScrollView: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 10) {
                ForEach(selectedImages, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                }
                ForEach(selectedVideos, id: \.self) { player in
                    VideoPlayer(player: player)
                        .frame(height: 300)
                }
                ForEach(selectedPDFUrls, id: \.self) { url in
                    PDFPreview(url: url)
                        .frame(height: 300)
                }
            }
        }
    }

    private func uploadEvidence(items: [Any]) async {
        isUploading = true
        uploadProgress = 0
        
        for (index, item) in items.enumerated() {
            do {
                let evidenceId = UUID()
                currentlyUploadingItem = "Item \(index + 1) of \(items.count)"
                
                let (fileData, mimeType) = try await getFileData(from: item)
                
                let evidence = Evidence(
                    id: evidenceId,
                    criteriaCode: criteriaCode,
                    unitCode: unitCode,
                    dateUploaded: Date(),
                    type: determineEvidenceType(item),
                    title: "Evidence \(index + 1)",
                    description: "Uploaded evidence for \(criteriaCode)",
                    bookmarkData: fileData,
                    sharePointUrl: nil,
                    fileURL: nil,
                    uploadDate: Date(),
                    associatedCriteria: [criteriaCode],
                    criteriaDescription: criteriaDescription,
                    assessmentStatus: .pending,
                    assessorFeedback: nil,
                    assessorName: nil,
                    assessmentDate: nil,
                    isLocallyUploaded: true
                )
                
                try await evidenceManager.uploadEvidence(evidence)
                uploadProgress = Double((index + 1)) / Double(items.count) * 100
                
                await MainActor.run {
                    onEvidenceUploaded(evidence)
                }
                
            } catch {
                await MainActor.run {
                    failedUploads.append("Item \(index + 1)")
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
        
        await MainActor.run {
            isUploading = false
            currentlyUploadingItem = nil
            uploadProgress = 0
            selectedItems = []
            selectedImages = []
            selectedVideos = []
            selectedPDFUrls = []
        }
    }

    private func getFileData(from item: Any) async throws -> (Data, String) {
        switch item {
        case let image as UIImage:
            guard let data = image.jpegData(compressionQuality: 0.8) else {
                throw NSError(domain: "AddEvidenceView", code: -1, 
                             userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
            }
            return (data, "image/jpeg")
            
        case let url as URL:
            let data = try Data(contentsOf: url)
            let mimeType = url.pathExtension.lowercased() == "pdf" ? "application/pdf" : "video/mp4"
            return (data, mimeType)
            
        default:
            throw NSError(domain: "AddEvidenceView", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Unsupported file type"])
        }
    }

    private func determineEvidenceType(_ item: Any) -> Evidence.EvidenceType {
        switch item {
        case is UIImage:
            return .photo
        case is URL where (item as! URL).pathExtension.lowercased() == "pdf":
            return .document
        case is URL:
            return .video
        default:
            return .document
        }
    }

    private func handleSelectedItems(_ newItems: [PhotosPickerItem]) {
        Task {
            var itemsToUpload: [Any] = []
            
            for item in newItems {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        await MainActor.run {
                            selectedImages.append(image)
                        }
                        itemsToUpload.append(image)
                    } else if let url = try? await item.loadTransferable(type: URL.self) {
                        if url.pathExtension.lowercased() == "pdf" {
                            await MainActor.run {
                                selectedPDFUrls.append(url)
                            }
                            itemsToUpload.append(url)
                        } else {
                            let player = AVPlayer(url: url)
                            await MainActor.run {
                                selectedVideos.append(player)
                            }
                            itemsToUpload.append(url)
                        }
                    }
                }
            }
            
            // Start upload process
            await uploadEvidence(items: itemsToUpload)
        }
    }
}
