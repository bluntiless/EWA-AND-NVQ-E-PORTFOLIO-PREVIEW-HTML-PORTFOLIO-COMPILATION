import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var evidenceManager: EvidenceManager
    
    // Add required state
    @State private var progress: [String: Double] = [:]
    @State private var units: [Unit] = []
    
    // Add progress calculation
    private func getProgressForUnit(_ unitCode: String) -> Double {
        let approved = evidenceManager.getApprovedEvidenceCount(for: unitCode)
        let total = viewModel.getRequiredEvidenceCount(for: unitCode)
        return Double(approved) / Double(max(1, total))
    }
    
    private func updateProgress() {
        Task {
            await evidenceManager.refreshEvidenceStatus()
            // Update progress after refresh
            for unit in units {
                progress[unit.code] = getProgressForUnit(unit.code)
            }
        }
    }
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var isEditingField = false
    @State private var editingField: String?
    @State private var editingValue = ""
    
    var body: some View {
        List {
            // Profile Image Section
            Section {
                HStack {
                    if let profileImage {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                    
                    PhotosPicker(selection: $selectedItem,
                               matching: .images) {
                        Text("Change Photo")
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            // Manual Input Section
            Section("Personal Information") {
                EditableRow(title: "Full Name", 
                          value: $viewModel.fullName,
                          isEditing: $isEditingField,
                          editingField: $editingField)
                
                EditableRow(title: "Job Title", 
                          value: $viewModel.jobTitle,
                          isEditing: $isEditingField,
                          editingField: $editingField)
                
                EditableRow(title: "Employer", 
                          value: $viewModel.employer,
                          isEditing: $isEditingField,
                          editingField: $editingField)
                
                HStack {
                    Text("Years of Experience")
                    Spacer()
                    Stepper("\(viewModel.yearsExperience)", 
                           value: $viewModel.yearsExperience, 
                           in: 0...50)
                }
            }
        }
        .navigationTitle("Profile")
        .onChange(of: selectedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                    viewModel.saveProfileImage(data)
                }
            }
        }
    }
    
    private func refreshAssessmentStatus() {
        // Add retry logic for failed metadata fetches
        let retryCount = 3
        let retryDelay = 1.0 // seconds
        
        func retryFetch(attempt: Int) {
            guard attempt < retryCount else {
                print("Failed to fetch metadata after \(retryCount) attempts")
                return
            }
            
            // Existing fetch logic here
            Task {
                do {
                    // Your existing metadata fetch code
                } catch {
                    print("Fetch attempt \(attempt + 1) failed: \(error)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                        retryFetch(attempt: attempt + 1)
                    }
                }
            }
        }
        
        retryFetch(attempt: 0)
    }
    
    private func getEvidencePath(unitCode: String, criteriaCode: String) -> String {
        let sanitizedUnit = unitCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
        
        let sanitizedCriteria = criteriaCode
            .replacingOccurrences(of: ".", with: "_")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return "Evidence/\(sanitizedUnit)/\(sanitizedCriteria)"
    }
    
    private func refreshEvidence() {
        Task {
            try? await evidenceManager.refreshEvidenceStatus()
        }
    }
}

struct EditableRow: View {
    let title: String
    @Binding var value: String
    @Binding var isEditing: Bool
    @Binding var editingField: String?
    
    var body: some View {
        if isEditing && editingField == title {
            HStack {
                TextField(title, text: $value)
                    .textFieldStyle(.roundedBorder)
                Button("Done") {
                    isEditing = false
                    editingField = nil
                }
            }
        } else {
            HStack {
                Text(title)
                Spacer()
                Text(value.isEmpty ? "Not Set" : value)
                    .foregroundColor(value.isEmpty ? .gray : .primary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                editingField = title
                isEditing = true
            }
        }
    }
} 