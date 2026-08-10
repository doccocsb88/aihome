import FirebaseAnalytics
import FirebaseRemoteConfig
import Combine
import Foundation
import Observation

@MainActor
@Observable
final class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    enum ResultSavePrompt: String {
        case none
        case autoAsk = "auto_ask"
        case highlight
    }

    enum OnboardingPaywallPosition: String {
        case afterOb1 = "after_ob1"
        case afterOb2 = "after_ob2"
        case afterOb3 = "after_ob3"
    }

    private enum Keys {
        static let trialEnable = "trialEnable"
        static let onboardingPaywallDismissible = "onboarding_paywall_dismissible"
        static let resultSavePrompt = "result_save_prompt"
        static let homeFeatureOrder = "home_feature_order"
        static let freeCreditCount = "free_credit_count"
        static let onboardingScreens = "onboarding_screens"
        static let onboardingPaywallPosition = "onboarding_paywall_position"
    }

    private let remoteConfig: RemoteConfig
    private let initialFetchCompletionSubject = PassthroughSubject<Void, Never>()
    private var fetchTask: Task<Void, Never>?
    private(set) var trialEnable: Bool
    private(set) var onboardingPaywallDismissible: Bool
    private(set) var resultSavePrompt: ResultSavePrompt
    private(set) var homeFeatureOrder: [String]
    private(set) var freeCreditCount: Int
    private(set) var onboardingScreens: [Int]
    private(set) var onboardingPaywallPosition: OnboardingPaywallPosition
    private(set) var hasCompletedInitialFetch: Bool

    private init(remoteConfig: RemoteConfig = .remoteConfig()) {
        self.remoteConfig = remoteConfig
        self.trialEnable = false
        self.onboardingPaywallDismissible = true
        self.resultSavePrompt = .none
        self.homeFeatureOrder = ["interior", "exterior", "garden", "ref_style", "remove_obj", "replace_obj", "new_flooring", "new_walls"]
        self.freeCreditCount = 3
        self.onboardingScreens = [1, 2, 3]
        self.onboardingPaywallPosition = .afterOb3
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
            Keys.onboardingPaywallDismissible: true as NSObject,
            Keys.resultSavePrompt: ResultSavePrompt.none.rawValue as NSString,
            Keys.homeFeatureOrder: homeFeatureOrderString as NSString,
            Keys.freeCreditCount: freeCreditCount as NSNumber,
            Keys.onboardingScreens: onboardingScreensString as NSString,
            Keys.onboardingPaywallPosition: OnboardingPaywallPosition.afterOb3.rawValue as NSString
        ])
    }

    private func syncValues() {
        trialEnable = remoteConfig[Keys.trialEnable].boolValue
        onboardingPaywallDismissible = remoteConfig[Keys.onboardingPaywallDismissible].boolValue
        resultSavePrompt = ResultSavePrompt(rawValue: remoteConfig[Keys.resultSavePrompt].stringValue) ?? .none
        homeFeatureOrder = stringList(for: Keys.homeFeatureOrder, fallback: homeFeatureOrder)
        freeCreditCount = max(remoteConfig[Keys.freeCreditCount].numberValue.intValue, 0)
        onboardingScreens = onboardingScreenIndexes(for: Keys.onboardingScreens, fallback: onboardingScreens)
        onboardingPaywallPosition = OnboardingPaywallPosition(rawValue: remoteConfig[Keys.onboardingPaywallPosition].stringValue) ?? .afterOb3
        syncAnalyticsUserProperties()
        AppLogger.logAction(
            "Remote Config syncValues",
            details: "trialEnable=\(trialEnable), freeCreditCount=\(freeCreditCount), resultSavePrompt=\(resultSavePrompt.rawValue)"
        )
    }

    private func stringList(for key: String, fallback: [String]) -> [String] {
        let values = remoteConfig[key].stringValue
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return values.isEmpty ? fallback : values
    }

    private func onboardingScreenIndexes(for key: String, fallback: [Int]) -> [Int] {
        let indexes = remoteConfig[key].stringValue
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        return indexes.isEmpty ? fallback : indexes
    }

    private var homeFeatureOrderString: String {
        homeFeatureOrder.joined(separator: ",")
    }

    private var onboardingScreensString: String {
        onboardingScreens.map(String.init).joined(separator: ",")
    }

    private func syncAnalyticsUserProperties() {
        Analytics.setUserProperty(trialEnable ? "on" : "off", forName: "rc_trial_screen")
        Analytics.setUserProperty(onboardingPaywallDismissible ? "true" : "false", forName: "rc_paywall_dismissible")
        Analytics.setUserProperty(resultSavePrompt.rawValue, forName: "rc_result_save_prompt")
        Analytics.setUserProperty(homeFeatureOrderString, forName: "rc_home_feature_order")
        Analytics.setUserProperty(String(freeCreditCount), forName: "rc_free_credit")
        Analytics.setUserProperty(onboardingScreensString, forName: "rc_onboarding_screens")
        Analytics.setUserProperty(onboardingPaywallPosition.rawValue, forName: "rc_paywall_position")
        Analytics.setUserProperty(String(freeCreditCount), forName: "rc_generation_result_count")
    }
}
