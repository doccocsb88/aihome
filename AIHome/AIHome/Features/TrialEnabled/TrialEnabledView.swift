import SwiftUI

struct TrialEnabledView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text("3-day free trial is enabled!")
                .font(.DesignSystem.title1)
                .multilineTextAlignment(.center)
            
            Text("You now have full access to all premium features.")
                .font(.DesignSystem.body)
                .foregroundColor(.DesignSystem.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button(action: {
                UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
                coordinator.replaceRoot(with: .mainTab)
            }) {
                Text("Start Designing")
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
    TrialEnabledView()
        .environment(AppCoordinator())
}
