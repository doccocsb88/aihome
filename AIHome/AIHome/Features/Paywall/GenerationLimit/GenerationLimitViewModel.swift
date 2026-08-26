import Foundation
import Observation

@Observable
final class GenerationLimitViewModel {
    private let userManager = UserManager.shared

    var freeGenerationsRemaining: Int {
        userManager.freeUsageRemaining
    }

    var freeGenerationLimit: Int {
        userManager.freeUsageLimit
    }

    var isPro: Bool {
        userManager.isPremium
    }

    var isUsageLocked: Bool {
        userManager.isUsageLocked
    }
    
    func refreshPremiumStatus() async {
        await userManager.refreshPremiumStatus()
    }
}
