import SwiftUI

struct FloatingFilterButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "line.3.horizontal.decrease")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(Color.DesignSystem.amaranth, in: Circle())
                .shadow(color: Color.DesignSystem.amaranth.opacity(0.35), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filter")
    }
}
