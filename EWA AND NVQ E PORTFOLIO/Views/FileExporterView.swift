import SwiftUI

struct FileExporterView: View {
    @Binding var isPresented: Bool
    let onSave: (URL) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                // File exporter content
            }
            .navigationTitle("Save Portfolio")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {  // This replaces "Move"
                    // Save action
                }
            )
        }
    }
} 