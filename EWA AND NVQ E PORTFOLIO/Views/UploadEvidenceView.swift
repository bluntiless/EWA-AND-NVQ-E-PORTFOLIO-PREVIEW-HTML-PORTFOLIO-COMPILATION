import SwiftUI
import PhotosUI

struct UploadEvidenceView: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var documentURL: URL?
    @State private var showingDocumentPicker = false
    
    var body: some View {
        List {
            Section(header: Text("Upload Evidence")) {
                // Photo picker
                PhotosPicker(
                    selection: $selectedItems,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Label("Select Photos", systemImage: "photo")
                    }
                
                // Document picker
                Button(action: {
                    showingDocumentPicker = true
                }) {
                    Label("Select Documents", systemImage: "doc")
                }
                
                // Upload button
                if !selectedImages.isEmpty || documentURL != nil {
                    Button(action: {
                        // Implement upload to Teams/SharePoint
                    }) {
                        Label("Upload to Teams", systemImage: "arrow.up.circle")
                    }
                }
            }
            
            // Preview section
            if !selectedImages.isEmpty {
                Section(header: Text("Selected Images")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0..<selectedImages.count, id: \.self) { index in
                                selectedImages[index]
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                        }
                    }
                }
            }
        }
        .fileImporter(
            isPresented: $showingDocumentPicker,
            allowedContentTypes: [.pdf, .text, .image]
        ) { result in
            // Handle selected document
        }
    }
} 