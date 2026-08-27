import FirebaseAnalytics
import FirebaseRemoteConfig
import Combine
import Foundation
import Observation

enum AdsPlacement: String, Codable, CaseIterable, Equatable {
    case openSplash = "open_splash"
    case openResume = "open_resume"
    case rewardedGenerate = "rewarded_generate"
    case rewardedRegenerate = "rewarded_regenerate"
    case interCloseEdit = "inter_close_edit"
    case interCloseIap = "inter_close_iap"
    case interCloseResult = "inter_close_result"
    case bannerHome = "banner_home"
    case bannerResult = "banner_result"

    var adKind: AdsAdKind {
        switch self {
        case .openSplash, .openResume:
            return .appOpen
        case .rewardedGenerate, .rewardedRegenerate:
            return .rewarded
        case .interCloseEdit, .interCloseIap, .interCloseResult:
            return .interstitial
        case .bannerHome, .bannerResult:
            return .banner
        }
    }

    var isFullscreen: Bool {
        adKind != .banner
    }
}

enum AdsAdKind {
    case appOpen
    case interstitial
    case rewarded
    case banner
}

struct AdsPlacementConfig: Codable, Equatable {
    var enabled: Bool
    var adsId: String

    static let empty = AdsPlacementConfig(enabled: false, adsId: "")
}

struct AdsInfoConfig: Codable, Equatable {
    var enabled: Bool
    var placements: [AdsPlacement: AdsPlacementConfig]

    static let defaultValue = AdsInfoConfig(
        enabled: true,
        placements: [
            .openSplash: .init(enabled: true, adsId: "05a37b30d8cee5ff"),
            .openResume: .init(enabled: true, adsId: "ccb2f614ccdfd440"),
            .rewardedGenerate: .init(enabled: true, adsId: "d4c21fc7205f62a0"),
            .rewardedRegenerate: .init(enabled: true, adsId: "a3a09e4d782ed80b"),
            .interCloseEdit: .init(enabled: true, adsId: "2024866b95177a63"),
            .interCloseIap: .init(enabled: true, adsId: "cc3c5cb6f6a84a14"),
            .interCloseResult: .init(enabled: true, adsId: "34a8c80d44b9af2d"),
            .bannerHome: .init(enabled: false, adsId: ""),
            .bannerResult: .init(enabled: false, adsId: "")
        ]
    )

    func placementConfig(for placement: AdsPlacement) -> AdsPlacementConfig {
        placements[placement] ?? .empty
    }

    func isEnabled(for placement: AdsPlacement) -> Bool {
        enabled && placementConfig(for: placement).enabled
    }

    func adsId(for placement: AdsPlacement) -> String {
        placementConfig(for: placement).adsId
    }

    var jsonString: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase

        guard let data = try? encoder.encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}

struct AdsGateConfig: Codable, Equatable {
    var intervalSeconds: Int
    var paywallDismissCountBeforeAds: Int
    var placements: [AdsPlacement]

    static let defaultValue = AdsGateConfig(
        intervalSeconds: 30,
        paywallDismissCountBeforeAds: 0,
        placements: AdsPlacement.allCases
    )

    func allows(_ placement: AdsPlacement) -> Bool {
        placements.contains(placement)
    }

    var jsonString: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase

        guard let data = try? encoder.encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return json
    }
}

private enum RemoteConfigCachePolicy {
    static let minimumFetchInterval: TimeInterval = 60 * 60
}

@MainActor
@Observable
final class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    private enum Keys {
        static let trialEnable = "trialEnable"
        static let homeFeatureOrder = "home_feature_order"
        static let freeCreditCount = "free_credit_count"
        static let onboardingScreens = "onboarding_screens"
        static let homeGPTProviderKind = "home_gpt_provider_kind"
        static let adsInfo = "ads_info"
        static let adsGate = "ads_gate"
    }

    private let remoteConfig: RemoteConfig
    private let initialFetchCompletionSubject = PassthroughSubject<Void, Never>()
    private var fetchTask: Task<Void, Never>?
    private(set) var trialEnable: Bool
    private(set) var homeFeatureOrder: [String]
    private(set) var freeCreditCount: Int
    private(set) var onboardingScreens: Bool
    private(set) var homeGPTProviderKind: HomeGPTProviderKind
    private(set) var adsInfo: AdsInfoConfig
    private(set) var adsGate: AdsGateConfig
    private(set) var hasCompletedInitialFetch: Bool

    private init(remoteConfig: RemoteConfig = .remoteConfig()) {
        self.remoteConfig = remoteConfig
        self.trialEnable = false
        self.homeFeatureOrder = ["interior", "exterior", "garden", "ref_style", "remove_obj", "replace_obj", "new_flooring", "new_walls"]
        self.freeCreditCount = 3
        self.onboardingScreens = true
        self.homeGPTProviderKind = .homeAIBackend
        self.adsInfo = .defaultValue
        self.adsGate = .defaultValue
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
        settings.minimumFetchInterval = RemoteConfigCachePolicy.minimumFetchInterval
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            Keys.trialEnable: false as NSObject,
            Keys.homeFeatureOrder: homeFeatureOrderJSON as NSString,
            Keys.freeCreditCount: freeCreditCount as NSNumber,
            Keys.onboardingScreens: onboardingScreens as NSObject,
            Keys.homeGPTProviderKind: homeGPTProviderKind.rawValue as NSString,
            Keys.adsInfo: adsInfoJSON as NSString,
            Keys.adsGate: adsGateJSON as NSString
        ])
    }

    private func syncValues() {
        trialEnable = remoteConfig[Keys.trialEnable].boolValue
        homeFeatureOrder = homeFeatureOrderValue(fallback: homeFeatureOrder)
        freeCreditCount = max(remoteConfig[Keys.freeCreditCount].numberValue.intValue, 0)
        onboardingScreens = onboardingScreensValue()
        homeGPTProviderKind = homeGPTProviderKindValue(fallback: homeGPTProviderKind)
        adsInfo = adsInfoValue()
        adsGate = adsGateValue()
        HomeGPTProviderRegistry.applyRemoteDefault(homeGPTProviderKind)
        syncAnalyticsUserProperties()
        AppLogger.logAction(
            "Remote Config syncValues",
            details: "trialEnable=\(trialEnable), freeCreditCount=\(freeCreditCount), homeGPTProviderKind=\(homeGPTProviderKind.rawValue), adsInfo=\(adsInfo.jsonString), adsGate=\(adsGate.jsonString)"
        )
    }

    private func adsInfoValue() -> AdsInfoConfig {
        let rawValue = remoteConfig[Keys.adsInfo].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !rawValue.isEmpty,
           let data = rawValue.data(using: .utf8),
           let parsedValue: AdsInfoConfig = {
               let decoder = JSONDecoder()
               decoder.keyDecodingStrategy = .convertFromSnakeCase
               return (try? decoder.decode(AdsInfoConfig.self, from: data))
           }() {
            AppLogger.logAction(
                "Remote Config ads_info",
                details: "raw=\(rawValue), parsed=\(parsedValue.jsonString)"
            )
            return parsedValue
        }

        AppLogger.logAction(
            "Remote Config ads_info",
            details: "raw=\(rawValue), parsed_default=\(AdsInfoConfig.defaultValue.jsonString)"
        )
        return AdsInfoConfig.defaultValue
    }

    private func adsGateValue() -> AdsGateConfig {
        let rawValue = remoteConfig[Keys.adsGate].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !rawValue.isEmpty,
           let data = rawValue.data(using: .utf8),
           let parsedValue: AdsGateConfig = {
               let decoder = JSONDecoder()
               decoder.keyDecodingStrategy = .convertFromSnakeCase
               return (try? decoder.decode(AdsGateConfig.self, from: data))
            }() {
            AppLogger.logAction(
                "Remote Config ads_gate",
                details: "raw=\(rawValue), parsed=\(parsedValue.jsonString)"
            )
            return parsedValue
        }

        AppLogger.logAction(
            "Remote Config ads_gate",
            details: "raw=\(rawValue), parsed_default=\(AdsGateConfig.defaultValue.jsonString)"
        )
        return AdsGateConfig.defaultValue
    }

    private func homeGPTProviderKindValue(fallback: HomeGPTProviderKind) -> HomeGPTProviderKind {
        let rawValue = remoteConfig[Keys.homeGPTProviderKind].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let parsedValue = HomeGPTProviderKind(rawValue: rawValue) ?? fallback
        AppLogger.logAction(
            "Remote Config home_gpt_provider_kind",
            details: "raw=\(rawValue), parsed=\(parsedValue.rawValue)"
        )
        return parsedValue
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

    private var adsInfoJSON: String {
        adsInfo.jsonString
    }

    private var adsGateJSON: String {
        adsGate.jsonString
    }

    private func syncAnalyticsUserProperties() {
        Analytics.setUserProperty(trialEnable ? "on" : "off", forName: "rc_trial_screen")
        Analytics.setUserProperty(homeFeatureOrderString, forName: "rc_home_feature_order")
        Analytics.setUserProperty(String(freeCreditCount), forName: "rc_free_credit")
        Analytics.setUserProperty(onboardingScreens ? "true" : "false", forName: "rc_onboarding_screens")
        Analytics.setUserProperty(adsInfo.enabled ? "true" : "false", forName: "rc_ads_info_enabled")

        for placement in AdsPlacement.allCases {
            let enabledValue = adsInfo.isEnabled(for: placement) ? "true" : "false"
            Analytics.setUserProperty(enabledValue, forName: "rc_ads_\(placement.rawValue)_enabled")
        }

        Analytics.setUserProperty(String(adsGate.intervalSeconds), forName: "rc_ads_gate_interval_seconds")
        Analytics.setUserProperty(String(adsGate.paywallDismissCountBeforeAds), forName: "rc_ads_gate_paywall_dismiss_count_before_ads")
    }
}
