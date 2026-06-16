import SwiftUI

struct WelcomeView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text(L10n.Onboarding.Welcome.title)
                .font(.DesignSystem.title1)
                .multilineTextAlignment(.center)
            
            Text(L10n.Onboarding.Welcome.subtitle)
                .font(.DesignSystem.body)
                .foregroundColor(.DesignSystem.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
            
            Spacer()
            
            Button(action: {
                coordinator.push(.onboardingInterior)
            }) {
                Text(L10n.Onboarding.Welcome.getStarted)
                    .font(.DesignSystem.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.DesignSystem.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                Link(L10n.Onboarding.Welcome.termsOfUse, destination: URL(string: "https://example.com/terms")!)
                Link(L10n.Onboarding.Welcome.subscriptionTerms, destination: URL(string: "https://example.com/subscription")!)
                Link(L10n.Onboarding.Welcome.privacyPolicy, destination: URL(string: "https://example.com/privacy")!)
            }
            .font(.DesignSystem.caption)
            .foregroundColor(.DesignSystem.textSecondary)
            .padding(.bottom, 16)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    WelcomeView()
        .environment(AppCoordinator())
}
