import Adapty
import AdaptyUI
import SwiftUI

struct GenerationUsageLimitModifier: ViewModifier {
    @Binding var isPresented: Bool

    var placement: AdaptyPurchaseService.Placement = .limitToken

    @State private var userManager = UserManager.shared
    @State private var isShowingPaywall = false
    @State private var isLoadingPaywall = false
    @State private var paywallConfiguration: AdaptyUI.PaywallConfiguration?
    @State private var paywallErrorMessage: String?

    func body(content: Content) -> some View {
        content
            .limitPopup(
                isPresented: $isPresented,
                kind: .limitReached,
                onUpgrade: {
                    Task {
                        await presentPaywall()
                    }
                }
            )
            .paywall(
                isPresented: $isShowingPaywall,
                fullScreen: true,
                paywallConfiguration: paywallConfiguration,
                didPerformAction: handlePaywallAction,
                didFinishPurchase: handlePurchase,
                didFailPurchase: handlePurchaseFailure,
                didFinishRestore: handleRestore,
                didFailRestore: handleRestoreFailure,
                didFailRendering: handleRenderingFailure
            )
            .alert(
                "Paywall",
                isPresented: Binding(
                    get: { paywallErrorMessage != nil },
                    set: { if !$0 { paywallErrorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(paywallErrorMessage ?? "")
            }
    }

    private func presentPaywall() async {
        guard !isLoadingPaywall else { return }

        isLoadingPaywall = true
        defer { isLoadingPaywall = false }

        do {
            paywallConfiguration = try await AdaptyPurchaseService.shared.loadSDKPaywallConfiguration(placement: placement)
            isShowingPaywall = true
        } catch {
            paywallErrorMessage = error.localizedDescription
        }
    }

    private func handlePaywallAction(_ action: AdaptyUI.Action) {
        switch action {
        case .close:
            isShowingPaywall = false
        case let .openURL(url, _):
            UIApplication.shared.open(url)
        case let .custom(id):
            AppLogger.logAction("Adapty Paywall Custom Action", details: id)
        }
    }

    private func handlePurchase(_ product: AdaptyPaywallProduct, result: AdaptyPurchaseResult) {
        guard !result.isPurchaseCancelled else { return }
        AppLogger.logAction("Adapty Paywall Purchase Completed", details: product.vendorProductId)
        isShowingPaywall = false
        Task {
            await userManager.refreshPremiumStatus()
        }
    }

    private func handlePurchaseFailure(_ product: AdaptyPaywallProduct, error: AdaptyError) {
        AppLogger.logAction("Adapty Paywall Purchase Failed", details: "\(product.vendorProductId): \(error.localizedDescription)")
        paywallErrorMessage = error.localizedDescription
    }

    private func handleRestore(_ profile: AdaptyProfile) {
        AppLogger.logAction("Adapty Paywall Restore Completed")
        userManager.setPremiumStatus(AdaptyPurchaseService.shared.hasPremiumAccess(profile))
    }

    private func handleRestoreFailure(_ error: AdaptyError) {
        AppLogger.logAction("Adapty Paywall Restore Failed", details: error.localizedDescription)
        paywallErrorMessage = error.localizedDescription
    }

    private func handleRenderingFailure(_ error: AdaptyUIError) {
        AppLogger.logAction("Adapty Paywall Rendering Failed", details: error.localizedDescription)
        paywallErrorMessage = error.localizedDescription
        isShowingPaywall = false
    }
}

extension View {
    func generationUsageLimit(
        isPresented: Binding<Bool>,
        placement: AdaptyPurchaseService.Placement = .limitToken
    ) -> some View {
        modifier(GenerationUsageLimitModifier(isPresented: isPresented, placement: placement))
    }
}
