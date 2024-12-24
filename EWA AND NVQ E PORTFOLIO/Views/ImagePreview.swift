import SwiftUI

struct ImagePreview: View {
    let url: URL
    
    var body: some View {
        if let image = UIImage(contentsOfFile: url.path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Text("Unable to load image")
        }
    }
} 