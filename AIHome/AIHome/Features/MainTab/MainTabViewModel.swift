import Foundation
import Observation

enum MainTab: CaseIterable {
    case home
    case inspiration
    case history
    case settings
}

@Observable
final class MainTabViewModel {
    var selectedTab: MainTab = .home
    var freeGenerationsRemaining: Int = 3
    var isPro: Bool = false
    
    init() {
        // Load from UserDefaults or storage
        self.freeGenerationsRemaining = UserDefaults.standard.integer(forKey: "freeGenerationsRemaining")
        if self.freeGenerationsRemaining == 0 && !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
            // Default value setup
            self.freeGenerationsRemaining = 3
            UserDefaults.standard.set(3, forKey: "freeGenerationsRemaining")
        }
        self.isPro = UserDefaults.standard.bool(forKey: "isProCached")
    }

    func refreshPremiumStatus() async {
        do {
            isPro = try await AdaptyPurchaseService.shared.refreshPremiumStatus()
        } catch {
            isPro = UserDefaults.standard.bool(forKey: "isProCached")
        }
    }
}
