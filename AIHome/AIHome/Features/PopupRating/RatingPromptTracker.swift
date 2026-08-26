import Foundation

enum RatingPromptTracker {
    private enum Keys {
        static let hasRated = "popupRating.hasCompletedRating"
        static let hasShownFirstResultPrompt = "popupRating.hasShownFirstResultPrompt"
        static let appSessionCount = "popupRating.appSessionCount"
    }

    private static var currentSessionNumber = 0
    private static var hasShownHomePromptThisSession = false

    static var hasRated: Bool {
        UserDefaults.standard.bool(forKey: Keys.hasRated)
    }

    static func recordSessionOpen() {
        let nextSessionNumber = UserDefaults.standard.integer(forKey: Keys.appSessionCount) + 1
        UserDefaults.standard.set(nextSessionNumber, forKey: Keys.appSessionCount)
        currentSessionNumber = nextSessionNumber
        hasShownHomePromptThisSession = false
    }

    static func shouldShowHomePromptOnAppear() -> Bool {
        guard !hasRated else { return false }
        guard currentSessionNumber == 2 else { return false }
        guard !hasShownHomePromptThisSession else { return false }

        hasShownHomePromptThisSession = true
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
