struct EvidenceRow: View {
    @State private var showingPreview = false
    // ... existing properties ...
    
    var body: some View {
        Button {
            showingPreview = true
        } label: {
            // ... existing row content ...
        }
        .sheet(isPresented: $showingPreview) {
            EvidenceDetailView(evidence: evidence)
        }
    }
} 