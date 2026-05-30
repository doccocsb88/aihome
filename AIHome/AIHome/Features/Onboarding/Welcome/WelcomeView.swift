import SwiftUI

struct WelcomeView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("Welcome to HomeGPT")
                .font(.DesignSystem.title1)
                .multilineTextAlignment(.center)
            
            Text("Transform your space with AI")
                .font(.DesignSystem.body)
                .foregroundColor(.DesignSystem.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                coordinator.push(.onboardingInterior)
            }) {
                Text("Get Started")
                    .font(.DesignSystem.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.DesignSystem.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            HStack(spacing: 16) {
                Link("Terms of use", destination: URL(string: "https://example.com/terms")!)
                Link("Subscription Terms", destination: URL(string: "https://example.com/subscription")!)
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
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
