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
        static let maxEnable = "max_enable"
        static let maxOpenSplashEnable = "max_open_splash_enable"
        static let maxOpenResumeEnable = "max_open_resume_enable"
        static let maxRewardedGenerateEnable = "max_rewarded_generate_enable"
        static let maxRewardedRegenerateEnable = "max_rewarded_regenerate_enable"
        static let maxInterCloseEditEnable = "max_inter_close_edit_enable"
        static let maxInterCloseIapEnable = "max_inter_close_iap_enable"
        static let maxInterCloseResultEnable = "max_inter_close_result_enable"
        static let maxAdsIntervalSeconds = "max_ads_interval_seconds"
        static let maxPaywallDismissCountBeforeAds = "max_paywall_dismiss_count_before_ads"
    }

    private let remoteConfig: RemoteConfig
    private let initialFetchCompletionSubject = PassthroughSubject<Void, Never>()
    private var fetchTask: Task<Void, Never>?
    private(set) var trialEnable: Bool
    private(set) var homeFeatureOrder: [String]
    private(set) var freeCreditCount: Int
    private(set) var onboardingScreens: Bool
    private(set) var maxEnable: Bool
    private(set) var maxOpenSplashEnable: Bool
    private(set) var maxOpenResumeEnable: Bool
    private(set) var maxRewardedGenerateEnable: Bool
    private(set) var maxRewardedRegenerateEnable: Bool
    private(set) var maxInterCloseEditEnable: Bool
    private(set) var maxInterCloseIapEnable: Bool
    private(set) var maxInterCloseResultEnable: Bool
    private(set) var maxAdsIntervalSeconds: Int
    private(set) var maxPaywallDismissCountBeforeAds: Int
    private(set) var hasCompletedInitialFetch: Bool

    private init(remoteConfig: RemoteConfig = .remoteConfig()) {
        self.remoteConfig = remoteConfig
        self.trialEnable = false
        self.homeFeatureOrder = ["interior", "exterior", "garden", "ref_style", "remove_obj", "replace_obj", "new_flooring", "new_walls"]
        self.freeCreditCount = 3
        self.onboardingScreens = true
        self.maxEnable = true
        self.maxOpenSplashEnable = true
        self.maxOpenResumeEnable = true
        self.maxRewardedGenerateEnable = true
        self.maxRewardedRegenerateEnable = true
        self.maxInterCloseEditEnable = true
        self.maxInterCloseIapEnable = true
        self.maxInterCloseResultEnable = true
        self.maxAdsIntervalSeconds = 30
        self.maxPaywallDismissCountBeforeAds = 3
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
            Keys.onboardingScreens: onboardingScreens as NSObject,
            Keys.maxEnable: maxEnable as NSObject,
            Keys.maxOpenSplashEnable: maxOpenSplashEnable as NSObject,
            Keys.maxOpenResumeEnable: maxOpenResumeEnable as NSObject,
            Keys.maxRewardedGenerateEnable: maxRewardedGenerateEnable as NSObject,
            Keys.maxRewardedRegenerateEnable: maxRewardedRegenerateEnable as NSObject,
            Keys.maxInterCloseEditEnable: maxInterCloseEditEnable as NSObject,
            Keys.maxInterCloseIapEnable: maxInterCloseIapEnable as NSObject,
            Keys.maxInterCloseResultEnable: maxInterCloseResultEnable as NSObject,
            Keys.maxAdsIntervalSeconds: maxAdsIntervalSeconds as NSNumber,
            Keys.maxPaywallDismissCountBeforeAds: maxPaywallDismissCountBeforeAds as NSNumber
        ])
    }

    private func syncValues() {
        trialEnable = remoteConfig[Keys.trialEnable].boolValue
        homeFeatureOrder = homeFeatureOrderValue(fallback: homeFeatureOrder)
        freeCreditCount = max(remoteConfig[Keys.freeCreditCount].numberValue.intValue, 0)
        onboardingScreens = onboardingScreensValue()
        maxEnable = remoteConfig[Keys.maxEnable].boolValue
        maxOpenSplashEnable = remoteConfig[Keys.maxOpenSplashEnable].boolValue
        maxOpenResumeEnable = remoteConfig[Keys.maxOpenResumeEnable].boolValue
        maxRewardedGenerateEnable = remoteConfig[Keys.maxRewardedGenerateEnable].boolValue
        maxRewardedRegenerateEnable = remoteConfig[Keys.maxRewardedRegenerateEnable].boolValue
        maxInterCloseEditEnable = remoteConfig[Keys.maxInterCloseEditEnable].boolValue
        maxInterCloseIapEnable = remoteConfig[Keys.maxInterCloseIapEnable].boolValue
        maxInterCloseResultEnable = remoteConfig[Keys.maxInterCloseResultEnable].boolValue
        maxAdsIntervalSeconds = max(remoteConfig[Keys.maxAdsIntervalSeconds].numberValue.intValue, 0)
        maxPaywallDismissCountBeforeAds = max(remoteConfig[Keys.maxPaywallDismissCountBeforeAds].numberValue.intValue, 0)
        syncAnalyticsUserProperties()
        AppLogger.logAction(
            "Remote Config syncValues",
            details: "trialEnable=\(trialEnable), freeCreditCount=\(freeCreditCount), maxEnable=\(maxEnable), maxAdsIntervalSeconds=\(maxAdsIntervalSeconds), maxPaywallDismissCountBeforeAds=\(maxPaywallDismissCountBeforeAds)"
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
        let parsedValue = remoteConfig[Keys.onboardingScreens].boolValue
        AppLogger.logAction(
            "Remote Config onboarding_screens",
            details: "parsed=\(parsedValue)"
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
        Analytics.setUserProperty(maxEnable ? "true" : "false", forName: "rc_max_enable")
        Analytics.setUserProperty(maxOpenSplashEnable ? "true" : "false", forName: "rc_max_open_splash")
        Analytics.setUserProperty(maxOpenResumeEnable ? "true" : "false", forName: "rc_max_open_resume")
        Analytics.setUserProperty(maxRewardedGenerateEnable ? "true" : "false", forName: "rc_max_rewarded_generate")
        Analytics.setUserProperty(maxRewardedRegenerateEnable ? "true" : "false", forName: "rc_max_rewarded_regenerate")
        Analytics.setUserProperty(maxInterCloseEditEnable ? "true" : "false", forName: "rc_max_inter_close_edit")
        Analytics.setUserProperty(maxInterCloseIapEnable ? "true" : "false", forName: "rc_max_inter_close_iap")
        Analytics.setUserProperty(maxInterCloseResultEnable ? "true" : "false", forName: "rc_max_inter_close_result")
        Analytics.setUserProperty(String(maxAdsIntervalSeconds), forName: "rc_max_ads_interval_seconds")
        Analytics.setUserProperty(String(maxPaywallDismissCountBeforeAds), forName: "rc_max_paywall_dismiss_count_before_ads")
    }
}
