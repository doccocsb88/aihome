import SwiftUI

struct TrialEnabledView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
            
            Text(L10n.Onboarding.TrialEnabled.title)
                .font(.DesignSystem.title1)
                .multilineTextAlignment(.center)
            
            Text(L10n.Onboarding.TrialEnabled.subtitle)
                .font(.DesignSystem.body)
                .foregroundColor(.DesignSystem.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()

            Spacer()
                .frame(height: OnboardingLayout.contentBottomReserve)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    TrialEnabledView()
}
