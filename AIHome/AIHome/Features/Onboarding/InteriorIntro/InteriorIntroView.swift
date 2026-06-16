import SwiftUI

struct InteriorIntroView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        OnboardingIntroPage(
            imageName: "onboarding_page1",
            beforeImageName: "onboarding_page2",
            title: L10n.Onboarding.Interior.title,
            subtitle: L10n.Onboarding.Interior.subtitle,
            activeIndex: 0,
            onContinue: {
                coordinator.push(.onboardingExterior)
            }
        )
    }
}

#Preview {
    InteriorIntroView()
        .environment(AppCoordinator())
}
