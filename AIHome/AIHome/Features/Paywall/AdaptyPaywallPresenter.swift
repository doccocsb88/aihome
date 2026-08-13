import Adapty
import AdaptyUI
import SwiftUI

struct AdaptyPaywallPresenter<Content: View>: View {
    var placement: AdaptyPurchaseService.Placement = .proButton
    var onClose: (() -> Void)?
    var onPurchaseCompleted: (() -> Void)?
    var onRestoreCompleted: (() -> Void)?
    @ViewBuilder var content: (_ present: @escaping () -> Void, _ isLoading: Bool) -> Content

    @State private var isPresented = false
    @State private var isLoading = false

    var body: some View {
        content(present, isLoading)
            .adaptyPaywall(
                isPresented: $isPresented,
                isLoading: $isLoading,
                placement: placement,
                onClose: onClose,
                onPurchaseCompleted: onPurchaseCompleted,
                onRestoreCompleted: onRestoreCompleted
            )
    }

    private func present() {
        isPresented = true
    }
}

private struct AdaptyPaywallPresentationModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var isLoading: Bool

    var placement: AdaptyPurchaseService.Placement
    var onClose: (() -> Void)?
    var onPurchaseCompleted: (() -> Void)?
    var onRestoreCompleted: (() -> Void)?

    @State private var userManager = UserManager.shared
    @State private var isLoadingPaywall = false
    @State private var isShowingPaywall = false
    @State private var paywallConfiguration: AdaptyUI.PaywallConfiguration?
    @State private var paywallErrorMessage: String?

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, shouldPresent in
                guard shouldPresent else { return }
                Task {
                    await presentPaywall()
                }
            }
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
        isLoading = true
        defer {
            isLoadingPaywall = false
            isLoading = false
        }

        do {
            paywallConfiguration = try await AdaptyPurchaseService.shared.loadSDKPaywallConfiguration(placement: placement)
            isShowingPaywall = true
            TrackingManager.shared.trackPaywallShown(placement: .init(placement: placement))
        } catch {
            paywallErrorMessage = error.localizedDescription
            isPresented = false
        }
    }

    private func handlePaywallAction(_ action: AdaptyUI.Action) {
        switch action {
        case .close:
            TrackingManager.shared.trackPaywallDismiss(placement: .init(placement: placement), method: .close)
            dismissPaywall()
            onClose?()
        case let .openURL(url, _):
            UIApplication.shared.open(url)
        case let .custom(id):
            AppLogger.logAction("Adapty Paywall Custom Action", details: "\(placement.rawValue): \(id)")
        }
    }

    private func handlePurchase(_ product: AdaptyPaywallProduct, result: AdaptyPurchaseResult) {
        guard !result.isPurchaseCancelled else { return }

        AppLogger.logAction("Adapty Paywall Purchase Completed", details: "\(placement.rawValue): \(product.vendorProductId)")

        if case let .success(profile, _) = result,
           AdaptyPurchaseService.shared.hasPremiumAccess(profile) {
            TrackingManager.shared.trackMetaPurchase(product: product, placement: .init(placement: placement))
        }

        dismissPaywall()

        Task {
            await userManager.refreshPremiumStatus()
            onPurchaseCompleted?()
        }
    }

    private func handlePurchaseFailure(_ product: AdaptyPaywallProduct, error: AdaptyError) {
        AppLogger.logAction("Adapty Paywall Purchase Failed", details: "\(placement.rawValue): \(product.vendorProductId): \(error.localizedDescription)")
        paywallErrorMessage = error.localizedDescription
    }

    private func handleRestore(_ profile: AdaptyProfile) {
        AppLogger.logAction("Adapty Paywall Restore Completed", details: placement.rawValue)
        userManager.setPremiumStatus(AdaptyPurchaseService.shared.hasPremiumAccess(profile))

        if let onRestoreCompleted {
            dismissPaywall()
            onRestoreCompleted()
        }
    }

    private func handleRestoreFailure(_ error: AdaptyError) {
        AppLogger.logAction("Adapty Paywall Restore Failed", details: "\(placement.rawValue): \(error.localizedDescription)")
        paywallErrorMessage = error.localizedDescription
    }

    private func handleRenderingFailure(_ error: AdaptyUIError) {
        AppLogger.logAction("Adapty Paywall Rendering Failed", details: "\(placement.rawValue): \(error.localizedDescription)")
        paywallErrorMessage = error.localizedDescription
        dismissPaywall()
    }

    private func dismissPaywall() {
        isShowingPaywall = false
        isPresented = false
    }
}

extension View {
    func adaptyPaywall(
        isPresented: Binding<Bool>,
        isLoading: Binding<Bool> = .constant(false),
        placement: AdaptyPurchaseService.Placement,
        onClose: (() -> Void)? = nil,
        onPurchaseCompleted: (() -> Void)? = nil,
        onRestoreCompleted: (() -> Void)? = nil
    ) -> some View {
        modifier(
            AdaptyPaywallPresentationModifier(
                isPresented: isPresented,
                isLoading: isLoading,
                placement: placement,
                onClose: onClose,
                onPurchaseCompleted: onPurchaseCompleted,
                onRestoreCompleted: onRestoreCompleted
            )
        )
    }
}
