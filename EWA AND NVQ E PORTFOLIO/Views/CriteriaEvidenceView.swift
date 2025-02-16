import SwiftUI

struct CriteriaEvidenceView: View {
    let unit: Unit
    let selectedCriteria: [PerformanceCriteria]
    @StateObject private var viewModel: CriteriaEvidenceViewModel
    @EnvironmentObject var evidenceManager: EvidenceManager
    @State private var showingUploadSheet = false
    @State private var selectedEvidenceType: Evidence.EvidenceType?
    @State private var isUploading = false
    
    init(unit: Unit, selectedCriteria: [PerformanceCriteria]) {
        self.unit = unit
        self.selectedCriteria = selectedCriteria
        _viewModel = StateObject(wrappedValue: CriteriaEvidenceViewModel(criteria: selectedCriteria))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Selected Criteria Information
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(selectedCriteria) { criteria in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Criteria \(criteria.code)")
                                .font(.headline)
                            Text(criteria.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            // Upload Options
            VStack(spacing: 12) {
                UploadButton(
                    title: "Upload Photos",
                    icon: "camera",
                    color: .blue
                ) {
                    handlePickerSelection(.photo)
                }
                
                UploadButton(
                    title: "Upload Video",
                    icon: "video",
                    color: .green
                ) {
                    handlePickerSelection(.video)
                }
                
                UploadButton(
                    title: "Upload Document",
                    icon: "doc",
                    color: .orange
                ) {
                    handlePickerSelection(.document)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingUploadSheet) {
            if let type = selectedEvidenceType {
                NavigationView {
                    EvidenceUploadView(
                        evidenceType: type,
                        criteriaCode: selectedCriteria[0].code,
                        unitCode: unit.reference,
                        criteriaDescription: selectedCriteria[0].description,
                        onEvidenceUploaded: { evidence in
                            print("📤 Evidence upload completed")
                            evidenceManager.addEvidence(evidence)
                            showingUploadSheet = false
                        },
                        selectedCriteria: selectedCriteria
                    )
                    .environmentObject(evidenceManager)
                }
                .onAppear {
                    print("🔄 Sheet View appeared with type: \(type)")
                }
            } else {
                EmptyView()
            }
        }
        .onChange(of: showingUploadSheet) { oldValue, newValue in
            print("📱 Sheet presentation changed: \(oldValue) -> \(newValue)")
        }
        .onChange(of: selectedEvidenceType) { oldValue, newValue in
            print("📎 Evidence type changed: \(String(describing: oldValue)) -> \(String(describing: newValue))")
        }
    }
    
    private func handlePickerSelection(_ type: Evidence.EvidenceType) {
        print("🎯 handlePickerSelection called with type: \(type)")
        
        // Reset state before presenting new picker
        selectedEvidenceType = nil
        showingUploadSheet = false
        print("🔄 State reset completed")
        
        // Small delay to ensure clean state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("⏱️ Delayed presentation starting")
            selectedEvidenceType = type
            showingUploadSheet = true
            print("✅ Sheet presentation completed")
        }
    }
}

struct UploadButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title3)
            }
            .padding()
            .foregroundColor(.white)
            .background(color)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
