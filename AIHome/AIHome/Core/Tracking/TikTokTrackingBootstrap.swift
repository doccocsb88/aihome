import Foundation
import TikTokBusinessSDK

enum TikTokTrackingBootstrap {
    static func configure() {
        guard let appSecret = Bundle.main.object(forInfoDictionaryKey: "TikTokAppSecret") as? String,
              !appSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !appSecret.contains("$(") else {
            AppLogger.logAction("TikTok SDK Skipped", details: "App Secret is not configured")
            return
        }

        // The iOS SDK names its App Secret parameter accessToken.
        guard let config = TikTokConfig(accessToken: appSecret,
                                       appId: "6777677408",
                                       tiktokAppId: "7687883863927701522") else {
            AppLogger.logError("Invalid TikTok SDK configuration")
            return
        }

        // Purchase postbacks are sent manually through PurchaseTrackingCoordinator.
        config.disablePaymentTracking()
        TikTokBusiness.initializeSdk(config) { success, error in
            if success {
                AppLogger.logAction("TikTok SDK Initialized")
            } else {
                AppLogger.logError("TikTok SDK Initialization Failed", error: error)
            }
        }
    }

    static func trackPurchase(_ event: PurchaseTrackingEvent) {
        guard TikTokBusiness.isInitialized() else {
            AppLogger.logAction("TikTok Purchase Skipped", details: "SDK is not initialized")
            return
        }

        let price = NSDecimalNumber(decimal: event.price)
        let purchaseEvent = TikTokPurchaseEvent(eventId: event.eventId)
        purchaseEvent.setContentType(event.contentType)
        purchaseEvent.setContentId(event.productId)
        purchaseEvent.setDescription(event.title)
        purchaseEvent.setValue(price.stringValue)

        if let currencyCode = event.currencyCode, !currencyCode.isEmpty {
            purchaseEvent.setCurrency(TTCurrency(rawValue: currencyCode))
        }

        let content = TikTokContentParams()
        content.price = price
        content.quantity = event.quantity
        content.contentId = event.productId
        content.contentCategory = event.contentType
        content.contentName = event.title
        purchaseEvent.setContents([content])

        TikTokBusiness.trackTTEvent(purchaseEvent)
        AppLogger.logAction(
            "TikTok Purchase Tracked",
            details: "\(event.productId): \(price.stringValue) \(event.currencyCode ?? "")"
        )
    }

    static func trackAppEvent(_ event: AppEventTrackingEvent) {
        guard TikTokBusiness.isInitialized() else {
            AppLogger.logAction("TikTok Event Skipped", details: "SDK is not initialized: \(event.name)")
            return
        }

        let tikTokEvent = TikTokBaseEvent(
            eventName: event.name,
            properties: event.properties,
            eventId: event.eventId
        )
        TikTokBusiness.trackTTEvent(tikTokEvent)
    }
}
