import Foundation
import Observation

enum UserAccessState: String {
    case free
    case premium
}

@MainActor
@Observable
final class UserManager {
    static let shared = UserManager()

    private enum Keys {
        static let isProCached = "isProCached"
        static let freeUsageCount = "freeUsageCount"
        static let freeUsageBonusCount = "freeUsageBonusCount"
        static let freeGenerationsRemaining = "freeGenerationsRemaining"
        static let hasMigratedRemainingUsage = "hasMigratedRemainingUsage"
    }

    private let userDefaults: UserDefaults

    private(set) var accessState: UserAccessState
    private(set) var freeUsageCount: Int
    private(set) var bonusFreeUsageCount: Int
    private let defaultFreeUsageLimit: Int

    var isPremium: Bool {
        accessState == .premium
    }

    var isFreeUser: Bool {
        accessState == .free
    }

    var freeUsageRemaining: Int {
        max(freeUsageLimit - freeUsageCount, 0)
    }

    var freeUsageLimit: Int {
        RemoteConfigManager.shared.freeCreditCount + bonusFreeUsageCount
    }

    var isUsageLocked: Bool {
        isFreeUser && freeUsageRemaining <= 0
    }

    var usageProgressText: String {
        "\(freeUsageRemaining)/\(freeUsageLimit)"
    }

    private init(
        userDefaults: UserDefaults = .standard,
        freeUsageLimit: Int = 3
    ) {
        self.userDefaults = userDefaults
        self.defaultFreeUsageLimit = freeUsageLimit

        let cachedPremium = userDefaults.bool(forKey: Keys.isProCached)
        self.accessState = cachedPremium ? .premium : .free
        self.bonusFreeUsageCount = UserManager.loadFreeUsageBonusCount(userDefaults: userDefaults)
        self.freeUsageCount = UserManager.loadFreeUsageCount(
            userDefaults: userDefaults,
            freeUsageLimit: freeUsageLimit
        )
    }

    func setPremiumStatus(_ isPremium: Bool) {
        accessState = isPremium ? .premium : .free
        userDefaults.set(isPremium, forKey: Keys.isProCached)
    }

    @discardableResult
    func recordFreeUsage() -> Bool {
        guard isFreeUser, !isUsageLocked else {
            return false
        }

        freeUsageCount = min(freeUsageCount + 1, freeUsageLimit)
        persistUsage()
        return true
    }

    @discardableResult
    func grantFreeUsage() -> Bool {
        guard isFreeUser else {
            return false
        }

        let previousLimit = freeUsageLimit
        bonusFreeUsageCount = max(bonusFreeUsageCount + 1, 0)
        persistUsage()
        return freeUsageLimit != previousLimit
    }

    @discardableResult
    func consumeUsageIfAllowed() -> Bool {
        guard canUsePremiumFeature else {
            return false
        }

        if isFreeUser {
            recordFreeUsage()
        }

        return true
    }

    var canUsePremiumFeature: Bool {
        isPremium || freeUsageRemaining > 0
    }

    func resetFreeUsage() {
        freeUsageCount = 0
        bonusFreeUsageCount = 0
        persistUsage()
    }

    func refreshPremiumStatus() async {
        do {
            let isPremium = try await AdaptyPurchaseService.shared.refreshPremiumStatus()
            setPremiumStatus(isPremium)
        } catch {
            setPremiumStatus(userDefaults.bool(forKey: Keys.isProCached))
        }
    }

    private func persistUsage() {
        userDefaults.set(freeUsageCount, forKey: Keys.freeUsageCount)
        userDefaults.set(bonusFreeUsageCount, forKey: Keys.freeUsageBonusCount)
        userDefaults.set(freeUsageRemaining, forKey: Keys.freeGenerationsRemaining)
    }

    private static func loadFreeUsageBonusCount(userDefaults: UserDefaults) -> Int {
        if let savedBonusCount = userDefaults.object(forKey: Keys.freeUsageBonusCount) as? Int {
            return max(savedBonusCount, 0)
        }

        return 0
    }

    private static func loadFreeUsageCount(
        userDefaults: UserDefaults,
        freeUsageLimit: Int
    ) -> Int {
        if let savedCount = userDefaults.object(forKey: Keys.freeUsageCount) as? Int {
            return min(max(savedCount, 0), freeUsageLimit)
        }

        guard userDefaults.bool(forKey: Keys.hasMigratedRemainingUsage) == false,
              let savedRemaining = userDefaults.object(forKey: Keys.freeGenerationsRemaining) as? Int else {
            userDefaults.set(true, forKey: Keys.hasMigratedRemainingUsage)
            userDefaults.set(0, forKey: Keys.freeUsageCount)
            userDefaults.set(freeUsageLimit, forKey: Keys.freeGenerationsRemaining)
            return 0
        }

        let migratedCount = min(max(freeUsageLimit - savedRemaining, 0), freeUsageLimit)
        userDefaults.set(true, forKey: Keys.hasMigratedRemainingUsage)
        userDefaults.set(migratedCount, forKey: Keys.freeUsageCount)
        userDefaults.set(max(freeUsageLimit - migratedCount, 0), forKey: Keys.freeGenerationsRemaining)
        return migratedCount
    }
}
