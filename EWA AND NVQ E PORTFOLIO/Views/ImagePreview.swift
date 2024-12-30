import SwiftUI

struct ImagePreview: View {
    let url: URL
    @State private var image: UIImage?
    @State private var errorMessage: String?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text(error)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("Loading image from URL: \(url)")
            if url.isFileURL {
                // Local file
                if let image = UIImage(contentsOfFile: url.path) {
                    await MainActor.run {
                        self.image = image
                    }
                    return
                }
            } else {
                // Remote URL
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
                }
                
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.image = image
                    }
                    return
                }
            }
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not load image"])
        } catch {
            print("Error loading image: \(error)")
            await MainActor.run {
                self.errorMessage = "Could not load preview.\nTap to open in SharePoint."
            }
        }
    }
} 