import SwiftUI
import PhotosUI
import PDFKit
import UniformTypeIdentifiers

struct EvidenceUploadView: View {
    @EnvironmentObject var evidenceManager: EvidenceManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var teamsManager = TeamsManager.shared
    
    // State variables
    @State private var title = ""
    @State private var description = ""
    @State private var selectedImage: UIImage?
    @State private var selectedPDF: PDFDocument?
    @State private var selectedDocumentURLs: [URL] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedVideoItems: [PhotosPickerItem] = []
    @State private var isShowingImagePicker = false
    @State private var isShowingDocumentPicker = false
    @State private var showingDocumentPicker = false
    @State private var showingError = false
    @State private var isUploading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var uploadProgress: Float = 0
    
    // Properties
    let evidenceType: Evidence.EvidenceType
    let criteriaCode: String
    let unitCode: String
    let criteriaDescription: String
    let onEvidenceUploaded: (Evidence) -> Void
    let selectedCriteria: [PerformanceCriteria]
    
    init(
        evidenceType: Evidence.EvidenceType,
        criteriaCode: String,
        unitCode: String,
        criteriaDescription: String,
        onEvidenceUploaded: @escaping (Evidence) -> Void,
        selectedCriteria: [PerformanceCriteria]
    ) {
        self.evidenceType = evidenceType
        self.criteriaCode = criteriaCode
        self.unitCode = unitCode
        self.criteriaDescription = criteriaDescription
        self.onEvidenceUploaded = onEvidenceUploaded
        self.selectedCriteria = selectedCriteria
    }
    
    var body: some View {
        formContent
            .navigationTitle("Upload \(evidenceType.rawValue.capitalized)")
            .fileImporter(isPresented: $showingDocumentPicker,
                         allowedContentTypes: supportedDocumentTypes,
                         allowsMultipleSelection: true) { result in
                handleDocumentPickerResult(result)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                setupViewController()
            }
    }
    
    private var formContent: some View {
        Form {
            detailsSection
            fileSection
            uploadButton
        }
    }
    
    private var detailsSection: some View {
        Section(header: Text("Details")) {
            TextField("Title", text: $title)
            TextEditor(text: $description)
                .frame(height: 100)
        }
    }
    
    private var fileSection: some View {
        Section(header: Text("File")) {
            Group {
                switch evidenceType {
                case .photo:
                    photoSelectionView
                case .video:
                    videoSelectionView
                case .document:
                    documentSelectionView
                case .audio:
                    audioSelectionView
                }
            }
        }
    }
    
    private var photoSelectionView: some View {
        VStack {
            if !selectedDocumentURLs.isEmpty {
                selectedPhotosPreview
            }
            photoPickerButton
        }
    }
    
    private var selectedPhotosPreview: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(selectedDocumentURLs, id: \.self) { url in
                    photoPreviewItem(url)
                }
            }
        }
    }
    
    private var uploadButton: some View {
        Group {
            if !selectedDocumentURLs.isEmpty {
                Button(action: {
                    Task {
                        await uploadMultipleEvidence()
                    }
                }) {
                    if isUploading {
                        ProgressView(value: uploadProgress, total: 1.0)
                    } else {
                        Text("Upload \(selectedDocumentURLs.count) Files")
                    }
                }
                .disabled(isUploading || selectedDocumentURLs.isEmpty)
            }
        }
    }
    
    private func handleDocumentPickerResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                handleFileSelection(url)
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    private var supportedDocumentTypes: [UTType] {
        [.pdf, .text, .plainText, .image, .jpeg, .png,
         UTType("com.microsoft.word.doc")!,
         UTType("org.openxmlformats.wordprocessingml.document")!,
         .rtf, .spreadsheet, .presentation]
    }
    
    private func handleFileSelection(_ url: URL) {
        switch evidenceType {
        case .photo, .video:
            // For photos and videos, we already have the file in our temp directory
            selectedDocumentURLs.append(url)
            
        case .document, .audio:
            // For documents and audio, use security-scoped resource handling
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Cannot access the selected file"
                showingError = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                _ = try url.bookmarkData(
                    options: .minimalBookmark,
                    includingResourceValuesForKeys: nil,
                    relativeTo: nil
                )
                
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(url.pathExtension)
                
                try FileManager.default.copyItem(at: url, to: tempURL)
                selectedDocumentURLs.append(tempURL)
            } catch {
                errorMessage = "Failed to process file: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
    
    private func handlePhotoSelection(_ item: PhotosPickerItem) {
        Task {
            do {
                if let imageData = try await item.loadTransferable(type: Data.self) {
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension("jpg")
                    try imageData.write(to: tempURL)
                    await MainActor.run {
                        handleFileSelection(tempURL)
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func handleVideoSelection(_ item: PhotosPickerItem) {
        Task {
            do {
                if let videoData = try await item.loadTransferable(type: Data.self) {
                    let tempURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension("mov")
                    try videoData.write(to: tempURL)
                    await MainActor.run {
                        handleFileSelection(tempURL)
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func setupViewController() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                teamsManager.setPresentingViewController(rootViewController)
            }
        }
    }
    
    private func uploadEvidence(fileURL: URL, title: String, description: String) async {
        isUploading = true
        defer { isUploading = false }
        
        do {
            print("Starting upload for file: \(fileURL)")
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw AppError.fileAccessError(NSError(
                    domain: "com.waynewright.ewa-nvq-portfolio1",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "File does not exist at path"]
                ))
            }
            
            let bookmarkData = try fileURL.bookmarkData(
                options: .minimalBookmark,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            
            // Create underscore-separated criteria string
            let criteriaString = selectedCriteria.map { $0.code }.joined(separator: "_")
            
            let evidence = Evidence(
                criteriaCode: criteriaString,
                unitCode: unitCode,
                type: evidenceType,
                title: title,
                description: description,
                bookmarkData: bookmarkData,
                fileURL: fileURL,
                associatedCriteria: selectedCriteria.map { $0.code },  // Keep as array for local use
                criteriaDescription: criteriaDescription
            )
            
            try await evidenceManager.uploadEvidence(evidence)
            onEvidenceUploaded(evidence)
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            print("Upload error: \(error)")
            print("File URL: \(fileURL)")
            print("File exists: \(FileManager.default.fileExists(atPath: fileURL.path))")
            await MainActor.run {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
    
    private func uploadMultipleEvidence() async {
        isUploading = true
        
        // Create array of criteria codes joined with underscores for SharePoint
        let criteriaCodes = selectedCriteria.map { $0.code }
        let criteriaString = criteriaCodes.joined(separator: "_")
        
        for (index, url) in selectedDocumentURLs.enumerated() {
            do {
                let evidence = Evidence(
                    criteriaCode: criteriaString,  // Use underscore format for SharePoint
                    unitCode: unitCode,
                    type: evidenceType,
                    title: title.isEmpty ? "Evidence \(index + 1)" : title,
                    description: description,
                    associatedCriteria: criteriaCodes,  // Keep array format for local use
                    criteriaDescription: selectedCriteria.map { $0.description }.joined(separator: " | ")
                )
                
                await uploadEvidence(fileURL: url, title: title, description: description)
            } catch {
                print("Failed to upload: \(url)")
            }
        }
        
        isUploading = false
        dismiss()
    }
    
    private var photoPickerButton: some View {
        PhotosPicker(selection: $selectedPhotoItems,
                    matching: .images,
                    photoLibrary: .shared()) {
            Label("Select Photos", systemImage: "photo.on.rectangle")
        }
        .onChange(of: selectedPhotoItems) { items in
            for item in items {
                handlePhotoSelection(item)
            }
        }
    }
    
    private var videoSelectionView: some View {
        VStack {
            if !selectedDocumentURLs.isEmpty {
                selectedVideosPreview
            }
            videoPickerButton
        }
    }
    
    private var videoPickerButton: some View {
        PhotosPicker(selection: $selectedVideoItems,
                    matching: .videos,
                    photoLibrary: .shared()) {
            Label("Select Video", systemImage: "video")
        }
        .onChange(of: selectedVideoItems) { items in
            for item in items {
                handleVideoSelection(item)
            }
        }
    }
    
    private var documentSelectionView: some View {
        VStack {
            if !selectedDocumentURLs.isEmpty {
                documentPreview
            }
            Button(action: {
                showingDocumentPicker = true
            }) {
                Label("Select Document", systemImage: "doc")
            }
        }
    }
    
    private var audioSelectionView: some View {
        VStack {
            if !selectedDocumentURLs.isEmpty {
                audioPreview
            }
            Button(action: {
                showingDocumentPicker = true
            }) {
                Label("Select Audio", systemImage: "music.note")
            }
        }
    }
    
    private var selectedVideosPreview: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(selectedDocumentURLs, id: \.self) { url in
                    videoPreviewItem(url)
                }
            }
        }
    }
    
    private var documentPreview: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(selectedDocumentURLs, id: \.self) { url in
                    documentPreviewItem(url)
                }
            }
        }
    }
    
    private var audioPreview: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(selectedDocumentURLs, id: \.self) { url in
                    audioPreviewItem(url)
                }
            }
        }
    }
    
    private func photoPreviewItem(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
            case .failure:
                Image(systemName: "photo")
                    .frame(height: 100)
            case .empty:
                ProgressView()
                    .frame(height: 100)
            @unknown default:
                EmptyView()
            }
        }
    }
    
    private func videoPreviewItem(_ url: URL) -> some View {
        Image(systemName: "video.fill")
            .frame(width: 100, height: 100)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(8)
    }
    
    private func documentPreviewItem(_ url: URL) -> some View {
        VStack {
            Image(systemName: "doc.fill")
                .font(.largeTitle)
            Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 100, height: 100)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
    
    private func audioPreviewItem(_ url: URL) -> some View {
        VStack {
            Image(systemName: "music.note")
                .font(.largeTitle)
            Text(url.lastPathComponent)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 100, height: 100)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
}
