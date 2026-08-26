import SwiftUI

struct MainTabHeaderView: View {
    let title: String
    var placement: AdaptyPurchaseService.Placement = .proButton
    var generationText: String?
    var titleSize: CGFloat = 36

    @State private var userManager = UserManager.shared

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: titleSize))
                .foregroundStyle(Color.DesignSystem.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                if userManager.isFreeUser {
                    generationPill
                    proButton
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var generationPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.DesignSystem.folly)

            Text(generationDisplayText)
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 15))
                .foregroundStyle(Color.DesignSystem.textPrimary)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(Color.DesignSystem.ghostWhite, in: Capsule())
    }

    private var proButton: some View {
        AdaptyPaywallButton(placement: placement, onClose: {
            AdsManager.shared.showInterstitialCloseIap {}
        }) { isLoading in
            HStack(spacing: 6) {
                if isLoading {
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
    }

    private var generationDisplayText: String {
        return generationText ?? userManager.usageProgressText
    }
}

struct AdaptyPaywallButton<Label: View>: View {
    var placement: AdaptyPurchaseService.Placement = .proButton
    var onClose: () -> Void = {}
    @ViewBuilder var label: (_ isLoading: Bool) -> Label

    var body: some View {
        AdaptyPaywallPresenter(placement: placement, onClose: onClose) { present, isLoading in
            Button(action: present) {
                label(isLoading)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
    }
}
