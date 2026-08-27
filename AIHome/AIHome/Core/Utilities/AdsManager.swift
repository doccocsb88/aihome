import AppLovinSDK
import Foundation
import SwiftUI
import UIKit

@MainActor
final class AdsManager: NSObject {
    static let shared = AdsManager()

    private enum Slot: String, CaseIterable {
        case openSplash
        case openResume
        case rewardedGenerate
        case rewardedRegenerate
        case interCloseEdit
        case interCloseIap
        case interCloseResult

        var placement: String {
            rawValue
        }

        var adUnitIdentifier: String {
            switch self {
            case .openSplash:
                return RemoteConfigManager.shared.adsInfo.openAds.adsId
            case .openResume:
                return RemoteConfigManager.shared.adsInfo.openAds.adsId
            case .rewardedGenerate:
                return RemoteConfigManager.shared.adsInfo.rewardedAds.generateAdsId
            case .rewardedRegenerate:
                return RemoteConfigManager.shared.adsInfo.rewardedAds.regenerateAdsId
            case .interCloseEdit:
                return RemoteConfigManager.shared.adsInfo.interAds.adsId
            case .interCloseIap:
                return RemoteConfigManager.shared.adsInfo.interAds.adsId
            case .interCloseResult:
                return RemoteConfigManager.shared.adsInfo.interAds.adsId
            }
        }
    }

    private struct PendingAction {
        var completion: (() -> Void)?
    }

    private enum Configuration {
        static let sdkKey = "J2ks4TF6rLetzM0TgPvggyqLiCRTUJ1afPHWi0la24rZnZOul9gyfkD4JtAmbcua43fHqHHBzV20zrbR6Ilz5G"
    }

    private var appOpenAd: MAAppOpenAd?
    private var rewardedGenerateAd: MARewardedAd?
    private var rewardedRegenerateAd: MARewardedAd?
    private var interstitialAd: MAInterstitialAd?
    private var pendingActions: [Slot: PendingAction] = [:]
    private var retryAttempts: [Slot: Int] = [:]
    private var activeFullscreenSlot: Slot?
    private var hasInitializedSDK = false
    private var hasHandledFirstForegroundActivation = false
    private var hasShownResumeThisForeground = false
    private var isPresentingFullscreenAd = false
    private var didCompleteColdStart = false
    private var lastFullscreenAdPresentedAt: Date?
    private var didUnlockAdsAfterPaywallGate = false

    private override init() {
        super.init()
    }

    func configureIfNeeded() {
        guard !hasInitializedSDK else { return }
        hasInitializedSDK = true

        AppLogger.logAction(
            "MAX configureIfNeeded",
            details: "sdkKey=\(Configuration.sdkKey.prefix(6))..., paywallDismissCount=\(PaywallExposureTracker.dismissCount), threshold=\(paywallDismissThreshold), interval=\(adsIntervalSeconds)s"
        )

        let sdk = ALSdk.shared()
        let initConfig = ALSdkInitializationConfiguration(sdkKey: Configuration.sdkKey) { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }

        AppLogger.logAction("MAX SDK initializing", details: "sdkKey=\(Configuration.sdkKey.prefix(6))...")
        sdk.initialize(with: initConfig) { [weak self] (_: ALSdkConfiguration) in
            DispatchQueue.main.async {
                self?.prepareAds()
            }
        }
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

    func showAppOpenSplashIfReady(completion: @escaping () -> Void) {
        AppLogger.logAction("MAX request app open splash", details: adsRequestDetails(for: .openSplash))
        presentAppOpenAd(
            slot: .openSplash,
            placement: Slot.openSplash.rawValue,
            completion: completion,
            markColdStartCompletedAfterDismissal: true
        )
    }

    func showAppOpenResumeIfReady() {
        AppLogger.logAction("MAX request app open resume", details: adsRequestDetails(for: .openResume))
        guard didCompleteColdStart else { return }
        guard !hasShownResumeThisForeground else { return }

        hasShownResumeThisForeground = true
        presentAppOpenAd(
            slot: .openResume,
            placement: Slot.openResume.rawValue,
            completion: {},
            markColdStartCompletedAfterDismissal: false
        )
    }

    func showRewardedGenerateIfNeeded(completion: @escaping () -> Void) {
        AppLogger.logAction("MAX request rewarded generate", details: adsRequestDetails(for: .rewardedGenerate))
        presentRewardedAd(slot: .rewardedGenerate, placement: Slot.rewardedGenerate.rawValue, completion: completion)
    }

    func showRewardedRegenerateIfNeeded(completion: @escaping () -> Void) {
        AppLogger.logAction("MAX request rewarded regenerate", details: adsRequestDetails(for: .rewardedRegenerate))
        presentRewardedAd(slot: .rewardedRegenerate, placement: Slot.rewardedRegenerate.rawValue, completion: completion)
    }

    func showInterstitialCloseEdit(completion: @escaping () -> Void) {
        AppLogger.logAction("MAX request inter close edit", details: adsRequestDetails(for: .interCloseEdit))
        presentInterstitialAd(slot: .interCloseEdit, placement: Slot.interCloseEdit.rawValue, completion: completion)
    }

    func showInterstitialCloseIap(completion: @escaping () -> Void) {
        AppLogger.logAction("MAX request inter close iap", details: adsRequestDetails(for: .interCloseIap))
        presentInterstitialAd(slot: .interCloseIap, placement: Slot.interCloseIap.rawValue, completion: completion)
    }

    func showInterstitialCloseResult(completion: @escaping () -> Void) {
        AppLogger.logAction("MAX request inter close result", details: adsRequestDetails(for: .interCloseResult))
        presentInterstitialAd(slot: .interCloseResult, placement: Slot.interCloseResult.rawValue, completion: completion)
    }

    func handlePaywallExposureUpdated() {
        AppLogger.logAction(
            "MAX paywall exposure updated",
            details: "dismissCount=\(PaywallExposureTracker.dismissCount), threshold=\(paywallDismissThreshold), unlocked=\(didUnlockAdsAfterPaywallGate)"
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
            details: "globalEnabled=\(isAdsGloballyEnabled), paywallGate=\(hasMetPaywallDismissGate), dismissCount=\(PaywallExposureTracker.dismissCount), threshold=\(paywallDismissThreshold)"
        )
        guard isAdsGloballyEnabled else {
            AppLogger.logAction("MAX disabled by remote config")
            return
        }

        guard hasMetPaywallDismissGate else {
            AppLogger.logAction(
                "MAX waiting for paywall gate",
                details: "dismissCount=\(PaywallExposureTracker.dismissCount), threshold=\(paywallDismissThreshold)"
            )
            return
        }

        didUnlockAdsAfterPaywallGate = true

        appOpenAd = makeAppOpenAd()
        rewardedGenerateAd = makeRewardedAd(for: .rewardedGenerate)
        rewardedRegenerateAd = makeRewardedAd(for: .rewardedRegenerate)
        interstitialAd = makeInterstitialAd()

        loadAllAds()
    }

    private var isAdsGloballyEnabled: Bool {
        RemoteConfigManager.shared.maxEnable
    }

    private var shouldShowAdsForCurrentUser: Bool {
        UserManager.shared.isFreeUser && isAdsGloballyEnabled && hasMetPaywallDismissGate
    }

    private var adsIntervalSeconds: TimeInterval {
        TimeInterval(RemoteConfigManager.shared.maxAdsIntervalSeconds)
    }

    private var paywallDismissThreshold: Int {
        RemoteConfigManager.shared.maxPaywallDismissCountBeforeAds
    }

    private var hasMetPaywallDismissGate: Bool {
        guard paywallDismissThreshold > 0 else { return true }
        return PaywallExposureTracker.dismissCount >= paywallDismissThreshold
    }

    private var canPresentFullscreenAdNow: Bool {
        guard shouldShowAdsForCurrentUser else { return false }

        guard let lastFullscreenAdPresentedAt else {
            return true
        }

        guard adsIntervalSeconds > 0 else {
            return true
        }

        return Date().timeIntervalSince(lastFullscreenAdPresentedAt) >= adsIntervalSeconds
    }

    private func makeAppOpenAd() -> MAAppOpenAd? {
        let adUnitIdentifier = Slot.openSplash.adUnitIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !adUnitIdentifier.isEmpty else { return nil }
        let ad = MAAppOpenAd(adUnitIdentifier: adUnitIdentifier)
        ad.delegate = self
        return ad
    }

    private func makeInterstitialAd() -> MAInterstitialAd? {
        let adUnitIdentifier = Slot.interCloseEdit.adUnitIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !adUnitIdentifier.isEmpty else { return nil }
        let ad = MAInterstitialAd(adUnitIdentifier: adUnitIdentifier)
        ad.delegate = self
        return ad
    }

    private func makeRewardedAd(for slot: Slot) -> MARewardedAd? {
        let adUnitIdentifier = slot.adUnitIdentifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !adUnitIdentifier.isEmpty else { return nil }
        let ad = MARewardedAd.shared(withAdUnitIdentifier: adUnitIdentifier)
        ad.delegate = self
        return ad
    }

    private func loadAllAds() {
        AppLogger.logAction("MAX loadAllAds", details: "starting preload")
        loadIfNeeded(slot: .openSplash)
        loadIfNeeded(slot: .rewardedGenerate)
        loadIfNeeded(slot: .rewardedRegenerate)
        loadIfNeeded(slot: .interCloseEdit)
    }

    private func loadIfNeeded(slot: Slot) {
        AppLogger.logAction("MAX loadIfNeeded", details: "\(slot.rawValue) \(adsRequestDetails(for: slot))")
        guard shouldShowAdsForCurrentUser else {
            AppLogger.logAction("MAX load skipped", details: "\(slot.rawValue) user/gate not eligible")
            return
        }

        guard isSlotEnabled(slot) else {
            AppLogger.logAction("MAX load skipped", details: "\(slot.rawValue) disabled by remote config")
            return
        }

        guard hasValidAdUnitIdentifier(for: slot) else {
            AppLogger.logAction("MAX load skipped", details: "\(slot.rawValue) missing ad unit id")
            return
        }

        switch slot {
        case .openSplash:
            AppLogger.logAction("MAX load", details: "\(slot.rawValue) appOpenAd.load()")
            appOpenAd?.load()
        case .openResume:
            AppLogger.logAction("MAX load", details: "\(slot.rawValue) appOpenAd.load()")
            appOpenAd?.load()
        case .rewardedGenerate:
            AppLogger.logAction("MAX load", details: "\(slot.rawValue) rewardedGenerateAd.load()")
            rewardedGenerateAd?.load()
        case .rewardedRegenerate:
            AppLogger.logAction("MAX load", details: "\(slot.rawValue) rewardedRegenerateAd.load()")
            rewardedRegenerateAd?.load()
        case .interCloseEdit:
            AppLogger.logAction("MAX load", details: "\(slot.rawValue) interstitialAd.load()")
            interstitialAd?.load()
        case .interCloseIap:
            AppLogger.logAction("MAX load", details: "\(slot.rawValue) interstitialAd.load()")
            interstitialAd?.load()
        case .interCloseResult:
            AppLogger.logAction("MAX load", details: "\(slot.rawValue) interstitialAd.load()")
            interstitialAd?.load()
        }
    }

    private func presentAppOpenAd(
        slot: Slot,
        placement: String,
        completion: @escaping () -> Void,
        markColdStartCompletedAfterDismissal: Bool
    ) {
        AppLogger.logAction(
            "MAX present app open",
            details: "\(slot.rawValue) placement=\(placement), \(adsRequestDetails(for: slot))"
        )
        guard shouldShowAdsForCurrentUser else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) user/gate not eligible")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard canPresentFullscreenAdNow else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) cooldown active")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard isSlotEnabled(slot) else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) disabled by remote config")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard !isPresentingFullscreenAd else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) another fullscreen ad is already showing")
            completion()
            return
        }

        guard let ad = appOpenAd, ad.isReady else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) ad not ready")
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            loadIfNeeded(slot: slot)
            completion()
            return
        }

        AppLogger.logAction("MAX present", details: "\(slot.rawValue) showing ad")
        pendingActions[slot] = PendingAction(completion: {
            if markColdStartCompletedAfterDismissal {
                self.didCompleteColdStart = true
            }
            completion()
        })
        activeFullscreenSlot = slot
        isPresentingFullscreenAd = true
        ad.show(forPlacement: placement)
    }

    private func presentInterstitialAd(
        slot: Slot,
        placement: String,
        completion: @escaping () -> Void
    ) {
        AppLogger.logAction(
            "MAX present interstitial",
            details: "\(slot.rawValue) placement=\(placement), \(adsRequestDetails(for: slot))"
        )
        guard canPresentFullscreenAdNow, isSlotEnabled(slot) else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) cooldown/gate/disabled")
            completion()
            return
        }

        guard !isPresentingFullscreenAd else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) another fullscreen ad is already showing")
            completion()
            return
        }

        guard let ad = interstitialAd, ad.isReady else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) ad not ready")
            loadIfNeeded(slot: slot)
            completion()
            return
        }

        AppLogger.logAction("MAX present", details: "\(slot.rawValue) showing ad")
        pendingActions[slot] = PendingAction(completion: completion)
        activeFullscreenSlot = slot
        isPresentingFullscreenAd = true
        ad.show(forPlacement: placement)
    }

    private func presentRewardedAd(
        slot: Slot,
        placement: String,
        completion: @escaping () -> Void
    ) {
        AppLogger.logAction(
            "MAX present rewarded",
            details: "\(slot.rawValue) placement=\(placement), \(adsRequestDetails(for: slot))"
        )
        guard canPresentFullscreenAdNow, isSlotEnabled(slot) else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) cooldown/gate/disabled")
            completion()
            return
        }

        guard !isPresentingFullscreenAd else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) another fullscreen ad is already showing")
            completion()
            return
        }

        guard let ad = rewardedAd(for: slot), ad.isReady else {
            AppLogger.logAction("MAX present skipped", details: "\(slot.rawValue) ad not ready")
            loadIfNeeded(slot: slot)
            completion()
            return
        }

        AppLogger.logAction("MAX present", details: "\(slot.rawValue) showing ad")
        pendingActions[slot] = PendingAction(completion: completion)
        activeFullscreenSlot = slot
        isPresentingFullscreenAd = true
        ad.show(forPlacement: placement)
    }

    private func isSlotEnabled(_ slot: Slot) -> Bool {
        let adsInfo = RemoteConfigManager.shared.adsInfo
        switch slot {
        case .openSplash:
            return adsInfo.enabled && adsInfo.openAds.enabled
        case .openResume:
            return adsInfo.enabled && adsInfo.openAds.enabled
        case .rewardedGenerate:
            return adsInfo.enabled && adsInfo.rewardedAds.enabled
        case .rewardedRegenerate:
            return adsInfo.enabled && adsInfo.rewardedAds.enabled
        case .interCloseEdit:
            return adsInfo.enabled && adsInfo.interAds.enabled
        case .interCloseIap:
            return adsInfo.enabled && adsInfo.interAds.enabled
        case .interCloseResult:
            return adsInfo.enabled && adsInfo.interAds.enabled
        }
    }

    private func hasValidAdUnitIdentifier(for slot: Slot) -> Bool {
        !slot.adUnitIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func rewardedAd(for slot: Slot) -> MARewardedAd? {
        switch slot {
        case .rewardedGenerate:
            rewardedGenerateAd
        case .rewardedRegenerate:
            rewardedRegenerateAd
        default:
            nil
        }
    }

    private func slot(for adUnitIdentifier: String) -> Slot? {
        Slot.allCases.first { $0.adUnitIdentifier == adUnitIdentifier }
    }

    private func finishFullscreenAd() {
        guard let slot = activeFullscreenSlot else { return }
        activeFullscreenSlot = nil
        isPresentingFullscreenAd = false
        AppLogger.logAction("MAX finish fullscreen", details: "\(slot.rawValue) adUnit=\(slot.adUnitIdentifier)")

        if let pending = pendingActions.removeValue(forKey: slot) {
            AppLogger.logAction("MAX pending completion", details: "\(slot.rawValue)")
            pending.completion?()
        }

        loadIfNeeded(slot: slot)
    }

    private func handleRetry(for adUnitIdentifier: String) {
        guard let slot = slot(for: adUnitIdentifier) else { return }
        let nextRetry = (retryAttempts[slot] ?? 0) + 1
        retryAttempts[slot] = nextRetry

        let delaySeconds = pow(2.0, min(6.0, Double(nextRetry)))
        AppLogger.logAction(
            "MAX retry scheduled",
            details: "\(slot.rawValue) attempt=\(nextRetry) delay=\(delaySeconds)s"
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
            self?.loadIfNeeded(slot: slot)
        }
    }

    private func adsRequestDetails(for slot: Slot) -> String {
        [
            "global=\(isAdsGloballyEnabled)",
            "slotEnabled=\(isSlotEnabled(slot))",
            "adUnitConfigured=\(hasValidAdUnitIdentifier(for: slot))",
            "paywallDismissCount=\(PaywallExposureTracker.dismissCount)",
            "paywallThreshold=\(paywallDismissThreshold)",
            "metPaywallGate=\(hasMetPaywallDismissGate)",
            "interval=\(adsIntervalSeconds)s",
            "cooldownReady=\(canPresentFullscreenAdNow)",
            "presenting=\(isPresentingFullscreenAd)",
            "resumeShown=\(hasShownResumeThisForeground)",
            "coldStartDone=\(didCompleteColdStart)"
        ].joined(separator: ", ")
    }
}

extension AdsManager: MAAdDelegate {
    func didLoad(_ ad: MAAd) {
        guard let slot = slot(for: ad.adUnitIdentifier) else { return }
        retryAttempts[slot] = 0
        AppLogger.logAction("MAX loaded", details: "\(slot.rawValue) adUnit=\(ad.adUnitIdentifier)")
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        AppLogger.logAction("MAX load failed", details: "\(adUnitIdentifier): \(error.code) \(error.message)")
        handleRetry(for: adUnitIdentifier)
    }

    func didDisplay(_ ad: MAAd) {
        AppLogger.logAction("MAX displayed", details: "\(ad.adUnitIdentifier) / \(ad.format)")
        lastFullscreenAdPresentedAt = Date()
    }

    func didClick(_ ad: MAAd) {
        AppLogger.logAction("MAX clicked", details: "\(ad.adUnitIdentifier)")
    }

    func didHide(_ ad: MAAd) {
        AppLogger.logAction("MAX hidden", details: "\(ad.adUnitIdentifier)")
        finishFullscreenAd()
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AppLogger.logAction("MAX display failed", details: "\(ad.adUnitIdentifier): \(error.code) \(error.message)")
        finishFullscreenAd()
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
    }
}
