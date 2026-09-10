@preconcurrency import AppLovinSDK
import Foundation
import SwiftUI
import UIKit

@MainActor
final class AdsManager: NSObject {
    static let shared = AdsManager()

    private struct PendingAction {
        var completion: (() -> Void)?
    }

    private enum Configuration {
        static let sdkKey = "J2ks4TF6rLetzM0TgPvggyqLiCRTUJ1afPHWi0la24rZnZOul9gyfkD4JtAmbcua43fHqHHBzV20zrbR6Ilz5G"
    }

    private var appOpenAds: [AdsPlacement: MAAppOpenAd] = [:]
    private var rewardedAds: [AdsPlacement: MARewardedAd] = [:]
    private var interstitialAds: [AdsPlacement: MAInterstitialAd] = [:]
    private var bannerAds: [AdsPlacement: MAAdView] = [:]
    private var pendingActions: [AdsPlacement: PendingAction] = [:]
    private var retryAttempts: [AdsPlacement: Int] = [:]
    private var activeFullscreenPlacement: AdsPlacement?
    private var hasInitializedSDK = false
    private var hasHandledFirstForegroundActivation = false
    private var hasShownResumeThisForeground = false
    private var isPresentingFullscreenAd = false
    private var didCompleteColdStart = false
    private var lastFullscreenAdPresentedAt: Date?
    private var didUnlockAdsAfterPaywallGate = false
    private var consentFlowUserGeographyRawValue: Int = 0

    private override init() {
        super.init()
    }

    func configureIfNeeded() {
        guard !hasInitializedSDK else { return }
        hasInitializedSDK = true

        AppLogger.logAction(
            "MAX configureIfNeeded",
            details: "sdkKey=\(Configuration.sdkKey.prefix(6))..., paywallDismissCount=\(paywallDismissCount), threshold=\(paywallDismissThreshold), interval=\(adsIntervalSeconds)s"
        )

        let sdk = ALSdk.shared()
        let settings = sdk.settings
        settings.termsAndPrivacyPolicyFlowSettings.isEnabled = true
        settings.termsAndPrivacyPolicyFlowSettings.privacyPolicyURL = AppConfig.URL.privacyPolicy
        settings.termsAndPrivacyPolicyFlowSettings.termsOfServiceURL = AppConfig.URL.termsOfService
        settings.termsAndPrivacyPolicyFlowSettings.shouldShowTermsAndPrivacyPolicyAlertInGDPR = true
#if DEBUG
        settings.termsAndPrivacyPolicyFlowSettings.debugUserGeography = ALConsentFlowUserGeography(rawValue: 1) ?? .unknown
#endif

        let initConfig = ALSdkInitializationConfiguration(sdkKey: Configuration.sdkKey) { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }

        AppLogger.logAction("MAX SDK initializing", details: "sdkKey=\(Configuration.sdkKey.prefix(6))...")
        sdk.initialize(with: initConfig) { [weak self] (_: ALSdkConfiguration) in
            DispatchQueue.main.async {
                TrackingBootstrap.shared.consentFlowDidComplete()
                self?.consentFlowUserGeographyRawValue = ALSdk.shared().configuration.consentFlowUserGeography.rawValue
                self?.prepareAds()
            }
        }
    }

    var isGDPRRegion: Bool {
        consentFlowUserGeographyRawValue == 1 || AppEnvironmentService.shared.isDebug
    }

    func markColdStartFinished() {
        didCompleteColdStart = true
    }

    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            handleDidBecomeActive()
        case .inactive, .background:
            hasShownResumeThisForeground = false
        @unknown default:
            break
        }
    }

    func showAppOpenSplashIfReady(deadline: Date? = nil, completion: @escaping () -> Void) {
        trackAdEvent(.showRequested, placement: .openSplash, params: adStateParams(for: .openSplash))
        AppLogger.logAction("MAX request app open splash", details: adsRequestDetails(for: .openSplash))

        guard hasSeenOnboarding else {
            trackAdEvent(.showSkipped, placement: .openSplash, params: adStateParams(for: .openSplash, extra: ["skip_reason": "first_app_launch"]))
            AppLogger.logAction("MAX splash skipped", details: "first app launch")
            completion()
            return
        }

        let splashDeadline = deadline ?? Date().addingTimeInterval(8)
        Task { @MainActor in
            await self.presentAppOpenSplashIfReady(before: splashDeadline, completion: completion)
        }
    }

    func showAppOpenResumeIfReady() {
        trackAdEvent(.showRequested, placement: .openResume, params: adStateParams(for: .openResume))
        AppLogger.logAction("MAX request app open resume", details: adsRequestDetails(for: .openResume))
        guard didCompleteColdStart else {
            trackAdEvent(.showSkipped, placement: .openResume, params: adStateParams(for: .openResume, extra: ["skip_reason": "cold_start_not_finished"]))
            return
        }
        guard !hasShownResumeThisForeground else {
            trackAdEvent(.showSkipped, placement: .openResume, params: adStateParams(for: .openResume, extra: ["skip_reason": "already_shown_this_foreground"]))
            return
        }

        hasShownResumeThisForeground = true
        presentFullscreenAd(
            placement: .openResume,
            placementName: AdsPlacement.openResume.rawValue,
            completion: {},
            markColdStartCompletedAfterDismissal: false
        )
    }

    @discardableResult
    func showRewardedGenerateIfNeeded(completion: @escaping () -> Void) -> Bool {
        trackAdEvent(.showRequested, placement: .rewardedGenerate, params: adStateParams(for: .rewardedGenerate))
        AppLogger.logAction("MAX request rewarded generate", details: adsRequestDetails(for: .rewardedGenerate))
        guard shouldShowRewardedAds(for: .rewardedGenerate) else {
            trackAdEvent(.showSkipped, placement: .rewardedGenerate, params: adStateParams(for: .rewardedGenerate, extra: ["skip_reason": "not_usage_locked_or_ineligible"]))
            completion()
            return true
        }

        presentRewardedAdWhenReady(
            placement: .rewardedGenerate,
            completion: completion
        )
        return true
    }

    @discardableResult
    func showRewardedRegenerateIfNeeded(completion: @escaping () -> Void) -> Bool {
        trackAdEvent(.showRequested, placement: .rewardedRegenerate, params: adStateParams(for: .rewardedRegenerate))
        AppLogger.logAction("MAX request rewarded regenerate", details: adsRequestDetails(for: .rewardedRegenerate))
        guard shouldShowRewardedAds(for: .rewardedRegenerate) else {
            trackAdEvent(.showSkipped, placement: .rewardedRegenerate, params: adStateParams(for: .rewardedRegenerate, extra: ["skip_reason": "not_usage_locked_or_ineligible"]))
            completion()
            return true
        }

        presentRewardedAdWhenReady(
            placement: .rewardedRegenerate,
            completion: completion
        )
        return true
    }

    func showInterstitialCloseEdit(completion: @escaping () -> Void) {
        trackAdEvent(.showRequested, placement: .interCloseEdit, params: adStateParams(for: .interCloseEdit))
        AppLogger.logAction("MAX request inter close edit", details: adsRequestDetails(for: .interCloseEdit))
        presentFullscreenAd(
            placement: .interCloseEdit,
            placementName: AdsPlacement.interCloseEdit.rawValue,
            completion: completion,
            markColdStartCompletedAfterDismissal: false
        )
    }

    func showInterstitialCloseIap(completion: @escaping () -> Void) {
        trackAdEvent(.showRequested, placement: .interCloseIap, params: adStateParams(for: .interCloseIap))
        AppLogger.logAction("MAX request inter close iap", details: adsRequestDetails(for: .interCloseIap))
        presentFullscreenAd(
            placement: .interCloseIap,
            placementName: AdsPlacement.interCloseIap.rawValue,
            completion: completion,
            markColdStartCompletedAfterDismissal: false
        )
    }

    func showInterstitialCloseResult(completion: @escaping () -> Void) {
        trackAdEvent(.showRequested, placement: .interCloseResult, params: adStateParams(for: .interCloseResult))
        AppLogger.logAction("MAX request inter close result", details: adsRequestDetails(for: .interCloseResult))
        presentFullscreenAd(
            placement: .interCloseResult,
            placementName: AdsPlacement.interCloseResult.rawValue,
            completion: completion,
            markColdStartCompletedAfterDismissal: false
        )
    }

    func bannerView(for placement: AdsPlacement) -> MAAdView? {
        guard placement.adKind == .banner else { return nil }
        trackAdEvent(.showRequested, placement: placement, params: adStateParams(for: placement))
        guard shouldShowAdsForCurrentUser else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "user_or_gate_not_eligible"]))
            return nil
        }
        guard isPlacementAllowedByGate(placement) else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "placement_not_allowed_by_gate"]))
            return nil
        }
        guard isPlacementEnabled(placement) else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "placement_disabled"]))
            return nil
        }
        guard hasValidAdUnitIdentifier(for: placement) else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "missing_ad_unit"]))
            return nil
        }

        let adView = bannerAd(for: placement)
        adView?.placement = placement.rawValue
        adView?.loadAd()
        adView?.startAutoRefresh()
        return adView
    }

    func handlePaywallExposureUpdated() {
        AppLogger.logAction(
            "MAX paywall exposure updated",
            details: "dismissCount=\(paywallDismissCount), threshold=\(paywallDismissThreshold), unlocked=\(didUnlockAdsAfterPaywallGate)"
        )
        guard isAdsGloballyEnabled else { return }
        guard hasMetPaywallDismissGate else { return }
        guard !didUnlockAdsAfterPaywallGate else { return }

        didUnlockAdsAfterPaywallGate = true
        AppLogger.logAction("MAX paywall gate unlocked", details: "loading all ads")
        loadAllAds()
    }

    private func handleDidBecomeActive() {
        guard didCompleteColdStart else {
            hasHandledFirstForegroundActivation = true
            return
        }

        if !hasHandledFirstForegroundActivation {
            hasHandledFirstForegroundActivation = true
            return
        }

        showAppOpenResumeIfReady()
    }

    private func prepareAds() {
        AppLogger.logAction(
            "MAX prepareAds",
            details: "globalEnabled=\(isAdsGloballyEnabled), paywallGate=\(hasMetPaywallDismissGate), dismissCount=\(paywallDismissCount), threshold=\(paywallDismissThreshold)"
        )
        guard isAdsGloballyEnabled else {
            AppLogger.logAction("MAX disabled by remote config")
            return
        }

        guard hasMetPaywallDismissGate else {
            AppLogger.logAction(
                "MAX waiting for paywall gate",
                details: "dismissCount=\(paywallDismissCount), threshold=\(paywallDismissThreshold)"
            )
            return
        }

        didUnlockAdsAfterPaywallGate = true
        loadAllAds()
    }

    private var isAdsGloballyEnabled: Bool {
        RemoteConfigManager.shared.adsInfo.enabled
    }

    private var shouldShowAdsForCurrentUser: Bool {
        UserManager.shared.isFreeUser && isAdsGloballyEnabled && hasMetPaywallDismissGate
    }

    private var shouldShowRewardedAdsForCurrentUser: Bool {
        UserManager.shared.isFreeUser && isAdsGloballyEnabled && hasMetPaywallDismissGate && UserManager.shared.isUsageLocked
    }

    private var adsIntervalSeconds: TimeInterval {
        TimeInterval(RemoteConfigManager.shared.adsGate.intervalSeconds)
    }

    private var paywallDismissThreshold: Int {
        RemoteConfigManager.shared.adsGate.paywallDismissCountBeforeAds
    }

    private var paywallDismissCount: Int {
        PaywallExposureTracker.dismissCount
    }

    private var hasMetPaywallDismissGate: Bool {
        guard paywallDismissThreshold > 0 else { return true }
        return paywallDismissCount >= paywallDismissThreshold
    }

    private func canPresentFullscreenAdNow(for placement: AdsPlacement) -> Bool {
        guard shouldShowAdsForCurrentUser else { return false }
        guard placement.isFullscreen else { return false }

        guard let lastFullscreenAdPresentedAt else {
            return true
        }

        guard adsIntervalSeconds > 0 else {
            return true
        }

        return Date().timeIntervalSince(lastFullscreenAdPresentedAt) >= adsIntervalSeconds
    }

    private func loadAllAds() {
        AppLogger.logAction("MAX loadAllAds", details: "starting preload")
        for placement in AdsPlacement.allCases {
            loadIfNeeded(placement: placement)
        }
    }

    private func loadIfNeeded(placement: AdsPlacement) {
        trackAdEvent(.loadRequested, placement: placement, params: adStateParams(for: placement))
        AppLogger.logAction("MAX loadIfNeeded", details: "\(placement.rawValue) \(adsRequestDetails(for: placement))")
        guard shouldShowAdsForCurrentUser else {
            trackAdEvent(.loadSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "user_or_gate_not_eligible"]))
            AppLogger.logAction("MAX load skipped", details: "\(placement.rawValue) user/gate not eligible")
            return
        }

        guard isPlacementAllowedByGate(placement) else {
            trackAdEvent(.loadSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "placement_not_allowed_by_gate"]))
            AppLogger.logAction("MAX load skipped", details: "\(placement.rawValue) not allowed by gate")
            return
        }

        guard isPlacementEnabled(placement) else {
            trackAdEvent(.loadSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "placement_disabled"]))
            AppLogger.logAction("MAX load skipped", details: "\(placement.rawValue) disabled by remote config")
            return
        }

        guard hasValidAdUnitIdentifier(for: placement) else {
            trackAdEvent(.loadSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "missing_ad_unit"]))
            AppLogger.logAction("MAX load skipped", details: "\(placement.rawValue) missing ad unit id")
            return
        }

        switch placement.adKind {
        case .appOpen:
            guard let ad = appOpenAd(for: placement) else { return }
            AppLogger.logAction("MAX load", details: "\(placement.rawValue) appOpenAd.load()")
            ad.load()
        case .rewarded:
            guard let ad = rewardedAd(for: placement) else { return }
            AppLogger.logAction("MAX load", details: "\(placement.rawValue) rewardedAd.load()")
            ad.load()
        case .interstitial:
            guard let ad = interstitialAd(for: placement) else { return }
            AppLogger.logAction("MAX load", details: "\(placement.rawValue) interstitialAd.load()")
            ad.load()
        case .banner:
            guard let ad = bannerAd(for: placement) else { return }
            AppLogger.logAction("MAX load", details: "\(placement.rawValue) bannerAd.loadAd()")
            ad.loadAd()
            ad.startAutoRefresh()
        }
    }

    private func presentFullscreenAd(
        placement: AdsPlacement,
        placementName: String,
        completion: @escaping () -> Void,
        markColdStartCompletedAfterDismissal: Bool
    ) {
        AppLogger.logAction(
            "MAX present fullscreen",
            details: "\(placement.rawValue) placement=\(placementName), \(adsRequestDetails(for: placement))"
        )
        guard shouldShowAdsForCurrentUser else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "user_or_gate_not_eligible"]))
            AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) user/gate not eligible")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard isPlacementAllowedByGate(placement), isPlacementEnabled(placement) else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "placement_disabled_or_gated"]))
            AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) disabled or gated")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard canPresentFullscreenAdNow(for: placement) else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "cooldown_active"]))
            AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) cooldown active")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard !isPresentingFullscreenAd else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "another_fullscreen_showing"]))
            AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) another fullscreen ad is already showing")
            completion()
            return
        }

        switch placement.adKind {
        case .appOpen:
            guard let ad = appOpenAd(for: placement), ad.isReady else {
                trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "ad_not_ready"]))
                AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) ad not ready")
                if markColdStartCompletedAfterDismissal {
                    didCompleteColdStart = true
                }
                loadIfNeeded(placement: placement)
                completion()
                return
            }

            AppLogger.logAction("MAX present", details: "\(placement.rawValue) showing ad")
            pendingActions[placement] = PendingAction(completion: {
                if markColdStartCompletedAfterDismissal {
                    self.didCompleteColdStart = true
                }
                completion()
            })
            activeFullscreenPlacement = placement
            isPresentingFullscreenAd = true
            ad.show(forPlacement: placementName)
        case .rewarded:
            guard let ad = rewardedAd(for: placement), ad.isReady else {
                trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "ad_not_ready"]))
                AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) ad not ready")
                loadIfNeeded(placement: placement)
                completion()
                return
            }

            AppLogger.logAction("MAX present", details: "\(placement.rawValue) showing ad")
            pendingActions[placement] = PendingAction(completion: completion)
            activeFullscreenPlacement = placement
            isPresentingFullscreenAd = true
            ad.show(forPlacement: placementName)
        case .interstitial:
            guard let ad = interstitialAd(for: placement), ad.isReady else {
                trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "ad_not_ready"]))
                AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) ad not ready")
                loadIfNeeded(placement: placement)
                completion()
                return
            }

            AppLogger.logAction("MAX present", details: "\(placement.rawValue) showing ad")
            pendingActions[placement] = PendingAction(completion: completion)
            activeFullscreenPlacement = placement
            isPresentingFullscreenAd = true
            ad.show(forPlacement: placementName)
        case .banner:
            completion()
        }
    }

    private func isPlacementEnabled(_ placement: AdsPlacement) -> Bool {
        RemoteConfigManager.shared.adsInfo.isEnabled(for: placement)
    }

    private func isPlacementAllowedByGate(_ placement: AdsPlacement) -> Bool {
        RemoteConfigManager.shared.adsGate.allows(placement)
    }

    private func hasValidAdUnitIdentifier(for placement: AdsPlacement) -> Bool {
        guard let adUnitIdentifier = adUnitIdentifier(for: placement) else { return false }
        return !adUnitIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func shouldShowRewardedAds(for placement: AdsPlacement) -> Bool {
        guard placement.adKind == .rewarded else { return false }
        return shouldShowRewardedAdsForCurrentUser
    }

    private func isRewardedAdReady(for placement: AdsPlacement) -> Bool {
        rewardedAd(for: placement)?.isReady ?? false
    }

    private func presentRewardedAdWhenReady(placement: AdsPlacement, completion: @escaping () -> Void) {
        Task { @MainActor in
            let deadline = Date().addingTimeInterval(8)

            while Date() < deadline {
                guard isRewardedAdReady(for: placement) else {
                    loadIfNeeded(placement: placement)
                    try? await Task.sleep(nanoseconds: 250_000_000)
                    continue
                }

                presentFullscreenAd(
                    placement: placement,
                    placementName: placement.rawValue,
                    completion: completion,
                    markColdStartCompletedAfterDismissal: false
                )
                return
            }

            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "rewarded_not_ready_before_deadline"]))
            AppLogger.logAction("MAX rewarded skipped", details: "\(placement.rawValue) not ready before deadline")
        }
    }

    private func adUnitIdentifier(for placement: AdsPlacement) -> String? {
        let adUnitIdentifier = RemoteConfigManager.shared.adsInfo.adsId(for: placement).trimmingCharacters(in: .whitespacesAndNewlines)
        return adUnitIdentifier.isEmpty ? nil : adUnitIdentifier
    }

    private func appOpenAd(for placement: AdsPlacement) -> MAAppOpenAd? {
        guard placement.adKind == .appOpen else { return nil }
        guard let adUnitIdentifier = adUnitIdentifier(for: placement) else { return nil }

        if let existing = appOpenAds[placement], existing.adUnitIdentifier == adUnitIdentifier {
            return existing
        }

        let ad = MAAppOpenAd(adUnitIdentifier: adUnitIdentifier)
        ad.delegate = self
        ad.revenueDelegate = self
        appOpenAds[placement] = ad
        return ad
    }

    private func rewardedAd(for placement: AdsPlacement) -> MARewardedAd? {
        guard placement.adKind == .rewarded else { return nil }
        guard let adUnitIdentifier = adUnitIdentifier(for: placement) else { return nil }

        if let existing = rewardedAds[placement], existing.adUnitIdentifier == adUnitIdentifier {
            return existing
        }

        let ad = MARewardedAd.shared(withAdUnitIdentifier: adUnitIdentifier)
        ad.delegate = self
        ad.revenueDelegate = self
        rewardedAds[placement] = ad
        return ad
    }

    private func interstitialAd(for placement: AdsPlacement) -> MAInterstitialAd? {
        guard placement.adKind == .interstitial else { return nil }
        guard let adUnitIdentifier = adUnitIdentifier(for: placement) else { return nil }

        if let existing = interstitialAds[placement], existing.adUnitIdentifier == adUnitIdentifier {
            return existing
        }

        let ad = MAInterstitialAd(adUnitIdentifier: adUnitIdentifier)
        ad.delegate = self
        ad.revenueDelegate = self
        interstitialAds[placement] = ad
        return ad
    }

    private func bannerAd(for placement: AdsPlacement) -> MAAdView? {
        guard placement.adKind == .banner else { return nil }
        guard let adUnitIdentifier = adUnitIdentifier(for: placement) else { return nil }

        if let existing = bannerAds[placement], existing.adUnitIdentifier == adUnitIdentifier {
            return existing
        }

        let ad = MAAdView(adUnitIdentifier: adUnitIdentifier)
        ad.delegate = self
        ad.revenueDelegate = self
        ad.placement = placement.rawValue
        bannerAds[placement] = ad
        return ad
    }

    private func placement(for adUnitIdentifier: String) -> AdsPlacement? {
        let normalized = adUnitIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        return AdsPlacement.allCases.first { RemoteConfigManager.shared.adsInfo.adsId(for: $0) == normalized }
    }

    private func finishFullscreenAd(for placement: AdsPlacement) {
        guard placement.isFullscreen else { return }
        guard activeFullscreenPlacement == placement else { return }

        activeFullscreenPlacement = nil
        isPresentingFullscreenAd = false
        AppLogger.logAction("MAX finish fullscreen", details: "\(placement.rawValue) adUnit=\(RemoteConfigManager.shared.adsInfo.adsId(for: placement))")

        if let pending = pendingActions.removeValue(forKey: placement) {
            AppLogger.logAction("MAX pending completion", details: "\(placement.rawValue)")
            pending.completion?()
        }

        loadIfNeeded(placement: placement)
    }

    private func handleRetry(for placement: AdsPlacement) {
        let nextRetry = (retryAttempts[placement] ?? 0) + 1
        retryAttempts[placement] = nextRetry

        let delaySeconds = pow(2.0, min(6.0, Double(nextRetry)))
        AppLogger.logAction(
            "MAX retry scheduled",
            details: "\(placement.rawValue) attempt=\(nextRetry) delay=\(delaySeconds)s"
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
            self?.loadIfNeeded(placement: placement)
        }
    }

    private func trackAdEvent(
        _ event: TrackingManager.AdEvent,
        placement: AdsPlacement,
        ad: MAAd? = nil,
        adUnitIdentifier: String? = nil,
        error: MAError? = nil,
        params: [String: Any?] = [:]
    ) {
        var eventParams = params
        eventParams["ad_unit_name"] = ad?.adUnitIdentifier ?? adUnitIdentifier ?? self.adUnitIdentifier(for: placement)

        if let ad {
            eventParams["ad_format"] = ad.format.label.lowercased()
            eventParams["ad_source"] = truncated(ad.networkName)
            eventParams["network_placement"] = truncated(ad.networkPlacement)
            eventParams["creative_id"] = truncated(ad.creativeIdentifier)
            eventParams["dsp_name"] = truncated(ad.dspName)
            eventParams["dsp_id"] = truncated(ad.dspIdentifier)
            eventParams["request_latency_ms"] = milliseconds(ad.requestLatency)
            eventParams["waterfall_name"] = truncated(ad.waterfall.name)
            eventParams["waterfall_test"] = truncated(ad.waterfall.testName)
            eventParams["waterfall_latency_ms"] = milliseconds(ad.waterfall.latency)
        }

        if let error {
            eventParams["error_code"] = Int(error.code.rawValue)
            eventParams["error_message"] = truncated(error.message)
            eventParams["mediated_error_code"] = error.mediatedNetworkErrorCode
            eventParams["mediated_error_message"] = truncated(error.mediatedNetworkErrorMessage)
            eventParams["request_latency_ms"] = milliseconds(error.requestLatency)
            eventParams["waterfall_name"] = truncated(error.waterfall?.name)
            eventParams["waterfall_test"] = truncated(error.waterfall?.testName)
            eventParams["waterfall_latency_ms"] = milliseconds(error.waterfall?.latency)
        }

        TrackingManager.shared.trackAdEvent(event, placement: placement, params: eventParams)
    }

    private func adStateParams(for placement: AdsPlacement, extra: [String: Any?] = [:]) -> [String: Any?] {
        var params: [String: Any?] = [
            "ad_unit_name": adUnitIdentifier(for: placement),
            "is_free_user": UserManager.shared.isFreeUser,
            "is_usage_locked": UserManager.shared.isUsageLocked,
            "ads_global_enabled": isAdsGloballyEnabled,
            "placement_enabled": isPlacementEnabled(placement),
            "gate_allowed": isPlacementAllowedByGate(placement),
            "ad_unit_configured": hasValidAdUnitIdentifier(for: placement),
            "paywall_dismiss_count": paywallDismissCount,
            "paywall_threshold": paywallDismissThreshold,
            "met_paywall_gate": hasMetPaywallDismissGate,
            "cooldown_ready": canPresentFullscreenAdNow(for: placement),
            "presenting_fullscreen": isPresentingFullscreenAd,
            "cold_start_done": didCompleteColdStart,
            "resume_shown": hasShownResumeThisForeground,
            "ad_ready": isAdReady(for: placement)
        ]
        extra.forEach { params[$0.key] = $0.value }
        return params
    }

    private func isAdReady(for placement: AdsPlacement) -> Bool {
        switch placement.adKind {
        case .appOpen:
            return appOpenAds[placement]?.isReady ?? false
        case .rewarded:
            return rewardedAds[placement]?.isReady ?? false
        case .interstitial:
            return interstitialAds[placement]?.isReady ?? false
        case .banner:
            return bannerAds[placement] != nil
        }
    }

    private func milliseconds(_ interval: TimeInterval?) -> Int? {
        guard let interval, interval > 0 else { return nil }
        return Int((interval * 1_000).rounded())
    }

    private func truncated(_ value: String?, limit: Int = 100) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return String(value.prefix(limit))
    }

    private func adsRequestDetails(for placement: AdsPlacement) -> String {
        [
            "global=\(isAdsGloballyEnabled)",
            "placementEnabled=\(isPlacementEnabled(placement))",
            "gateAllowed=\(isPlacementAllowedByGate(placement))",
            "adUnitConfigured=\(hasValidAdUnitIdentifier(for: placement))",
            "paywallDismissCount=\(paywallDismissCount)",
            "paywallThreshold=\(paywallDismissThreshold)",
            "metPaywallGate=\(hasMetPaywallDismissGate)",
            "interval=\(adsIntervalSeconds)s",
            "cooldownReady=\(canPresentFullscreenAdNow(for: placement))",
            "presenting=\(isPresentingFullscreenAd)",
            "resumeShown=\(hasShownResumeThisForeground)",
            "coldStartDone=\(didCompleteColdStart)"
        ].joined(separator: ", ")
    }

    private var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }

    private func presentAppOpenSplashIfReady(before deadline: Date, completion: @escaping () -> Void) async {
        let placement: AdsPlacement = .openSplash

        guard shouldShowAdsForCurrentUser else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "user_or_gate_not_eligible"]))
            AppLogger.logAction("MAX splash skipped", details: "user/gate not eligible")
            completion()
            return
        }

        guard isPlacementAllowedByGate(placement), isPlacementEnabled(placement) else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "placement_disabled_or_gated"]))
            AppLogger.logAction("MAX splash skipped", details: "disabled or gated")
            completion()
            return
        }

        guard hasValidAdUnitIdentifier(for: placement) else {
            trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "missing_ad_unit"]))
            AppLogger.logAction("MAX splash skipped", details: "missing ad unit id")
            completion()
            return
        }

        loadIfNeeded(placement: placement)

        while Date() < deadline {
            if let ad = appOpenAd(for: placement), ad.isReady {
                presentFullscreenAd(
                    placement: placement,
                    placementName: placement.rawValue,
                    completion: completion,
                    markColdStartCompletedAfterDismissal: true
                )
                return
            }

            try? await Task.sleep(nanoseconds: 250_000_000)
        }

        trackAdEvent(.showSkipped, placement: placement, params: adStateParams(for: placement, extra: ["skip_reason": "app_open_not_ready_before_deadline"]))
        AppLogger.logAction("MAX splash skipped", details: "open_splash not ready before deadline")
        completion()
    }
}

extension AdsManager: MAAdDelegate {
    func didLoad(_ ad: MAAd) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        retryAttempts[placement] = 0
        trackAdEvent(.loaded, placement: placement, ad: ad)
        AppLogger.logAction("MAX loaded", details: "\(placement.rawValue) adUnit=\(ad.adUnitIdentifier)")
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        AppLogger.logAction("MAX load failed", details: "\(adUnitIdentifier): \(error.code) \(error.message)")
        guard let placement = placement(for: adUnitIdentifier) else { return }
        trackAdEvent(
            .loadFailed,
            placement: placement,
            adUnitIdentifier: adUnitIdentifier,
            error: error,
            params: ["next_retry_attempt": (retryAttempts[placement] ?? 0) + 1]
        )
        handleRetry(for: placement)
    }

    func didDisplay(_ ad: MAAd) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        trackAdEvent(.displayed, placement: placement, ad: ad)
        AppLogger.logAction("MAX displayed", details: "\(ad.adUnitIdentifier) / \(ad.format)")
        if placement.isFullscreen {
            lastFullscreenAdPresentedAt = Date()
        }
    }

    func didClick(_ ad: MAAd) {
        if let placement = placement(for: ad.adUnitIdentifier) {
            trackAdEvent(.clicked, placement: placement, ad: ad)
        }
        AppLogger.logAction("MAX clicked", details: "\(ad.adUnitIdentifier)")
    }

    func didHide(_ ad: MAAd) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        trackAdEvent(.hidden, placement: placement, ad: ad)
        AppLogger.logAction("MAX hidden", details: "\(ad.adUnitIdentifier)")
        finishFullscreenAd(for: placement)
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        trackAdEvent(.displayFailed, placement: placement, ad: ad, error: error)
        AppLogger.logAction("MAX display failed", details: "\(ad.adUnitIdentifier): \(error.code) \(error.message)")
        finishFullscreenAd(for: placement)
    }
}

extension AdsManager: MARewardedAdDelegate {
    func didStartRewardedVideo(for ad: MAAd) {
        if let placement = placement(for: ad.adUnitIdentifier) {
            trackAdEvent(.rewardStarted, placement: placement, ad: ad)
        }
        AppLogger.logAction("MAX rewarded video started", details: ad.adUnitIdentifier)
    }

    func didCompleteRewardedVideo(for ad: MAAd) {
        if let placement = placement(for: ad.adUnitIdentifier) {
            trackAdEvent(.rewardCompleted, placement: placement, ad: ad)
        }
        AppLogger.logAction("MAX rewarded video completed", details: ad.adUnitIdentifier)
    }

    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        AppLogger.logAction("MAX rewarded", details: "\(ad.adUnitIdentifier) \(reward.amount) \(reward.label)")
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }

        let limitBefore = UserManager.shared.freeUsageLimit
        let remainingBefore = UserManager.shared.freeUsageRemaining
        let bonusBefore = UserManager.shared.bonusFreeUsageCount
        guard UserManager.shared.grantFreeUsage() else {
            trackAdEvent(
                .rewardSkipped,
                placement: placement,
                ad: ad,
                params: [
                    "skip_reason": "no_quota_change",
                    "reward_amount": reward.amount,
                    "reward_label": reward.label
                ]
            )
            AppLogger.logAction("MAX reward grant skipped", details: "\(placement.rawValue) no quota change")
            return
        }

        trackAdEvent(
            .rewardGranted,
            placement: placement,
            ad: ad,
            params: [
                "reward_amount": reward.amount,
                "reward_label": reward.label,
                "limit_before": limitBefore,
                "limit_after": UserManager.shared.freeUsageLimit,
                "remaining_before": remainingBefore,
                "remaining_after": UserManager.shared.freeUsageRemaining,
                "bonus_before": bonusBefore,
                "bonus_after": UserManager.shared.bonusFreeUsageCount
            ]
        )
        TrackingManager.shared.trackRewardEarned(
            placement: placement,
            adUnitIdentifier: ad.adUnitIdentifier,
            limitBefore: limitBefore,
            limitAfter: UserManager.shared.freeUsageLimit,
            remainingBefore: remainingBefore,
            remainingAfter: UserManager.shared.freeUsageRemaining,
            bonusBefore: bonusBefore,
            bonusAfter: UserManager.shared.bonusFreeUsageCount
        )
    }
}

extension AdsManager: MAAdRevenueDelegate {
    func didPayRevenue(for ad: MAAd) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        trackAdEvent(
            .revenuePaid,
            placement: placement,
            ad: ad,
            params: [
                "revenue_usd": ad.revenue,
                "revenue_precision": ad.revenuePrecision,
                "value": ad.revenue,
                "currency": "USD"
            ]
        )
    }
}

extension AdsManager: MAAdViewAdDelegate {
    func didExpand(_ ad: MAAd) {
        if let placement = placement(for: ad.adUnitIdentifier) {
            trackAdEvent(.bannerExpanded, placement: placement, ad: ad)
        }
        AppLogger.logAction("MAX banner expanded", details: ad.adUnitIdentifier)
    }

    func didCollapse(_ ad: MAAd) {
        if let placement = placement(for: ad.adUnitIdentifier) {
            trackAdEvent(.bannerCollapsed, placement: placement, ad: ad)
        }
        AppLogger.logAction("MAX banner collapsed", details: ad.adUnitIdentifier)
    }
}
