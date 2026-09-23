import Adapty
import AdaptyUI
import Foundation
import StoreKit

enum PurchaseActivationResult {
    case active
    case pending
    case cancelled
    case inactive
}

enum PurchaseServiceError: LocalizedError {
    case missingPublicSDKKey
    case missingPlacementId
    case noProducts

    var errorDescription: String? {
        switch self {
        case .missingPublicSDKKey:
            "Adapty Public SDK Key is not configured."
        case .missingPlacementId:
            "Adapty flow placement is not configured."
        case .noProducts:
            "No products are available for this flow."
        }
    }
}

@MainActor
final class AdaptyPurchaseService {
    static let shared = AdaptyPurchaseService()

    enum Placement: String, CaseIterable {
        case bannerSettings = "flow_banner_settings_ios"
        case limitToken = "flow_limit_token_ios"
        case proButton = "flow_pro_button_ios"
        case watermark = "flow_watermark_ios"
        case session = "flow_session_ios"
        case onboarding = "flow_onboarding_ios"
    }

    private enum Defaults {
        static let publicSDKKey = "public_live_Z9bFijzJ.C3HmFcRBviO4VivLzi7l"
        static let placementId = Placement.proButton.rawValue
        static let accessLevelId = "premium"
    }

    private let userDefaults: UserDefaults
    private var activationTask: Task<Void, Error>?

    private var publicSDKKey: String {
        infoValue(for: "ADAPTY_PUBLIC_SDK_KEY", defaultValue: Defaults.publicSDKKey)
    }

    private var placementId: String {
        infoValue(for: "ADAPTY_FLOW_PLACEMENT_ID", defaultValue: Defaults.placementId)
    }

    private var accessLevelId: String {
        infoValue(for: "ADAPTY_ACCESS_LEVEL_ID", defaultValue: Defaults.accessLevelId)
    }

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func configure() {
        guard activationTask == nil else { return }
        guard !publicSDKKey.isEmpty else { return }

        activationTask = Task {
            let config = AdaptyConfiguration
                .builder(withAPIKey: publicSDKKey)
                .build()

            try await Adapty.activate(with: config)
            await TrackingBootstrap.shared.syncAdaptyIntegrationIdentifiers()
            try await AdaptyUI.activate()
        }
    }

    func loadPaywallProducts(placementId: String? = nil) async throws -> [AdaptyPaywallProduct] {
        try await ensureActivated()

        let flow = try await loadFlow(placementId: placementId)
        let products = try await Adapty.getPaywallProducts(flow: flow)

        guard !products.isEmpty else {
            throw PurchaseServiceError.noProducts
        }

        return products
    }

    func loadPaywallProducts(placement: Placement) async throws -> [AdaptyPaywallProduct] {
        try await loadPaywallProducts(placementId: placement.rawValue)
    }

    func loadSDKFlowConfiguration(placementId: String? = nil) async throws -> AdaptyUI.FlowConfiguration {
        try await ensureActivated()

        let flow = try await loadFlow(placementId: placementId)
        return try await AdaptyUI.getFlowConfiguration(forFlow: flow)
    }

    func loadSDKFlowConfiguration(placement: Placement) async throws -> AdaptyUI.FlowConfiguration {
        try await loadSDKFlowConfiguration(placementId: placement.rawValue)
    }

    func availablePlacementIds() -> [String] {
        Placement.allCases.map(\.rawValue)
    }

    private func loadFlow(placementId: String? = nil) async throws -> AdaptyFlow {
        let resolvedPlacementId = placementId ?? self.placementId

        guard !resolvedPlacementId.isEmpty else {
            throw PurchaseServiceError.missingPlacementId
        }

        return try await Adapty.getFlow(placementId: resolvedPlacementId)
    }

    func makePurchase(product: AdaptyPaywallProduct) async throws -> PurchaseActivationResult {
        try await ensureActivated()

        let purchaseResult = try await Adapty.makePurchase(product: product)
        switch purchaseResult {
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        case let .success(profile, transaction):
            let hasAccess = hasPremiumAccess(profile)
            cachePremiumStatus(hasAccess)
            PurchaseTrackingCoordinator.trackPurchase(
                product: product,
                eventId: String(transaction.unsafePayloadValue.id)
            )
            return hasAccess ? .active : .inactive
        }
    }

    func restorePurchases() async throws -> Bool {
        try await ensureActivated()

        let profile = try await Adapty.restorePurchases()
        let hasAccess = hasPremiumAccess(profile)
        cachePremiumStatus(hasAccess)
        return hasAccess
    }

    func refreshPremiumStatus() async throws -> Bool {
        try await ensureActivated()

        let profile = try await Adapty.getProfile()
        let hasAccess = hasPremiumAccess(profile)
        cachePremiumStatus(hasAccess)
        return hasAccess
    }

    func hasPremiumAccess(_ profile: AdaptyProfile) -> Bool {
        profile.accessLevels[accessLevelId]?.isActive ?? false
    }

    private func ensureActivated() async throws {
        if activationTask == nil {
            configure()
        }

        guard let activationTask else {
            throw PurchaseServiceError.missingPublicSDKKey
        }

        try await activationTask.value
    }

    private func cachePremiumStatus(_ isActive: Bool) {
        userDefaults.set(isActive, forKey: "isProCached")
        UserManager.shared.setPremiumStatus(isActive)
    }

    private func infoValue(for key: String, defaultValue: String = "") -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return defaultValue
        }

        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedValue.hasPrefix("$(") {
            return defaultValue
        }

        return trimmedValue
    }
}
