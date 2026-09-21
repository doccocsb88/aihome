import Foundation

enum RatingPromptTracker {
    private enum Keys {
        static let hasRated = "popupRating.hasCompletedRating"
        static let hasShownFirstResultPrompt = "popupRating.hasShownFirstResultPrompt"
        static let appSessionCount = "popupRating.appSessionCount"
        static let deferredHomePrompt = "popupRating.deferredHomePrompt"
    }

    private static var currentSessionNumber = 0
    private static var hasShownHomePromptThisSession = false
    private static var hasAttemptedSessionFlowThisSession = false

    static var hasRated: Bool {
        UserDefaults.standard.bool(forKey: Keys.hasRated)
    }

    static func recordSessionOpen() {
        let nextSessionNumber = UserDefaults.standard.integer(forKey: Keys.appSessionCount) + 1
        UserDefaults.standard.set(nextSessionNumber, forKey: Keys.appSessionCount)
        currentSessionNumber = nextSessionNumber
        hasShownHomePromptThisSession = false
        hasAttemptedSessionFlowThisSession = false
    }

    static func shouldPresentSessionFlow(isPremium: Bool, hasSeenOnboarding: Bool) -> Bool {
        guard currentSessionNumber >= 2,
              hasSeenOnboarding,
              !isPremium,
              !hasAttemptedSessionFlowThisSession else { return false }

        hasAttemptedSessionFlowThisSession = true
        if currentSessionNumber == 2 {
            UserDefaults.standard.set(true, forKey: Keys.deferredHomePrompt)
        }
        return true
    }

    static func shouldShowHomePromptOnAppear() -> Bool {
        guard !hasRated else { return false }
        guard currentSessionNumber == 2 || UserDefaults.standard.bool(forKey: Keys.deferredHomePrompt) else {
            return false
        }
        guard !hasAttemptedSessionFlowThisSession else { return false }
        guard !hasShownHomePromptThisSession else { return false }

        hasShownHomePromptThisSession = true
        UserDefaults.standard.set(false, forKey: Keys.deferredHomePrompt)
        return true
    }

    static func shouldShowFirstResultPrompt() -> Bool {
        guard !hasRated else { return false }
        guard !UserDefaults.standard.bool(forKey: Keys.hasShownFirstResultPrompt) else {
            return false
        }

        UserDefaults.standard.set(true, forKey: Keys.hasShownFirstResultPrompt)
        return true
    }
}
