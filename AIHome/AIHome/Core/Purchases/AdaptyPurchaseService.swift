import Adapty
import AdaptyUI
import Foundation

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
            "Adapty paywall placement is not configured."
        case .noProducts:
            "No products are available for this paywall."
        }
    }
}

@MainActor
final class AdaptyPurchaseService {
    static let shared = AdaptyPurchaseService()

    private enum Defaults {
        static let publicSDKKey = "public_live_Z9bFijzJ.C3HmFcRBviO4VivLzi7l"
        static let placementId = "top_bar_ios"
        static let accessLevelId = "premium"
    }

    private let userDefaults: UserDefaults
    private var activationTask: Task<Void, Error>?

    private var publicSDKKey: String {
        infoValue(for: "ADAPTY_PUBLIC_SDK_KEY", defaultValue: Defaults.publicSDKKey)
    }

    private var placementId: String {
        infoValue(for: "ADAPTY_PAYWALL_PLACEMENT_ID", defaultValue: Defaults.placementId)
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
            try await AdaptyUI.activate()
        }
    }

    func loadPaywallProducts(placementId: String? = nil) async throws -> [AdaptyPaywallProduct] {
        try await ensureActivated()

        let paywall = try await loadPaywall(placementId: placementId)
        let products = try await Adapty.getPaywallProducts(paywall: paywall)

        guard !products.isEmpty else {
            throw PurchaseServiceError.noProducts
        }

        return products
    }

    func loadSDKPaywallConfiguration(placementId: String? = nil) async throws -> AdaptyUI.PaywallConfiguration {
        try await ensureActivated()

        let paywall = try await loadPaywall(placementId: placementId)
        return try await AdaptyUI.getPaywallConfiguration(forPaywall: paywall)
    }

    private func loadPaywall(placementId: String? = nil) async throws -> AdaptyPaywall {
        let resolvedPlacementId = placementId ?? self.placementId

        guard !resolvedPlacementId.isEmpty else {
            throw PurchaseServiceError.missingPlacementId
        }

        return try await Adapty.getPaywall(placementId: resolvedPlacementId)
    }

    func makePurchase(product: AdaptyPaywallProduct) async throws -> PurchaseActivationResult {
        try await ensureActivated()

        let purchaseResult = try await Adapty.makePurchase(product: product)
        switch purchaseResult {
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        case let .success(profile, _):
            let hasAccess = profile.accessLevels[accessLevelId]?.isActive ?? false
            cachePremiumStatus(hasAccess)
            return hasAccess ? .active : .inactive
        }
    }

    func restorePurchases() async throws -> Bool {
        try await ensureActivated()

        let profile = try await Adapty.restorePurchases()
        let hasAccess = profile.accessLevels[accessLevelId]?.isActive ?? false
        cachePremiumStatus(hasAccess)
        return hasAccess
    }

    func refreshPremiumStatus() async throws -> Bool {
        try await ensureActivated()

        let profile = try await Adapty.getProfile()
        let hasAccess = profile.accessLevels[accessLevelId]?.isActive ?? false
        cachePremiumStatus(hasAccess)
        return hasAccess
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
