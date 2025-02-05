import SwiftUI

struct UnitDetailView: View {
    @ObservedObject var unit: Unit
    @State private var navigationTitle: String
    
    init(unit: Unit) {
        self.unit = unit
        // Initialize the title with the correct format
        _navigationTitle = State(initialValue: "Unit \(unit.displayCode)")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Unit details card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Code")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(unit.displayCode)  // Use displayCode here too
                    }
                    
                    HStack {
                        Text("Title")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(unit.title)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Credit Value")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(unit.creditValue)")
                    }
                    
                    HStack {
                        Text("GLH")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(unit.glh)")
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                // Progress indicator
                VStack(alignment: .leading) {
                    Text("\(Int(unit.progress * 100))% Complete")
                        .foregroundColor(.secondary)
                    ProgressView(value: unit.progress)
                        .progressViewStyle(.linear)
                        .tint(.blue)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                // Learning outcomes section
                Text("Learning Outcome")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Force title update when view appears
            navigationTitle = "Unit \(unit.displayCode)"
        }
    }
} 