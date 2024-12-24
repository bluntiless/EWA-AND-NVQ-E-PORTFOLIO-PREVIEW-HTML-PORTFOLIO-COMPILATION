import SwiftUI
import AVKit

struct VideoPreview: View {
    let url: URL
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: url))
    }
} 