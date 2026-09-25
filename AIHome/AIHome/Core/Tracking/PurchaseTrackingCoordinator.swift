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

struct AppEventTrackingEvent {
    let name: String
    let eventId: String
    let properties: [String: Any]
}

@MainActor
enum PurchaseTrackingCoordinator {
    fileprivate enum Constants {
        static let trackedEventIdsKey = "purchaseTracking.trackedEventIds"
        static let freeTrialOfferType = "free_trial"
        static let startTrialEventName = "StartTrial"
        static let subscribeEventName = "Subscribe"
        static let qualifiedTrialEventName = "QualifiedTrial"
        static let qualifiedTrialDelay: TimeInterval = 60 * 60
    }

    private static var trackedEventIds = Set(UserDefaults.standard.stringArray(forKey: Constants.trackedEventIdsKey) ?? [])
    private static var scheduledEvaluationEventIds = Set<String>()

    static func trackPurchase(
        product: AdaptyPaywallProduct,
        profile: AdaptyProfile,
        eventId: String? = nil
    ) {
        let resolvedEventId = eventId ?? UUID().uuidString
        guard reserveEventId(resolvedEventId) else {
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
        trackPurchaseLifecycleEvents(product: product, profile: profile)
    }

    static func evaluateProfile(_ profile: AdaptyProfile) {
        for accessLevel in activeAccessLevels(in: profile) {
            trackQualifiedTrialIfNeeded(accessLevel)
            scheduleQualifiedTrialEvaluationIfNeeded(accessLevel)
            trackConvertedTrialSubscribeIfNeeded(accessLevel)
        }
    }

    private static func trackMetaPurchase(_ event: PurchaseTrackingEvent) {
        // Adapty's Meta integration owns subscription purchase reporting.
        AppLogger.logAction("Meta Purchase Tracking Skipped", details: "Handled by Adapty: \(event.productId)")
    }

    private static func trackPurchaseLifecycleEvents(
        product: AdaptyPaywallProduct,
        profile: AdaptyProfile
    ) {
        let matchingAccessLevels = activeAccessLevels(in: profile)
            .filter { $0.vendorProductId == product.vendorProductId }

        for accessLevel in matchingAccessLevels {
            if accessLevel.isActiveFreeTrial {
                trackStartTrial(accessLevel, product: product)
                trackQualifiedTrialIfNeeded(accessLevel)
                scheduleQualifiedTrialEvaluationIfNeeded(accessLevel)
            } else {
                trackSubscribe(accessLevel, product: product, source: "purchase")
            }
        }
    }

    private static func trackStartTrial(
        _ accessLevel: AdaptyProfile.AccessLevel,
        product: AdaptyPaywallProduct
    ) {
        let eventId = lifecycleEventId("start_trial", accessLevel: accessLevel, date: accessLevel.activatedAt)
        guard reserveEventId(eventId) else { return }

        let event = appEvent(
            name: Constants.startTrialEventName,
            eventId: eventId,
            accessLevel: accessLevel,
            product: product,
            source: "purchase"
        )
        TikTokTrackingBootstrap.trackAppEvent(event)
        AppLogger.logAction("TikTok StartTrial Tracked", details: accessLevel.vendorProductId)
    }

    private static func trackQualifiedTrialIfNeeded(_ accessLevel: AdaptyProfile.AccessLevel) {
        guard accessLevel.isActiveFreeTrial,
              accessLevel.willRenew,
              accessLevel.unsubscribedAt == nil,
              Date().timeIntervalSince(accessLevel.activatedAt) >= Constants.qualifiedTrialDelay,
              hasTrackedStartTrial(accessLevel) else { return }

        let eventId = lifecycleEventId("qualified_trial", accessLevel: accessLevel, date: accessLevel.activatedAt)
        guard reserveEventId(eventId) else { return }

        let event = appEvent(
            name: Constants.qualifiedTrialEventName,
            eventId: eventId,
            accessLevel: accessLevel,
            product: nil,
            source: "qualified_trial_check",
            extraProperties: [
                "trial_age_seconds": Int(Date().timeIntervalSince(accessLevel.activatedAt))
            ]
        )
        TikTokTrackingBootstrap.trackAppEvent(event)
        AppLogger.logAction("TikTok QualifiedTrial Tracked", details: accessLevel.vendorProductId)
    }

    private static func scheduleQualifiedTrialEvaluationIfNeeded(_ accessLevel: AdaptyProfile.AccessLevel) {
        guard accessLevel.isActiveFreeTrial,
              accessLevel.willRenew,
              accessLevel.unsubscribedAt == nil,
              hasTrackedStartTrial(accessLevel) else { return }

        let eventId = lifecycleEventId("qualified_trial", accessLevel: accessLevel, date: accessLevel.activatedAt)
        guard !trackedEventIds.contains(eventId),
              scheduledEvaluationEventIds.insert(eventId).inserted else { return }

        let trialAge = Date().timeIntervalSince(accessLevel.activatedAt)
        let remainingDelay = max(0, Constants.qualifiedTrialDelay - trialAge)
        Task {
            if remainingDelay > 0 {
                try? await Task.sleep(nanoseconds: UInt64(remainingDelay * 1_000_000_000))
            }

            guard let profile = try? await Adapty.getProfile() else {
                await PurchaseTrackingCoordinator.clearScheduledQualifiedTrialEvaluation(eventId)
                return
            }

            await PurchaseTrackingCoordinator.clearScheduledQualifiedTrialEvaluation(eventId)
            await PurchaseTrackingCoordinator.evaluateProfile(profile)
        }
    }

    private static func clearScheduledQualifiedTrialEvaluation(_ eventId: String) {
        scheduledEvaluationEventIds.remove(eventId)
    }

    private static func trackConvertedTrialSubscribeIfNeeded(_ accessLevel: AdaptyProfile.AccessLevel) {
        guard !accessLevel.isActiveFreeTrial,
              accessLevel.renewedAt != nil,
              hasTrackedStartTrial(accessLevel) else { return }

        trackSubscribe(accessLevel, product: nil, source: "trial_converted")
    }

    private static func trackSubscribe(
        _ accessLevel: AdaptyProfile.AccessLevel,
        product: AdaptyPaywallProduct?,
        source: String
    ) {
        let date = accessLevel.renewedAt ?? accessLevel.activatedAt
        let eventId = lifecycleEventId("subscribe", accessLevel: accessLevel, date: date)
        guard reserveEventId(eventId) else { return }

        let event = appEvent(
            name: Constants.subscribeEventName,
            eventId: eventId,
            accessLevel: accessLevel,
            product: product,
            source: source
        )
        TikTokTrackingBootstrap.trackAppEvent(event)
        AppLogger.logAction("TikTok Subscribe Tracked", details: "\(source): \(accessLevel.vendorProductId)")
    }

    private static func appEvent(
        name: String,
        eventId: String,
        accessLevel: AdaptyProfile.AccessLevel,
        product: AdaptyPaywallProduct?,
        source: String,
        extraProperties: [String: Any] = [:]
    ) -> AppEventTrackingEvent {
        var properties: [String: Any] = [
            "content_type": "subscription",
            "content_id": accessLevel.vendorProductId,
            "product_id": accessLevel.vendorProductId,
            "access_level_id": accessLevel.id,
            "source": source,
            "will_renew": accessLevel.willRenew,
            "is_free_trial": accessLevel.isActiveFreeTrial
        ]

        if let product {
            properties["description"] = product.localizedTitle
            properties["value"] = NSDecimalNumber(decimal: product.price).stringValue
            if let currencyCode = product.currencyCode?.uppercased(), !currencyCode.isEmpty {
                properties["currency"] = currencyCode
            }
        }

        if let renewedAt = accessLevel.renewedAt {
            properties["renewed_at"] = Int(renewedAt.timeIntervalSince1970)
        }

        properties["activated_at"] = Int(accessLevel.activatedAt.timeIntervalSince1970)
        extraProperties.forEach { properties[$0.key] = $0.value }
        return AppEventTrackingEvent(name: name, eventId: eventId, properties: properties)
    }

    private static func activeAccessLevels(in profile: AdaptyProfile) -> [AdaptyProfile.AccessLevel] {
        profile.accessLevels.values
            .filter { $0.isActive && !$0.isRefund }
            .sorted { $0.activatedAt < $1.activatedAt }
    }

    private static func hasTrackedStartTrial(_ accessLevel: AdaptyProfile.AccessLevel) -> Bool {
        trackedEventIds.contains(lifecycleEventId("start_trial", accessLevel: accessLevel, date: accessLevel.activatedAt))
    }

    private static func lifecycleEventId(
        _ prefix: String,
        accessLevel: AdaptyProfile.AccessLevel,
        date: Date
    ) -> String {
        "\(prefix):\(accessLevel.id):\(accessLevel.vendorProductId):\(Int(date.timeIntervalSince1970))"
    }

    private static func reserveEventId(_ eventId: String) -> Bool {
        guard trackedEventIds.insert(eventId).inserted else { return false }
        persistTrackedEventIds()
        return true
    }

    private static func persistTrackedEventIds() {
        UserDefaults.standard.set(Array(trackedEventIds).sorted(), forKey: Constants.trackedEventIdsKey)
    }
}

private extension AdaptyProfile.AccessLevel {
    var isActiveFreeTrial: Bool {
        activeIntroductoryOfferType == PurchaseTrackingCoordinator.Constants.freeTrialOfferType ||
            activePromotionalOfferType == PurchaseTrackingCoordinator.Constants.freeTrialOfferType
    }
}
