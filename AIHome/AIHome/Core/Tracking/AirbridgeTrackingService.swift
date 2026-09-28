import Adapty
import Airbridge
import Foundation
import UIKit

@MainActor
final class AirbridgeTrackingService {
    static let shared = AirbridgeTrackingService()

    private enum Constants {
        static let appNameKey = "AIRBRIDGE_APP_NAME"
        static let sdkTokenKey = "AIRBRIDGE_SDK_TOKEN"
        static let duplicateWindowSeconds: TimeInterval = 1
    }

    private var isConfigured = false
    private var lastHandledURL: URL?
    private var lastHandledAt: Date?

    private init() {}

    func configure() {
        guard !isConfigured else { return }
        guard let appName = infoValue(for: Constants.appNameKey),
              let sdkToken = infoValue(for: Constants.sdkTokenKey) else {
            AppLogger.logAction("Airbridge SDK Skipped", details: "App name or SDK token is not configured")
            return
        }

        let option = AirbridgeOptionBuilder(name: appName, token: sdkToken)
            .build()
        Airbridge.initializeSDK(option: option)
        isConfigured = true
        AppLogger.logAction("Airbridge SDK Initialized", details: appName)

        Airbridge.handleDeferredDeeplink { url in
            guard let url else { return }
            Task { @MainActor in
                AirbridgeDeepLinkRouter.shared.enqueue(url)
            }
        }
    }

    @discardableResult
    func handleOpenURL(_ url: URL) -> Bool {
        guard !isDuplicate(url) else { return true }
        markHandled(url)

        guard isConfigured else {
            AirbridgeDeepLinkRouter.shared.enqueue(url)
            return true
        }

        Airbridge.trackDeeplink(url: url)
        let isAirbridgeDeeplink = Airbridge.handleDeeplink(url: url) { url in
            Task { @MainActor in
                AirbridgeDeepLinkRouter.shared.enqueue(url)
            }
        }

        if !isAirbridgeDeeplink {
            AirbridgeDeepLinkRouter.shared.enqueue(url)
        }

        return true
    }

    @discardableResult
    func handleUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard isConfigured else {
            if let url = userActivity.webpageURL {
                AirbridgeDeepLinkRouter.shared.enqueue(url)
            }
            return userActivity.webpageURL != nil
        }

        Airbridge.trackDeeplink(userActivity: userActivity)
        let isAirbridgeDeeplink = Airbridge.handleDeeplink(userActivity: userActivity) { url in
            Task { @MainActor in
                AirbridgeDeepLinkRouter.shared.enqueue(url)
            }
        }

        if !isAirbridgeDeeplink, let url = userActivity.webpageURL {
            AirbridgeDeepLinkRouter.shared.enqueue(url)
        }

        return isAirbridgeDeeplink || userActivity.webpageURL != nil
    }

    func syncAdaptyIntegrationIdentifier() {
        guard isConfigured else { return }

        Airbridge.fetchDeviceUUID { deviceUUID in
            let trimmedDeviceUUID = deviceUUID.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedDeviceUUID.isEmpty else {
                AppLogger.logError("Missing Airbridge Device UUID")
                return
            }

            Task {
                do {
                    try await Adapty.setIntegrationIdentifier(.airbridgeDeviceId(trimmedDeviceUUID))
                    await MainActor.run {
                        AppLogger.logAction("Adapty Airbridge Integration Synced")
                    }
                } catch {
                    await MainActor.run {
                        AppLogger.logError("Failed to sync Airbridge Device UUID", error: error)
                    }
                }
            }
        }
    }

    func trackAnalyticsEvent(name: String, parameters: [String: Any]) {
        guard isConfigured,
              let event = airbridgeEvent(for: name, parameters: parameters) else { return }

        Airbridge.trackEvent(
            category: event.category,
            semanticAttributes: event.semanticAttributes,
            customAttributes: event.customAttributes
        )
    }

    private func airbridgeEvent(
        for name: String,
        parameters: [String: Any]
    ) -> (category: String, semanticAttributes: [String: Any], customAttributes: [String: Any])? {
        switch name {
        case "ad_impression":
            return (
                category: AirbridgeCategory.AD_IMPRESSION,
                semanticAttributes: semanticAttributes(
                    from: parameters,
                    keyMap: [
                        "value": AirbridgeAttribute.VALUE,
                        "currency": AirbridgeAttribute.CURRENCY
                    ]
                ),
                customAttributes: customAttributes(from: parameters, excluding: ["value", "currency"])
            )
        case "credit_consumed":
            return (
                category: AirbridgeCategory.SPEND_CREDITS,
                semanticAttributes: [:],
                customAttributes: parameters
            )
        case "screen_home":
            return (
                category: AirbridgeCategory.HOME_VIEWED,
                semanticAttributes: [:],
                customAttributes: parameters
            )
        case "select_feature",
             "generation_start",
             "generation_success",
             "screen_paywall",
             "paywall_dismiss",
             "save_result",
             "share_result",
             "rate_app":
            return (
                category: name,
                semanticAttributes: [:],
                customAttributes: parameters
            )
        default:
            return nil
        }
    }

    private func semanticAttributes(from parameters: [String: Any], keyMap: [String: String]) -> [String: Any] {
        parameters.reduce(into: [:]) { result, item in
            guard let mappedKey = keyMap[item.key] else { return }
            result[mappedKey] = item.value
        }
    }

    private func customAttributes(from parameters: [String: Any], excluding keys: Set<String>) -> [String: Any] {
        parameters.filter { !keys.contains($0.key) }
    }

    private func infoValue(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty, !trimmedValue.hasPrefix("$(") else {
            return nil
        }

        return trimmedValue
    }

    private func isDuplicate(_ url: URL) -> Bool {
        guard lastHandledURL == url,
              let lastHandledAt,
              Date().timeIntervalSince(lastHandledAt) < Constants.duplicateWindowSeconds else {
            return false
        }

        return true
    }

    private func markHandled(_ url: URL) {
        lastHandledURL = url
        lastHandledAt = Date()
    }
}
