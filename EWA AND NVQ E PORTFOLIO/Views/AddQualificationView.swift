import SwiftUI

struct AddQualificationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    
    @State private var title = ""
    @State private var awardingBody = ""
    @State private var yearCompleted = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Qualification Title", text: $title)
                TextField("Awarding Body", text: $awardingBody)
                Stepper("Year Completed: \(yearCompleted)", 
                       value: $yearCompleted,
                       in: 1950...Calendar.current.component(.year, from: Date()))
            }
            .navigationTitle("Add Qualification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save qualification
                        dismiss()
                    }
                }
            }
        }
    }
} 