import SwiftUI
import PDFKit
import AVKit
import QuickLook

struct EvidencePreviewView: View {
    @StateObject private var viewModel: EvidencePreviewViewModel
    @State private var isRefreshing = false
    
    init(evidence: Evidence) {
        _viewModel = StateObject(wrappedValue: EvidencePreviewViewModel(evidence: evidence))
    }
    
    var body: some View {
        VStack {
            // Existing preview content...
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Assessment Status:")
                        .bold()
                    Text(viewModel.assessmentStatus.displayName)
                        .foregroundColor(viewModel.assessmentStatus.color)
                }
                
                if let feedback = viewModel.assessorFeedback, !feedback.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Assessor Feedback:")
                            .bold()
                        Text(feedback)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                
                if let assessor = viewModel.assessorName, !assessor.isEmpty {
                    HStack {
                        Text("Assessed by:")
                            .bold()
                        Text(assessor)
                    }
                }
                
                if let date = viewModel.assessmentDate {
                    HStack {
                        Text("Assessment Date:")
                            .bold()
                        Text(date, style: .date)
                    }
                }
            }
            .padding()
            
            Button(action: {
                Task {
                    isRefreshing = true
                    await viewModel.refreshMetadata()
                    isRefreshing = false
                }
            }) {
                Label("Refresh Status", systemImage: "arrow.clockwise")
            }
            .disabled(!viewModel.canRefresh || isRefreshing)
        }
    }
}

// New ViewModel to handle state
class EvidencePreviewViewModel: ObservableObject {
    private let evidence: Evidence
    
    @Published var assessmentStatus: Evidence.AssessmentStatus
    @Published var assessorFeedback: String?
    @Published var assessorName: String?
    @Published var assessmentDate: Date?
    
    var canRefresh: Bool {
        evidence.isUploaded
    }
    
    init(evidence: Evidence) {
        self.evidence = evidence
        self.assessmentStatus = evidence.assessmentStatus
        self.assessorFeedback = evidence.assessorFeedback
        self.assessorName = evidence.assessorName
        self.assessmentDate = evidence.assessmentDate
    }
    
    func refreshMetadata() async {
        do {
            try await TeamsManager.shared.refreshEvidenceMetadata(for: evidence)
            await MainActor.run {
                self.assessmentStatus = evidence.assessmentStatus
                self.assessorFeedback = evidence.assessorFeedback
                self.assessorName = evidence.assessorName
                self.assessmentDate = evidence.assessmentDate
            }
        } catch {
            print("Error refreshing metadata:", error)
        }
    }
} 
