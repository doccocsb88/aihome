import SwiftUI

struct LandscapeIntroView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        OnboardingIntroPage(
            imageName: "onboarding_page3",
            beforeImageName: "onboarding_page1",
            title: L10n.Onboarding.Landscape.title,
            subtitle: L10n.Onboarding.Landscape.subtitle,
            activeIndex: 2,
            onContinue: {
                coordinator.push(.trialEnabled)
            }
        )
    }
}

#Preview {
    LandscapeIntroView()
        .environment(AppCoordinator())
}
