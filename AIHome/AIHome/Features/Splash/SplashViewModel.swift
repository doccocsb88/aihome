import Foundation
import Observation
import SwiftUI

@Observable
final class SplashViewModel {
    var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    func determineNextRoute() -> AppRoute {
        return hasSeenOnboarding ? .mainTab : .onboardingIntro
    }
}
