import SwiftUI
import PDFKit
import AVKit
import UIKit
import QuickLook

struct EvidenceRow: View {
    var evidence: Evidence
    
    var body: some View {
        HStack(spacing: 12) {
            // Preview thumbnail
            Group {
                switch evidence.type {
                case .photo:
                    if let url = try? evidence.resolvedFileURL,
                       let image = UIImage(contentsOfFile: url.path) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "photo")
                    }
                case .video:
                    Image(systemName: "video.fill")
                case .document:
                    Image(systemName: "doc.fill")
                }
            }
            .frame(width: 44, height: 44)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(evidence.title)
                    .font(.headline)
                Text(evidence.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                Text("Unit \(evidence.unitCode) - \(evidence.criteriaCode)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .contentShape(Rectangle())
    }
}
