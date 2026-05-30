import SwiftUI

struct ExteriorIntroView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Rectangle()
                .fill(Color.DesignSystem.surface)
                .aspectRatio(1, contentMode: .fit)
                .overlay(Text("Exterior Before / After").foregroundColor(.DesignSystem.textSecondary))
                .padding()
            
            Text("Exterior Design")
                .font(.DesignSystem.title1)
            
            Text("Reimagine your facade")
                .font(.DesignSystem.body)
                .foregroundColor(.DesignSystem.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                coordinator.push(.onboardingLandscape)
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
    ExteriorIntroView()
        .environment(AppCoordinator())
}
