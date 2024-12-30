import SwiftUI
import PDFKit
import AVKit
import UIKit
import QuickLook

struct EvidenceRow: View {
    let evidence: Evidence
    
    init(evidence: Evidence) {
        self.evidence = evidence
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
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
                    case .audio:
                        Image(systemName: "audio.fill")
                    }
                }
                .frame(width: 44, height: 44)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(evidence.title)
                        .font(.headline)
                    Text(evidence.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        
                    HStack {
                        Text("Unit \(evidence.unitCode) - \(evidence.criteriaCode)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: evidence.currentStatus.icon)
                            Text(evidence.currentStatus.displayName)
                        }
                        .font(.caption)
                        .foregroundColor(evidence.currentStatus.color)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}
