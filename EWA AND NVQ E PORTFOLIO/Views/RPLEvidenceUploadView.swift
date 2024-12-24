import SwiftUI

struct RPLEvidenceUploadView: View {
    let unit: Unit
    @State private var selectedCertificates: [String] = []
    @State private var showingDocumentPicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Unit \(unit.code): \(unit.title)")
                        .font(.headline)
                    Text(unit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Unit Information")
            }
            
            Section {
                Text("This knowledge unit requires Recognition of Prior Learning (RPL)")
                    .font(.subheadline)
                Text("Please upload relevant certificates or qualifications")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(unit.learningOutcomes, id: \.number) { outcome in
                    ForEach(outcome.performanceCriteria) { criteria in
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(selectedCertificates.isEmpty ? .gray : .green)
                            Text(criteria.description)
                                .font(.subheadline)
                        }
                    }
                }
            } header: {
                Text("Required Evidence")
            }
            
            Section {
                if selectedCertificates.isEmpty {
                    Text("No certificates uploaded")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(selectedCertificates, id: \.self) { certificate in
                        HStack {
                            Image(systemName: "doc.fill")
                            Text(certificate)
                            Spacer()
                            Button(action: {
                                removeCertificate(certificate)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                Button(action: {
                    showingDocumentPicker = true
                }) {
                    Label("Upload Certificate", systemImage: "plus.circle")
                }
            } header: {
                Text("Uploaded Certificates")
            }
            
            Section {
                Button(action: submitEvidence) {
                    HStack {
                        Spacer()
                        Text("Submit for Verification")
                        Spacer()
                    }
                }
                .disabled(selectedCertificates.isEmpty)
            } header: {
                Text("Submission")
            }
        }
        .navigationTitle("RPL Evidence Upload")
        .sheet(isPresented: $showingDocumentPicker) {
            // Document picker implementation
            Text("Document Picker Placeholder")
        }
        .alert("Evidence Submission", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func removeCertificate(_ certificate: String) {
        selectedCertificates.removeAll { $0 == certificate }
    }
    
    private func submitEvidence() {
        // Implement evidence submission logic
        alertMessage = "Evidence submitted successfully for verification"
        showingAlert = true
    }
}

// Preview provider
struct RPLEvidenceUploadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RPLEvidenceUploadView(unit: cityAndGuilds2357Units.first(where: { $0.unitType == .knowledge })!)
        }
    }
} 