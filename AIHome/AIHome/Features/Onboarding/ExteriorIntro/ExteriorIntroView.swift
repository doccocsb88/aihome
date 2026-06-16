import SwiftUI

struct ExteriorIntroView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        OnboardingIntroPage(
            imageName: "onboarding_page2",
            title: L10n.Onboarding.Exterior.title,
            subtitle: L10n.Onboarding.Exterior.subtitle,
            activeIndex: 1,
            onContinue: {
                coordinator.push(.onboardingLandscape)
            }
        )
    }
}

#Preview {
    ExteriorIntroView()
        .environment(AppCoordinator())
}
