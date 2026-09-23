import Adapty
import Foundation

struct PurchaseTrackingEvent {
    let eventId: String
    let productId: String
    let title: String
    let price: Decimal
    let currencyCode: String?
    let contentType: String
    let quantity: Int
}

@MainActor
enum PurchaseTrackingCoordinator {
    private static var trackedEventIds = Set<String>()

    static func trackPurchase(
        product: AdaptyPaywallProduct,
        eventId: String? = nil
    ) {
        let resolvedEventId = eventId ?? UUID().uuidString
        guard trackedEventIds.insert(resolvedEventId).inserted else {
            AppLogger.logAction("Purchase Tracking Skipped", details: "Duplicate event id: \(resolvedEventId)")
            return
        }

        let event = PurchaseTrackingEvent(
            eventId: resolvedEventId,
            productId: product.vendorProductId,
            title: product.localizedTitle,
            price: product.price,
            currencyCode: product.currencyCode?.uppercased(),
            contentType: "subscription",
            quantity: 1
        )

        trackMetaPurchase(event)
        TikTokTrackingBootstrap.trackPurchase(event)
    }

    private static func trackMetaPurchase(_ event: PurchaseTrackingEvent) {
        // Adapty's Meta integration owns subscription purchase reporting.
        AppLogger.logAction("Meta Purchase Tracking Skipped", details: "Handled by Adapty: \(event.productId)")
    }
}
