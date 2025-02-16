import SwiftUI
import PhotosUI

struct VideoUploadView: View {
    @Binding var selectedVideoItem: PhotosPickerItem?
    let title: String
    let description: String
    let onVideoSelected: (PhotosPickerItem) -> Void
    @State private var isViewActive = false
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Preparing video picker...")
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        isLoading = false
                    }
                }
            } else {
                VStack {
                    PhotosPicker(
                        selection: $selectedVideoItem,
                        matching: .videos,
                        photoLibrary: .shared()
                    ) {
                        Label("Select Video", systemImage: "video")
                    }
                    .onChange(of: selectedVideoItem) { oldValue, newValue in
                        if let item = newValue {
                            onVideoSelected(item)
                        }
                    }
                }
            }
        }
        .onAppear {
            isViewActive = true
        }
        .onDisappear {
            isViewActive = false
            selectedVideoItem = nil  // Force reset the selection
            isLoading = true  // Reset loading state
        }
    }
} 