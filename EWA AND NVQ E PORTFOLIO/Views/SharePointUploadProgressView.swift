import SwiftUI

struct SharePointUploadProgressView: View {
    let progress: TeamsManager.UploadProgress
    @ObservedObject var teamsManager: TeamsManager
    let evidence: Evidence
    
    var body: some View {
        VStack(spacing: 12) {
            Text(progress.filename)
                .font(.headline)
            
            switch progress.status {
            case .preparing:
                Text("Preparing upload...")
                ProgressView()
            case .uploading:
                Text("Uploading...")
                ProgressView(value: progress.progress)
            case .processing:
                Text("Processing...")
                ProgressView()
            case .complete:
                Label("Upload complete", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .failed(let error):
                Label("Upload failed: \(error.localizedDescription)", 
                      systemImage: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
} 