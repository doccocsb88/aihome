import Adapty
import FacebookCore
import FirebaseAnalytics
import Foundation

@MainActor
final class TrackingBootstrap {
    static let shared = TrackingBootstrap()

    private enum Defaults {
        static let facebookIntegrationKey = "facebook_anonymous_id"
        static let firebaseIntegrationKey = "firebase_app_instance_id"
    }

    private init() {}

    func syncAdaptyIntegrationIdentifiers() async {
        await syncFacebookAnonymousID()
        await syncFirebaseAppInstanceID()
    }

    private func syncFacebookAnonymousID() async {
        let anonymousID = AppEvents.shared.anonymousID.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !anonymousID.isEmpty else {
            AppLogger.logError("Missing Facebook Anonymous ID")
            return
        }

        do {
            try await Adapty.setIntegrationIdentifier(
                key: Defaults.facebookIntegrationKey,
                value: anonymousID
            )
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
            try await Adapty.setIntegrationIdentifier(
                key: Defaults.firebaseIntegrationKey,
                value: appInstanceID
            )
            AppLogger.logAction("Adapty Firebase Integration Synced")
        } catch {
            AppLogger.logError("Failed to sync Firebase App Instance ID", error: error)
        }
    }
}
