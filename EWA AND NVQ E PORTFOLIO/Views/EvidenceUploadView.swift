import SwiftUI
import PhotosUI
import AVKit
import Photos
import Foundation
import UniformTypeIdentifiers

struct EvidenceUploadView: View {
    let criteriaCode: String
    let unitCode: String
    let criteriaDescription: String
    let evidenceType: Evidence.EvidenceType
    let onEvidenceUploaded: (Evidence) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDocumentURLs: [URL] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var selectedVideoItems: [PhotosPickerItem] = []
    @State private var showingDocumentPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isUploading = false
    @State private var evidenceItems: [Evidence] = []
    
    @StateObject private var teamsManager = TeamsManager.shared
    @Environment(\.dismiss) private var dismiss
    
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
                    .onChange(of: selectedPhotoItems) { oldValue, newValue in
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
                    }
                    .onChange(of: selectedVideoItems) { oldValue, newValue in
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
                }
            }
            
            if !selectedDocumentURLs.isEmpty {
                Button(action: {
                    Task {
                        await handleMultipleUploads()
                    }
                }) {
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("Upload \(selectedDocumentURLs.count) Files")
                    }
                }
                .disabled(isUploading)
            }
        }
        .navigationTitle("Upload \(evidenceType.rawValue.capitalized)")
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.pdf, .text, .image],
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
    
    private func handleFileSelection(_ url: URL) {
        do {
            let bookmarkData = try url.bookmarkData()
            var newEvidence = Evidence(
                criteriaCode: criteriaCode,
                unitCode: unitCode,
                type: evidenceType,
                title: title,
                description: description,
                criteriaDescription: criteriaDescription
            )
            newEvidence.setBookmarkData(bookmarkData)
            newEvidence.setFileURL(url)
            self.evidenceItems.append(newEvidence)
            self.selectedDocumentURLs.append(url)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
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
    
    private var canUpload: Bool {
        !title.isEmpty && !description.isEmpty && !selectedDocumentURLs.isEmpty
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
    
    private func handleMultipleUploads() async {
        isUploading = true
        defer { isUploading = false }
        
        do {
            if !evidenceItems.isEmpty {
                let uploadedEvidence = try await teamsManager.uploadMultipleToSharePoint(evidenceItems: evidenceItems)
                for evidence in uploadedEvidence {
                    onEvidenceUploaded(evidence)
                }
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}
