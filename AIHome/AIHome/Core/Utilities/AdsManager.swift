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

        var adUnitID: String {
            switch self {
            case .openSplash:
                return "05a37b30d8cee5ff"
            case .openResume:
                return "ccb2f614ccdfd440"
            case .rewardedGenerate:
                return "d4c21fc7205f62a0"
            case .rewardedRegenerate:
                return "a3a09e4d782ed80b"
            case .interCloseEdit:
                return "2024866b95177a63"
            case .interCloseIap:
                return "cc3c5cb6f6a84a14"
            case .interCloseResult:
                return "34a8c80d44b9af2d"
            }
        }
    }

    private struct PendingAction {
        var completion: (() -> Void)?
    }

    private enum Configuration {
        static let sdkKey = "J2ks4TF6rLetzM0TgPvggyqLiCRTUJ1afPHWi0la24rZnZOul9gyfkD4JtAmbcua43fHqHHBzV20zrbR6Ilz5G"
    }

    private var appOpenSplashAd: MAInterstitialAd?
    private var appOpenResumeAd: MAInterstitialAd?
    private var rewardedGenerateAd: MARewardedAd?
    private var rewardedRegenerateAd: MARewardedAd?
    private var interCloseEditAd: MAInterstitialAd?
    private var interCloseIapAd: MAInterstitialAd?
    private var interCloseResultAd: MAInterstitialAd?
    private var pendingActions: [Slot: PendingAction] = [:]
    private var retryAttempts: [Slot: Int] = [:]
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

        guard let sdk = ALSdk.shared(withKey: Configuration.sdkKey) else {
            AppLogger.logAction("MAX SDK unavailable", details: "missing sdk instance")
            return
        }

        sdk.mediationProvider = ALMediationProviderMAX
        sdk.initializeSdk(completionHandler: { [weak self] _ in
            self?.prepareAds()
        }
        )
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
        presentAppOpenAd(
            slot: .openSplash,
            placement: Slot.openSplash.rawValue,
            completion: completion,
            markColdStartCompletedAfterDismissal: true
        )
    }

    func showAppOpenResumeIfReady() {
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
        presentRewardedAd(slot: .rewardedGenerate, placement: Slot.rewardedGenerate.rawValue, completion: completion)
    }

    func showRewardedRegenerateIfNeeded(completion: @escaping () -> Void) {
        presentRewardedAd(slot: .rewardedRegenerate, placement: Slot.rewardedRegenerate.rawValue, completion: completion)
    }

    func showInterstitialCloseEdit(completion: @escaping () -> Void) {
        presentInterstitialAd(slot: .interCloseEdit, placement: Slot.interCloseEdit.rawValue, completion: completion)
    }

    func showInterstitialCloseIap(completion: @escaping () -> Void) {
        presentInterstitialAd(slot: .interCloseIap, placement: Slot.interCloseIap.rawValue, completion: completion)
    }

    func showInterstitialCloseResult(completion: @escaping () -> Void) {
        presentInterstitialAd(slot: .interCloseResult, placement: Slot.interCloseResult.rawValue, completion: completion)
    }

    func handlePaywallExposureUpdated() {
        guard isAdsGloballyEnabled else { return }
        guard hasMetPaywallDismissGate else { return }
        guard !didUnlockAdsAfterPaywallGate else { return }

        didUnlockAdsAfterPaywallGate = true
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

        appOpenSplashAd = makeAppOpenAd(for: .openSplash)
        appOpenResumeAd = makeAppOpenAd(for: .openResume)
        rewardedGenerateAd = makeRewardedAd(for: .rewardedGenerate)
        rewardedRegenerateAd = makeRewardedAd(for: .rewardedRegenerate)
        interCloseEditAd = makeInterstitialAd(for: .interCloseEdit)
        interCloseIapAd = makeInterstitialAd(for: .interCloseIap)
        interCloseResultAd = makeInterstitialAd(for: .interCloseResult)

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

    private func makeAppOpenAd(for slot: Slot) -> MAInterstitialAd {
        let ad = MAInterstitialAd(adUnitIdentifier: slot.adUnitID)
        ad.delegate = self
        return ad
    }

    private func makeInterstitialAd(for slot: Slot) -> MAInterstitialAd {
        let ad = MAInterstitialAd(adUnitIdentifier: slot.adUnitID)
        ad.delegate = self
        return ad
    }

    private func makeRewardedAd(for slot: Slot) -> MARewardedAd {
        let ad = MARewardedAd.shared(withAdUnitIdentifier: slot.adUnitID)
        ad.delegate = self
        return ad
    }

    private func loadAllAds() {
        loadIfNeeded(slot: .openSplash)
        loadIfNeeded(slot: .openResume)
        loadIfNeeded(slot: .rewardedGenerate)
        loadIfNeeded(slot: .rewardedRegenerate)
        loadIfNeeded(slot: .interCloseEdit)
        loadIfNeeded(slot: .interCloseIap)
        loadIfNeeded(slot: .interCloseResult)
    }

    private func loadIfNeeded(slot: Slot) {
        guard shouldShowAdsForCurrentUser else { return }

        switch slot {
        case .openSplash:
            guard RemoteConfigManager.shared.maxOpenSplashEnable else { return }
            appOpenSplashAd?.load()
        case .openResume:
            guard RemoteConfigManager.shared.maxOpenResumeEnable else { return }
            appOpenResumeAd?.load()
        case .rewardedGenerate:
            guard RemoteConfigManager.shared.maxRewardedGenerateEnable else { return }
            rewardedGenerateAd?.load()
        case .rewardedRegenerate:
            guard RemoteConfigManager.shared.maxRewardedRegenerateEnable else { return }
            rewardedRegenerateAd?.load()
        case .interCloseEdit:
            guard RemoteConfigManager.shared.maxInterCloseEditEnable else { return }
            interCloseEditAd?.load()
        case .interCloseIap:
            guard RemoteConfigManager.shared.maxInterCloseIapEnable else { return }
            interCloseIapAd?.load()
        case .interCloseResult:
            guard RemoteConfigManager.shared.maxInterCloseResultEnable else { return }
            interCloseResultAd?.load()
        }
    }

    private func presentAppOpenAd(
        slot: Slot,
        placement: String,
        completion: @escaping () -> Void,
        markColdStartCompletedAfterDismissal: Bool
    ) {
        guard shouldShowAdsForCurrentUser else {
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard canPresentFullscreenAdNow else {
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard isSlotEnabled(slot) else {
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            completion()
            return
        }

        guard !isPresentingFullscreenAd else {
            completion()
            return
        }

        guard let ad = appOpenAd(for: slot), ad.isReady else {
            if markColdStartCompletedAfterDismissal {
                didCompleteColdStart = true
            }
            loadIfNeeded(slot: slot)
            completion()
            return
        }

        pendingActions[slot] = PendingAction(completion: {
            if markColdStartCompletedAfterDismissal {
                self.didCompleteColdStart = true
            }
            completion()
        })
        isPresentingFullscreenAd = true
        ad.show(forPlacement: placement)
    }

    private func presentInterstitialAd(
        slot: Slot,
        placement: String,
        completion: @escaping () -> Void
    ) {
        guard canPresentFullscreenAdNow, isSlotEnabled(slot) else {
            completion()
            return
        }

        guard !isPresentingFullscreenAd else {
            completion()
            return
        }

        guard let ad = interstitialAd(for: slot), ad.isReady else {
            loadIfNeeded(slot: slot)
            completion()
            return
        }

        pendingActions[slot] = PendingAction(completion: completion)
        isPresentingFullscreenAd = true
        ad.show(forPlacement: placement)
    }

    private func presentRewardedAd(
        slot: Slot,
        placement: String,
        completion: @escaping () -> Void
    ) {
        guard canPresentFullscreenAdNow, isSlotEnabled(slot) else {
            completion()
            return
        }

        guard !isPresentingFullscreenAd else {
            completion()
            return
        }

        guard let ad = rewardedAd(for: slot), ad.isReady else {
            loadIfNeeded(slot: slot)
            completion()
            return
        }

        pendingActions[slot] = PendingAction(completion: completion)
        isPresentingFullscreenAd = true
        ad.show(forPlacement: placement)
    }

    private func isSlotEnabled(_ slot: Slot) -> Bool {
        switch slot {
        case .openSplash:
            RemoteConfigManager.shared.maxOpenSplashEnable
        case .openResume:
            RemoteConfigManager.shared.maxOpenResumeEnable
        case .rewardedGenerate:
            RemoteConfigManager.shared.maxRewardedGenerateEnable
        case .rewardedRegenerate:
            RemoteConfigManager.shared.maxRewardedRegenerateEnable
        case .interCloseEdit:
            RemoteConfigManager.shared.maxInterCloseEditEnable
        case .interCloseIap:
            RemoteConfigManager.shared.maxInterCloseIapEnable
        case .interCloseResult:
            RemoteConfigManager.shared.maxInterCloseResultEnable
        }
    }

    private func appOpenAd(for slot: Slot) -> MAInterstitialAd? {
        switch slot {
        case .openSplash:
            appOpenSplashAd
        case .openResume:
            appOpenResumeAd
        default:
            nil
        }
    }

    private func interstitialAd(for slot: Slot) -> MAInterstitialAd? {
        switch slot {
        case .interCloseEdit:
            interCloseEditAd
        case .interCloseIap:
            interCloseIapAd
        case .interCloseResult:
            interCloseResultAd
        default:
            nil
        }
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
        Slot.allCases.first { $0.adUnitID == adUnitIdentifier }
    }

    private func finishFullscreenAd(for adUnitIdentifier: String) {
        guard let slot = slot(for: adUnitIdentifier) else { return }
        isPresentingFullscreenAd = false

        if let pending = pendingActions.removeValue(forKey: slot) {
            pending.completion?()
        }

        loadIfNeeded(slot: slot)
    }

    private func handleRetry(for adUnitIdentifier: String) {
        guard let slot = slot(for: adUnitIdentifier) else { return }
        let nextRetry = (retryAttempts[slot] ?? 0) + 1
        retryAttempts[slot] = nextRetry

        let delaySeconds = pow(2.0, min(6.0, Double(nextRetry)))
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) { [weak self] in
            self?.loadIfNeeded(slot: slot)
        }
    }
}

extension AdsManager: MAAdDelegate {
    func didLoad(_ ad: MAAd) {
        guard let slot = slot(for: ad.adUnitIdentifier) else { return }
        retryAttempts[slot] = 0
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
        finishFullscreenAd(for: ad.adUnitIdentifier)
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        AppLogger.logAction("MAX display failed", details: "\(ad.adUnitIdentifier): \(error.code) \(error.message)")
        finishFullscreenAd(for: ad.adUnitIdentifier)
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
