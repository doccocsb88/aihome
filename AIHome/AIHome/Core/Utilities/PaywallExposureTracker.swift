import Foundation

enum PaywallExposureTracker {
    private enum Keys {
        static let dismissCount = "ads.paywallDismissCount"
    }

    static var dismissCount: Int {
        let value = UserDefaults.standard.integer(forKey: Keys.dismissCount)
        return max(value, 0)
    }

    static func recordDismiss() {
        let nextCount = dismissCount + 1
        UserDefaults.standard.set(nextCount, forKey: Keys.dismissCount)
    }
}
