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
    
    // Properties
    let evidenceType: Evidence.EvidenceType
    let criteriaCode: String
    let unitCode: String
    let criteriaDescription: String
    let onEvidenceUploaded: (Evidence) -> Void
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                TextField("Title", text: $title)
                TextEditor(text: $description)
                    .frame(height: 100)
            }
            
            Section(header: Text("File")) {
                switch evidenceType {
                case .photo:
                    if !selectedDocumentURLs.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedDocumentURLs, id: \.self) { url in
                                    VStack {
                                        ImagePreview(url: url)
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                        
                                        Button(action: {
                                            selectedDocumentURLs.removeAll { $0 == url }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Select Photos", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedPhotoItems) { _, newValue in
                        for item in newValue {
                            handlePhotoSelection(item)
                        }
                    }
                    
                case .video:
                    if !selectedDocumentURLs.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(selectedDocumentURLs, id: \.self) { url in
                                    VStack {
                                        Image(systemName: "video.fill")
                                            .font(.title)
                                            .frame(width: 60, height: 60)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                        
                                        Button(action: {
                                            selectedDocumentURLs.removeAll { $0 == url }
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    PhotosPicker(
                        selection: $selectedVideoItems,
                        matching: .videos,
                        photoLibrary: .shared()
                    ) {
                        Label("Select Videos", systemImage: "video")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .onChange(of: selectedVideoItems) { _, newValue in
                        for item in newValue {
                            handleVideoSelection(item)
                        }
                    }
                    
                case .document:
                    Button(action: {
                        showingDocumentPicker = true
                    }) {
                        Label("Select Documents", systemImage: "doc")
                    }
                    
                case .audio:
                    Button(action: {
                        // Audio selection action
                    }) {
                        Label("Select Audio", systemImage: "music.note")
                    }
                }
            }
            
            if !selectedDocumentURLs.isEmpty {
                Button(action: {
                    Task {
                        if let url = selectedDocumentURLs.first {
                            await uploadEvidence(fileURL: url, title: title, description: description)
                        }
                    }
                }) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("Upload \(selectedDocumentURLs.count) Files")
                    }
                }
                .disabled(isUploading || !canUpload)
            }
        }
        .navigationTitle("Upload \(evidenceType.rawValue.capitalized)")
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [
                .pdf,
                .text,
                .plainText,
                .image,
                .jpeg,
                .png,
                UTType("com.microsoft.word.doc")!,
                UTType("org.openxmlformats.wordprocessingml.document")!,
                .rtf,
                .spreadsheet,
                .presentation
            ],
            allowsMultipleSelection: true
        ) { result in
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
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            setupViewController()
        }
    }
    
    private var canUpload: Bool {
        !selectedDocumentURLs.isEmpty  // Only check if files are selected
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
            
            let evidence = Evidence(
                criteriaCode: criteriaCode,
                unitCode: unitCode,
                type: evidenceType,
                title: title,
                description: description,
                bookmarkData: bookmarkData,
                fileURL: fileURL,
                associatedCriteria: [criteriaCode],
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
}
