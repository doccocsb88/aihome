import Adapty
import AppTrackingTransparency
import FacebookCore
import FirebaseAnalytics
import Foundation
import StoreKit
import TikTokBusinessSDK
import UIKit

@MainActor
final class TrackingBootstrap {
    static let shared = TrackingBootstrap()

    private var isFacebookInitialized = false
    private var hasCompletedConsentFlow = false
    private var lastReportedATTStatus: ATTrackingManager.AuthorizationStatus?
    private var storeKitTransactionTask: Task<Void, Never>?
    private let trackingDefaults = UserDefaults.standard

    private enum PurchaseTrackingKeys {
        static let startedTransactions = "ads.startedSubscriptionTransactions"
        static let trialTransactions = "ads.trialSubscriptionTransactions"
        static let convertedTrialTransactions = "ads.convertedTrialTransactions"
    }

    private init() {}

    func configureFacebook() {
        // Enable Meta's install, app activation, and in-app purchase event logging.
        Settings.shared.isAutoLogAppEventsEnabled = true
    }

    func configureTikTok() {
        guard let appID = infoValue(for: "TikTokAppleAppID"),
              let tikTokAppID = infoValue(for: "TikTokAppID"),
              let appSecret = infoValue(for: "TikTokAppSecret"),
              let config = TikTokConfig(
                accessToken: appSecret,
                appId: appID,
                tiktokAppId: tikTokAppID
              ) else {
            AppLogger.logAction("TikTok App Events SDK Skipped", details: "Missing TikTok SDK configuration")
            return
        }

        // Airbridge owns SKAN conversion value updates. Keep TikTok lifecycle and
        // StoreKit purchase auto-logging enabled; manual events below add trial/subscription semantics.
        config.disableSKAdNetworkSupport()
        TikTokBusiness.initializeSdk(config) { success, error in
            if success {
                AppLogger.logAction("TikTok App Events SDK Initialized")
                Task { @MainActor in
                    self.startStoreKitTransactionTracking()
                }
            } else {
                AppLogger.logError("TikTok App Events SDK Initialization Failed", error: error)
            }
        }
    }

    private func startStoreKitTransactionTracking() {
        guard storeKitTransactionTask == nil else { return }

        storeKitTransactionTask = Task { [weak self] in
            let updatesTask = Task { [weak self] in
                for await result in Transaction.updates {
                    guard let self else { return }
                    await self.processTransaction(result)
                }
            }

            for await result in Transaction.currentEntitlements {
                guard let self else { return }
                await self.processTransaction(result)
            }

            await updatesTask.value
        }
    }

    private func processTransaction(_ result: VerificationResult<Transaction>) async {
        guard case let .verified(transaction) = result,
              transaction.productType == .autoRenewable else { return }

        let transactionID = String(transaction.originalID)
        let started = trackingDefaults.stringArray(forKey: PurchaseTrackingKeys.startedTransactions) ?? []
        let trials = trackingDefaults.stringArray(forKey: PurchaseTrackingKeys.trialTransactions) ?? []
        let converted = trackingDefaults.stringArray(forKey: PurchaseTrackingKeys.convertedTrialTransactions) ?? []

        if transaction.offerType == .introductory {
            guard !trials.contains(transactionID) else { return }
            trackingDefaults.set(trials + [transactionID], forKey: PurchaseTrackingKeys.trialTransactions)
            trackingDefaults.set(started + [transactionID], forKey: PurchaseTrackingKeys.startedTransactions)
            trackStandardEvent("StartTrial")
            return
        }

        if trials.contains(transactionID) {
            guard !converted.contains(transactionID) else { return }
            trackingDefaults.set(converted + [transactionID], forKey: PurchaseTrackingKeys.convertedTrialTransactions)
            trackStandardEvent("Subscribe")
            return
        }

        guard !started.contains(transactionID) else { return }
        trackingDefaults.set(started + [transactionID], forKey: PurchaseTrackingKeys.startedTransactions)
        trackStandardEvent("Subscribe")
    }

    private func trackStandardEvent(_ eventName: String) {
        AppEvents.shared.logEvent(AppEvents.Name(eventName))
        TikTokBusiness.trackTTEvent(TikTokBaseEvent(eventName: eventName))
        AppLogger.logAction("Ads Standard Event", details: eventName)
    }

    private func infoValue(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    func facebookDidInitialize() {
        isFacebookInitialized = true
        applicationDidBecomeActive()
    }

    func consentFlowDidComplete() {
        hasCompletedConsentFlow = true
        reportATTStatusIfNeeded()
    }

    func applicationDidBecomeActive() {
        guard isFacebookInitialized,
              UIApplication.shared.applicationState == .active else { return }

        // Preserve Meta session/install reporting alongside its automatic purchase logging.
        AppEvents.shared.activateApp()
        reportATTStatusIfNeeded()
    }

    private func reportATTStatusIfNeeded() {
        guard isFacebookInitialized, hasCompletedConsentFlow,
              UIApplication.shared.applicationState == .active else { return }

        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status != lastReportedATTStatus else { return }

        let statusName: String
        switch status {
        case .authorized: statusName = "authorized"
        case .denied: statusName = "denied"
        case .restricted: statusName = "restricted"
        case .notDetermined: statusName = "not_determined"
        @unknown default: statusName = "unknown"
        }

        // iOS 17+ reads ATE directly from ATT. A later decision must still emit an update.
        AppEvents.shared.logEvent(AppEvents.Name("att_status_updated"))
        AppEvents.shared.flush()
        Analytics.logEvent("att_status_updated", parameters: [
            "status": statusName,
            "meta_ate": Settings.shared.isAdvertiserTrackingEnabled ? 1 : 0
        ])
        AppLogger.logAction("ATT Status Reported", details: statusName)
        lastReportedATTStatus = status
    }

    func syncAdaptyIntegrationIdentifiers() async {
        await syncFacebookAnonymousID()
        await syncFirebaseAppInstanceID()
        syncAirbridgeDeviceID()
    }

    private func syncFacebookAnonymousID() async {
        let anonymousID = AppEvents.shared.anonymousID.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !anonymousID.isEmpty else {
            AppLogger.logError("Missing Facebook Anonymous ID")
            return
        }

        do {
            try await Adapty.setIntegrationIdentifier(.facebookAnonymousId(anonymousID))
            AppLogger.logAction("Adapty Facebook Integration Synced")
        } catch {
            AppLogger.logError("Failed to sync Facebook Anonymous ID", error: error)
        }
    }

    private func syncFirebaseAppInstanceID() async {
        guard let appInstanceID = Analytics.appInstanceID(),
              !appInstanceID.isEmpty else {
            AppLogger.logError("Missing Firebase App Instance ID")
            return
        }

        do {
            try await Adapty.setIntegrationIdentifier(.firebaseAppInstanceId(appInstanceID))
            AppLogger.logAction("Adapty Firebase Integration Synced")
        } catch {
            AppLogger.logError("Failed to sync Firebase App Instance ID", error: error)
        }
    }

    private func syncAirbridgeDeviceID() {
        AirbridgeTrackingService.shared.syncAdaptyIntegrationIdentifier()
    }
}
