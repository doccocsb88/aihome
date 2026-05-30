import SwiftUI

struct InteriorIntroView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Placeholder for before/after comparison visual
            Rectangle()
                .fill(Color.DesignSystem.surface)
                .aspectRatio(1, contentMode: .fit)
                .overlay(Text("Before / After Comparison").foregroundColor(.DesignSystem.textSecondary))
                .padding()
            
            Text("Interior Design")
                .font(.DesignSystem.title1)
            
            Text("Redesign your space instantly")
                .font(.DesignSystem.body)
                .foregroundColor(.DesignSystem.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                coordinator.push(.onboardingExterior)
            }) {
                Text("Continue")
                    .font(.DesignSystem.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.DesignSystem.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    InteriorIntroView()
        .environment(AppCoordinator())
}
