import SwiftUI

struct LandscapeIntroView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Rectangle()
                .fill(Color.DesignSystem.surface)
                .aspectRatio(1, contentMode: .fit)
                .overlay(Text("Landscape Before / After").foregroundColor(.DesignSystem.textSecondary))
                .padding()
            
            Text("Landscape Design")
                .font(.DesignSystem.title1)
            
            Text("Refresh your garden with AI")
                .font(.DesignSystem.body)
                .foregroundColor(.DesignSystem.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                coordinator.push(.trialEnabled)
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
    LandscapeIntroView()
        .environment(AppCoordinator())
}
