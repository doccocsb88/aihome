import Adapty
import AdaptyUI
import SwiftUI

struct MainTabHeaderView: View {
    let title: String
    var placement: AdaptyPurchaseService.Placement = .proButton
    var generationText = "3/3"
    var titleSize: CGFloat = 36

    @State private var isShowingPaywall = false
    @State private var isLoadingPaywall = false
    @State private var paywallConfiguration: AdaptyUI.PaywallConfiguration?
    @State private var paywallErrorMessage: String?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: titleSize))
                .foregroundStyle(Color.DesignSystem.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                generationPill
                proButton
            }
        }
        .padding(.horizontal, 16)
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

    private var generationPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.DesignSystem.folly)

            Text(generationText)
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 15))
                .foregroundStyle(Color.DesignSystem.textPrimary)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(Color.DesignSystem.ghostWhite, in: Capsule())
    }

    private var proButton: some View {
        Button {
            Task {
                await presentPaywall()
            }
        } label: {
            HStack(spacing: 6) {
                if isLoadingPaywall {
                    ProgressView()
                        .tint(.white)
                }

                Text("PRO")
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 15))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(height: 34)
            .background(Color.DesignSystem.folly, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isLoadingPaywall)
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
    }

    private func handlePurchaseFailure(_ product: AdaptyPaywallProduct, error: AdaptyError) {
        AppLogger.logAction("Adapty Paywall Purchase Failed", details: "\(product.vendorProductId): \(error.localizedDescription)")
        paywallErrorMessage = error.localizedDescription
    }

    private func handleRestore(_ profile: AdaptyProfile) {
        AppLogger.logAction("Adapty Paywall Restore Completed")
        UserDefaults.standard.set(profile.accessLevels["premium"]?.isActive ?? false, forKey: "isProCached")
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
