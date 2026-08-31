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
        AppLogger.logAction("MAX request app open splash", details: adsRequestDetails(for: .openSplash))

        guard hasSeenOnboarding else {
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
        AppLogger.logAction("MAX request app open resume", details: adsRequestDetails(for: .openResume))
        guard didCompleteColdStart else { return }
        guard !hasShownResumeThisForeground else { return }

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
        AppLogger.logAction("MAX request rewarded generate", details: adsRequestDetails(for: .rewardedGenerate))
        guard shouldShowRewardedAds(for: .rewardedGenerate) else {
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
        AppLogger.logAction("MAX request rewarded regenerate", details: adsRequestDetails(for: .rewardedRegenerate))
        guard shouldShowRewardedAds(for: .rewardedRegenerate) else {
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
        AppLogger.logAction("MAX request inter close edit", details: adsRequestDetails(for: .interCloseEdit))
        presentFullscreenAd(
            placement: .interCloseEdit,
            placementName: AdsPlacement.interCloseEdit.rawValue,
            completion: completion,
            markColdStartCompletedAfterDismissal: false
        )
    }

    func showInterstitialCloseIap(completion: @escaping () -> Void) {
        AppLogger.logAction("MAX request inter close iap", details: adsRequestDetails(for: .interCloseIap))
        presentFullscreenAd(
            placement: .interCloseIap,
            placementName: AdsPlacement.interCloseIap.rawValue,
            completion: completion,
            markColdStartCompletedAfterDismissal: false
        )
    }

    func showInterstitialCloseResult(completion: @escaping () -> Void) {
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
        guard shouldShowAdsForCurrentUser else { return nil }
        guard isPlacementAllowedByGate(placement) else { return nil }
        guard isPlacementEnabled(placement) else { return nil }
        guard hasValidAdUnitIdentifier(for: placement) else { return nil }

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
        AppLogger.logAction("MAX loadIfNeeded", details: "\(placement.rawValue) \(adsRequestDetails(for: placement))")
        guard shouldShowAdsForCurrentUser else {
            AppLogger.logAction("MAX load skipped", details: "\(placement.rawValue) user/gate not eligible")
            return
        }

        guard isPlacementAllowedByGate(placement) else {
            AppLogger.logAction("MAX load skipped", details: "\(placement.rawValue) not allowed by gate")
            return
        }

        guard isPlacementEnabled(placement) else {
            AppLogger.logAction("MAX load skipped", details: "\(placement.rawValue) disabled by remote config")
            return
        }

        guard hasValidAdUnitIdentifier(for: placement) else {
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
            AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) user/gate not eligible")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard isPlacementAllowedByGate(placement), isPlacementEnabled(placement) else {
            AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) disabled or gated")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard canPresentFullscreenAdNow(for: placement) else {
            AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) cooldown active")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard !isPresentingFullscreenAd else {
            AppLogger.logAction("MAX present skipped", details: "\(placement.rawValue) another fullscreen ad is already showing")
            completion()
            return
        }

        switch placement.adKind {
        case .appOpen:
            guard let ad = appOpenAd(for: placement), ad.isReady else {
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
            AppLogger.logAction("MAX splash skipped", details: "user/gate not eligible")
            completion()
            return
        }

        guard isPlacementAllowedByGate(placement), isPlacementEnabled(placement) else {
            AppLogger.logAction("MAX splash skipped", details: "disabled or gated")
            completion()
            return
        }

        guard hasValidAdUnitIdentifier(for: placement) else {
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

        AppLogger.logAction("MAX splash skipped", details: "open_splash not ready before deadline")
        completion()
    }
}

extension AdsManager: MAAdDelegate {
    func didLoad(_ ad: MAAd) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        retryAttempts[placement] = 0
        AppLogger.logAction("MAX loaded", details: "\(placement.rawValue) adUnit=\(ad.adUnitIdentifier)")
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        AppLogger.logAction("MAX load failed", details: "\(adUnitIdentifier): \(error.code) \(error.message)")
        guard let placement = placement(for: adUnitIdentifier) else { return }
        handleRetry(for: placement)
    }

    func didDisplay(_ ad: MAAd) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        AppLogger.logAction("MAX displayed", details: "\(ad.adUnitIdentifier) / \(ad.format)")
        if placement.isFullscreen {
            lastFullscreenAdPresentedAt = Date()
        }
    }

    func didClick(_ ad: MAAd) {
        AppLogger.logAction("MAX clicked", details: "\(ad.adUnitIdentifier)")
    }

    func didHide(_ ad: MAAd) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        AppLogger.logAction("MAX hidden", details: "\(ad.adUnitIdentifier)")
        finishFullscreenAd(for: placement)
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }
        AppLogger.logAction("MAX display failed", details: "\(ad.adUnitIdentifier): \(error.code) \(error.message)")
        finishFullscreenAd(for: placement)
    }
}

extension AdsManager: MARewardedAdDelegate {
    func didStartRewardedVideo(for ad: MAAd) {
        AppLogger.logAction("MAX rewarded video started", details: ad.adUnitIdentifier)
    }

    func didCompleteRewardedVideo(for ad: MAAd) {
        AppLogger.logAction("MAX rewarded video completed", details: ad.adUnitIdentifier)
    }

    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        AppLogger.logAction("MAX rewarded", details: "\(ad.adUnitIdentifier) \(reward.amount) \(reward.label)")
        guard let placement = placement(for: ad.adUnitIdentifier) else { return }

        let limitBefore = UserManager.shared.freeUsageLimit
        let remainingBefore = UserManager.shared.freeUsageRemaining
        let bonusBefore = UserManager.shared.bonusFreeUsageCount
        guard UserManager.shared.grantFreeUsage() else {
            AppLogger.logAction("MAX reward grant skipped", details: "\(placement.rawValue) no quota change")
            return
        }

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

extension AdsManager: MAAdViewAdDelegate {
    func didExpand(_ ad: MAAd) {
        AppLogger.logAction("MAX banner expanded", details: ad.adUnitIdentifier)
    }

    func didCollapse(_ ad: MAAd) {
        AppLogger.logAction("MAX banner collapsed", details: ad.adUnitIdentifier)
    }
}
