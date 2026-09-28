import Adapty
import AppTrackingTransparency
import FacebookCore
import FirebaseAnalytics
import Foundation
import UIKit

@MainActor
final class TrackingBootstrap {
    static let shared = TrackingBootstrap()

    private var isFacebookInitialized = false
    private var hasCompletedConsentFlow = false
    private var lastReportedATTStatus: ATTrackingManager.AuthorizationStatus?

    private init() {}

    func configureFacebook() {
        // Adapty's Meta integration owns all subscription and purchase events.
        Settings.shared.isAutoLogAppEventsEnabled = false
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

        // Preserve session/install reporting with automatic purchase logging disabled.
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
