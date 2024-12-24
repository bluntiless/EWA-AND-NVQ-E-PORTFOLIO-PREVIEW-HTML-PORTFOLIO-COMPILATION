import SwiftUI

struct UnitTypeTag: View {
    let type: UnitType
    
    var body: some View {
        Text(type == .performance ? "P" : "K")
            .font(.caption2.bold())
            .foregroundColor(.white)
            .padding(4)
            .background(
                Circle()
                    .fill(type == .performance ? Color.blue : Color.green)
            )
    }
}

#Preview {
    HStack {
        UnitTypeTag(type: .performance)
        UnitTypeTag(type: .knowledge)
    }
    .padding()
} 