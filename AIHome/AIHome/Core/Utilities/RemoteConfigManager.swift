import FirebaseAnalytics
import FirebaseRemoteConfig
import Combine
import Foundation
import Observation

@MainActor
@Observable
final class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    private enum Keys {
        static let trialEnable = "trialEnable"
        static let homeFeatureOrder = "home_feature_order"
        static let freeCreditCount = "free_credit_count"
        static let onboardingScreens = "onboarding_screens"
    }

    private let remoteConfig: RemoteConfig
    private let initialFetchCompletionSubject = PassthroughSubject<Void, Never>()
    private var fetchTask: Task<Void, Never>?
    private(set) var trialEnable: Bool
    private(set) var homeFeatureOrder: [String]
    private(set) var freeCreditCount: Int
    private(set) var onboardingScreens: Bool
    private(set) var hasCompletedInitialFetch: Bool

    private init(remoteConfig: RemoteConfig = .remoteConfig()) {
        self.remoteConfig = remoteConfig
        self.trialEnable = false
        self.homeFeatureOrder = ["interior", "exterior", "garden", "ref_style", "remove_obj", "replace_obj", "new_flooring", "new_walls"]
        self.freeCreditCount = 3
        self.onboardingScreens = true
        self.hasCompletedInitialFetch = false
        configureDefaults()
        syncValues()
    }

    func fetchAndActivate() async {
        if let fetchTask {
            await fetchTask.value
            return
        }

        let task = Task { @MainActor in
            await performFetchAndActivate()
        }
        fetchTask = task
        await task.value
        fetchTask = nil
    }

    var initialFetchCompletionPublisher: AnyPublisher<Void, Never> {
        if hasCompletedInitialFetch {
            return Just(()).eraseToAnyPublisher()
        }

        return initialFetchCompletionSubject.eraseToAnyPublisher()
    }

    private func performFetchAndActivate() async {
        defer {
            hasCompletedInitialFetch = true
            initialFetchCompletionSubject.send(())
        }

        do {
            let status = try await remoteConfig.fetchAndActivate()
            syncValues()
            AppLogger.logAction("Remote Config Activated", details: "\(status.rawValue)")
        } catch {
            AppLogger.logError("Remote Config Fetch Failed", error: error)
        }
    }

    private func configureDefaults() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            Keys.trialEnable: false as NSObject,
            Keys.homeFeatureOrder: homeFeatureOrderJSON as NSString,
            Keys.freeCreditCount: freeCreditCount as NSNumber,
            Keys.onboardingScreens: onboardingScreens as NSObject
        ])
    }

    private func syncValues() {
        trialEnable = remoteConfig[Keys.trialEnable].boolValue
        homeFeatureOrder = homeFeatureOrderValue(fallback: homeFeatureOrder)
        freeCreditCount = max(remoteConfig[Keys.freeCreditCount].numberValue.intValue, 0)
        onboardingScreens = onboardingScreensValue()
        syncAnalyticsUserProperties()
        AppLogger.logAction(
            "Remote Config syncValues",
            details: "trialEnable=\(trialEnable), freeCreditCount=\(freeCreditCount)"
        )
    }

    private func homeFeatureOrderValue(fallback: [String]) -> [String] {
        let rawValue = remoteConfig[Keys.homeFeatureOrder].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedValue = stringList(from: rawValue, fallback: fallback)
        AppLogger.logAction(
            "Remote Config home_feature_order",
            details: "raw=\(rawValue), parsed=\(parsedValue.joined(separator: ","))"
        )
        return parsedValue
    }

    private func onboardingScreensValue() -> Bool {
        let rawValue = remoteConfig[Keys.onboardingScreens].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedValue = remoteConfig[Keys.onboardingScreens].boolValue
        AppLogger.logAction(
            "Remote Config onboarding_screens",
            details: "raw=\(rawValue), parsed=\(parsedValue)"
        )
        return parsedValue
    }

    private func stringList(from rawValue: String, fallback: [String]) -> [String] {
        guard !rawValue.isEmpty else { return fallback }

        if let data = rawValue.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [String] {
            let values = jsonArray
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            if !values.isEmpty {
                return values
            }
        }

        let values = rawValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return values.isEmpty ? fallback : values
    }

    private var homeFeatureOrderString: String {
        homeFeatureOrder.joined(separator: ",")
    }

    private var homeFeatureOrderJSON: String {
        guard let data = try? JSONSerialization.data(withJSONObject: homeFeatureOrder),
              let json = String(data: data, encoding: .utf8) else {
            return homeFeatureOrderString
        }
        return json
    }

    private func syncAnalyticsUserProperties() {
        Analytics.setUserProperty(trialEnable ? "on" : "off", forName: "rc_trial_screen")
        Analytics.setUserProperty(homeFeatureOrderString, forName: "rc_home_feature_order")
        Analytics.setUserProperty(String(freeCreditCount), forName: "rc_free_credit")
        Analytics.setUserProperty(onboardingScreens ? "true" : "false", forName: "rc_onboarding_screens")
    }
}
