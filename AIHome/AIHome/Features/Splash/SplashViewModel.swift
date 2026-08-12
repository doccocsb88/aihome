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
        guard !hasSeenOnboarding else {
            return .mainTab
        }

        return .onboardingIntro
    }
}
