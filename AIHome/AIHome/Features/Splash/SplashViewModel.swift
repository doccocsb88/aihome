import Foundation
import Observation
import SwiftUI

@Observable
final class SplashViewModel {
    var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    @MainActor
    func determineNextRoute() -> AppRoute {
        guard !hasSeenOnboarding, RemoteConfigManager.shared.onboardingScreens else {
            return .mainTab
        }

        return .onboardingIntro
    }
}
