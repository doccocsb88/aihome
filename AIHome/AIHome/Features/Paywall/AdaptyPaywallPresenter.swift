import Adapty
import AdaptyUI
import StoreKit
import SwiftUI

struct AdaptyPaywallPresenter<Content: View>: View {
    var placement: AdaptyPurchaseService.Placement = .proButton
    var onClose: (() -> Void)?
    var onLoadFailure: (() -> Void)?
    var onRenderingFailure: (() -> Void)?
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
                onLoadFailure: onLoadFailure,
                onRenderingFailure: onRenderingFailure,
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
    var onLoadFailure: (() -> Void)?
    var onRenderingFailure: (() -> Void)?
    var onPurchaseCompleted: (() -> Void)?
    var onRestoreCompleted: (() -> Void)?

    @State private var userManager = UserManager.shared
    @State private var isLoadingPaywall = false
    @State private var isShowingPaywall = false
    @State private var flowConfiguration: AdaptyUI.FlowConfiguration?
    @State private var paywallErrorMessage: String?

    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { _, shouldPresent in
                guard shouldPresent else { return }
                Task {
                    await presentPaywall()
                }
            }
            .flow(
                isPresented: $isShowingPaywall,
                fullScreen: true,
                flowConfiguration: flowConfiguration,
                didPerformAction: handlePaywallAction,
                didFinishPurchase: handlePurchase,
                didFailPurchase: handlePurchaseFailure,
                didFinishRestore: handleRestore,
                didFailRestore: handleRestoreFailure,
                didReceiveError: handleRenderingFailure
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
            flowConfiguration = try await AdaptyPurchaseService.shared.loadSDKFlowConfiguration(placement: placement)
            isShowingPaywall = true
            TrackingManager.shared.trackPaywallShown(placement: .init(placement: placement))
        } catch {
            isPresented = false
            AppLogger.logError("Failed to load Adapty flow: \(placement.rawValue)", error: error)
            if let onLoadFailure {
                onLoadFailure()
            } else {
                paywallErrorMessage = error.localizedDescription
            }
        }
    }

    private func handlePaywallAction(_ action: AdaptyUI.Action) {
        switch action {
        case .close:
            TrackingManager.shared.trackPaywallDismiss(placement: .init(placement: placement), method: .close)
            PaywallExposureTracker.recordDismiss()
            AdsManager.shared.handlePaywallExposureUpdated()
            dismissPaywall()
            onClose?()
        case let .openURL(url, _):
            UIApplication.shared.open(url)
        case let .custom(id):
            AppLogger.logAction("Adapty Paywall Custom Action", details: "\(placement.rawValue): \(id)")
        }
    }

    private func handlePurchase(_ product: AdaptyPaywallProduct, result: AdaptyPurchaseResult) {
        guard result.isPurchaseSuccess else { return }

        AppLogger.logAction("Adapty Paywall Purchase Completed", details: "\(placement.rawValue): \(product.vendorProductId)")
        PurchaseTrackingCoordinator.trackPurchase(
            product: product,
            eventId: result.transaction.map { String($0.id) }
        )

        PaywallExposureTracker.recordDismiss()
        AdsManager.shared.handlePaywallExposureUpdated()
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
            PaywallExposureTracker.recordDismiss()
            AdsManager.shared.handlePaywallExposureUpdated()
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
        dismissPaywall()
        if let onRenderingFailure {
            onRenderingFailure()
        } else {
            paywallErrorMessage = error.localizedDescription
        }
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
        onLoadFailure: (() -> Void)? = nil,
        onRenderingFailure: (() -> Void)? = nil,
        onPurchaseCompleted: (() -> Void)? = nil,
        onRestoreCompleted: (() -> Void)? = nil
    ) -> some View {
        modifier(
            AdaptyPaywallPresentationModifier(
                isPresented: isPresented,
                isLoading: isLoading,
                placement: placement,
                onClose: onClose,
                onLoadFailure: onLoadFailure,
                onRenderingFailure: onRenderingFailure,
                onPurchaseCompleted: onPurchaseCompleted,
                onRestoreCompleted: onRestoreCompleted
            )
        )
    }
}
