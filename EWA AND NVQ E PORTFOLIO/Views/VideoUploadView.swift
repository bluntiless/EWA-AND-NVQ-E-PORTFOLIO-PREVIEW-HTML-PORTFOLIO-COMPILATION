import SwiftUI
import PhotosUI

struct VideoUploadView: View {
    @Binding var selectedVideoItem: PhotosPickerItem?
    let title: String
    let description: String
    let onVideoSelected: (PhotosPickerItem) -> Void
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedVideoItem,
                matching: .videos,
                photoLibrary: .shared()
            ) {
                Label("Select Video", systemImage: "video")
            }
            .onChange(of: selectedVideoItem, { oldValue, newValue in
                if let item = newValue {
                    onVideoSelected(item)
                }
            })
        }
    }
} 