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
}

struct AdsTypeConfig: Codable, Equatable {
    var enabled: Bool
    var adsId: String

    static let empty = AdsTypeConfig(enabled: false, adsId: "")
}

struct RewardedAdsConfig: Codable, Equatable {
    var enabled: Bool
    var generateAdsId: String
    var regenerateAdsId: String

    static let empty = RewardedAdsConfig(enabled: false, generateAdsId: "", regenerateAdsId: "")
}

struct AdsInfoConfig: Codable, Equatable {
    var enabled: Bool
    var openAds: AdsTypeConfig
    var interAds: AdsTypeConfig
    var rewardedAds: RewardedAdsConfig
    var bannerAds: AdsTypeConfig

    static let defaultValue = AdsInfoConfig(
        enabled: true,
        openAds: .init(enabled: true, adsId: "05a37b30d8cee5ff"),
        interAds: .init(enabled: true, adsId: "2024866b95177a63"),
        rewardedAds: .init(enabled: true, generateAdsId: "d4c21fc7205f62a0", regenerateAdsId: "a3a09e4d782ed80b"),
        bannerAds: .init(enabled: false, adsId: "")
    )

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
        static let legacyAdsPlacements = "ads_placements"
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
        settings.minimumFetchInterval = 0
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

        if let legacyGate = legacyAdsGateFromPlacementsValue() {
            AppLogger.logAction(
                "Remote Config ads_gate",
                details: "raw=\(rawValue), parsed_legacy=\(legacyGate.jsonString)"
            )
            return legacyGate
        }

        AppLogger.logAction(
            "Remote Config ads_gate",
            details: "raw=\(rawValue), parsed_default=\(AdsGateConfig.defaultValue.jsonString)"
        )
        return AdsGateConfig.defaultValue
    }

    private func legacyAdsGateFromPlacementsValue() -> AdsGateConfig? {
        let rawValue = remoteConfig[Keys.legacyAdsPlacements].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if !rawValue.isEmpty,
           let data = rawValue.data(using: .utf8),
           let parsedValue: LegacyAdsPlacementsConfig = {
               let decoder = JSONDecoder()
               decoder.keyDecodingStrategy = .convertFromSnakeCase
               return (try? decoder.decode(LegacyAdsPlacementsConfig.self, from: data))
            }() {
            return parsedValue.asGateConfig
        }

        let hasLegacyValues =
            hasNonStaticValue(for: Keys.maxEnable) ||
            hasNonStaticValue(for: Keys.maxOpenSplashEnable) ||
            hasNonStaticValue(for: Keys.maxOpenResumeEnable) ||
            hasNonStaticValue(for: Keys.maxRewardedGenerateEnable) ||
            hasNonStaticValue(for: Keys.maxRewardedRegenerateEnable) ||
            hasNonStaticValue(for: Keys.maxInterCloseEditEnable) ||
            hasNonStaticValue(for: Keys.maxInterCloseIapEnable) ||
            hasNonStaticValue(for: Keys.maxInterCloseResultEnable) ||
            hasNonStaticValue(for: Keys.maxAdsIntervalSeconds) ||
            hasNonStaticValue(for: Keys.maxPaywallDismissCountBeforeAds)

        if hasLegacyValues {
            return AdsGateConfig(
                intervalSeconds: max(remoteConfig[Keys.maxAdsIntervalSeconds].numberValue.intValue, 0),
                paywallDismissCountBeforeAds: max(remoteConfig[Keys.maxPaywallDismissCountBeforeAds].numberValue.intValue, 0),
                placements: AdsPlacement.allCases.filter { placement in
                    switch placement {
                    case .openSplash:
                        return remoteConfig[Keys.maxOpenSplashEnable].boolValue
                    case .openResume:
                        return remoteConfig[Keys.maxOpenResumeEnable].boolValue
                    case .rewardedGenerate:
                        return remoteConfig[Keys.maxRewardedGenerateEnable].boolValue
                    case .rewardedRegenerate:
                        return remoteConfig[Keys.maxRewardedRegenerateEnable].boolValue
                    case .interCloseEdit:
                        return remoteConfig[Keys.maxInterCloseEditEnable].boolValue
                    case .interCloseIap:
                        return remoteConfig[Keys.maxInterCloseIapEnable].boolValue
                    case .interCloseResult:
                        return remoteConfig[Keys.maxInterCloseResultEnable].boolValue
                    }
                }
            )
        }

        return nil
    }

    private func hasNonStaticValue(for key: String) -> Bool {
        remoteConfig.configValue(forKey: key).source != .static
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

    var maxEnable: Bool { adsInfo.enabled }
    var maxOpenSplashEnable: Bool { adsInfo.openAds.enabled }
    var maxOpenResumeEnable: Bool { adsInfo.openAds.enabled }
    var maxRewardedGenerateEnable: Bool { adsInfo.rewardedAds.enabled }
    var maxRewardedRegenerateEnable: Bool { adsInfo.rewardedAds.enabled }
    var maxInterCloseEditEnable: Bool { adsInfo.interAds.enabled }
    var maxInterCloseIapEnable: Bool { adsInfo.interAds.enabled }
    var maxInterCloseResultEnable: Bool { adsInfo.interAds.enabled }
    var maxAdsIntervalSeconds: Int { adsGate.intervalSeconds }
    var maxPaywallDismissCountBeforeAds: Int { adsGate.paywallDismissCountBeforeAds }

    private func syncAnalyticsUserProperties() {
        Analytics.setUserProperty(trialEnable ? "on" : "off", forName: "rc_trial_screen")
        Analytics.setUserProperty(homeFeatureOrderString, forName: "rc_home_feature_order")
        Analytics.setUserProperty(String(freeCreditCount), forName: "rc_free_credit")
        Analytics.setUserProperty(onboardingScreens ? "true" : "false", forName: "rc_onboarding_screens")
        Analytics.setUserProperty(maxEnable ? "true" : "false", forName: "rc_ads_info_enabled")
        Analytics.setUserProperty(maxOpenSplashEnable ? "true" : "false", forName: "rc_ads_open_enabled")
        Analytics.setUserProperty(maxInterCloseEditEnable ? "true" : "false", forName: "rc_ads_inter_enabled")
        Analytics.setUserProperty(maxRewardedGenerateEnable ? "true" : "false", forName: "rc_ads_rewarded_enabled")
        Analytics.setUserProperty(adsInfo.bannerAds.enabled ? "true" : "false", forName: "rc_ads_banner_enabled")
        Analytics.setUserProperty(String(maxAdsIntervalSeconds), forName: "rc_ads_gate_interval_seconds")
        Analytics.setUserProperty(String(maxPaywallDismissCountBeforeAds), forName: "rc_ads_gate_paywall_dismiss_count_before_ads")
    }
}

private struct LegacyAdsPlacementsConfig: Codable {
    var enabled: Bool
    var openSplashEnabled: Bool
    var openResumeEnabled: Bool
    var rewardedGenerateEnabled: Bool
    var rewardedRegenerateEnabled: Bool
    var interCloseEditEnabled: Bool
    var interCloseIapEnabled: Bool
    var interCloseResultEnabled: Bool
    var adsIntervalSeconds: Int
    var paywallDismissCountBeforeAds: Int

    var asGateConfig: AdsGateConfig {
        AdsGateConfig(
            intervalSeconds: adsIntervalSeconds,
            paywallDismissCountBeforeAds: paywallDismissCountBeforeAds,
            placements: AdsPlacement.allCases.filter { placement in
                switch placement {
                case .openSplash:
                    return openSplashEnabled
                case .openResume:
                    return openResumeEnabled
                case .rewardedGenerate:
                    return rewardedGenerateEnabled
                case .rewardedRegenerate:
                    return rewardedRegenerateEnabled
                case .interCloseEdit:
                    return interCloseEditEnabled
                case .interCloseIap:
                    return interCloseIapEnabled
                case .interCloseResult:
                    return interCloseResultEnabled
                }
            }
        )
    }
}
