import Adapty
import SwiftUI

struct DemoPaywall: View {
    var onClose: () -> Void = {}
    var onPurchaseCompleted: () -> Void = {}
    var onTerms: () -> Void = {}
    var onPrivacy: () -> Void = {}
    var onRestore: () -> Void = {}

    @State private var products: [AdaptyPaywallProduct] = []
    @State private var selectedProductIndex = 0
    @State private var isLoadingProducts = false
    @State private var isPurchasing = false
    @State private var statusMessage: String?

    private let backgroundColor = Color(red: 0.89, green: 0.86, blue: 0.79)
    private let primaryTextColor = Color(red: 0.04, green: 0.04, blue: 0.04)
    private let secondaryTextColor = Color(red: 0.50, green: 0.48, blue: 0.44)
    private let buttonColor = Color(red: 0.20, green: 0.20, blue: 0.20)

    private var selectedProduct: AdaptyPaywallProduct? {
        guard products.indices.contains(selectedProductIndex) else { return nil }
        return products[selectedProductIndex]
    }

    var body: some View {
        paywallCard
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor.ignoresSafeArea())
            .task {
                await loadProducts()
            }
            .alert(
                "Paywall",
                isPresented: Binding(
                    get: { statusMessage != nil },
                    set: { if !$0 { statusMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(statusMessage ?? "")
            }
    }

    private var paywallCard: some View {
        VStack(spacing: 0) {
            topControls

            Image("demo_paywall_halloween_art")
                .resizable()
                .scaledToFit()
                .frame(height: 274)
                .padding(.top, -2)
                .padding(.horizontal, 42)
                .accessibilityHidden(true)

            Text("No Tricks, Just Treats")
                .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 29))
                .foregroundStyle(primaryTextColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .padding(.top, 10)
                .padding(.horizontal, 22)

            Text("Get a discount before it vanishes!")
                .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 21))
                .foregroundStyle(primaryTextColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.84)
                .padding(.top, 8)
                .padding(.horizontal, 22)

            Rectangle()
                .fill(secondaryTextColor.opacity(0.32))
                .frame(width: 74, height: 1)
                .padding(.top, 18)

            Text("SPECIAL LIMITED TIME OFFER")
                .font(FontFamily.Inter24pt.medium.swiftUIFont(size: 12))
                .foregroundStyle(secondaryTextColor)
                .tracking(0.2)
                .padding(.top, 25)

            Text("13:59:59")
                .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 38))
                .foregroundStyle(buttonColor)
                .monospacedDigit()
                .padding(.top, 8)

            if isLoadingProducts {
                ProgressView()
                    .controlSize(.large)
                    .frame(height: 132)
                    .padding(.top, 20)
            } else {
                productPicker
                    .padding(.top, 20)
            }

            Button {
                Task {
                    await purchaseSelectedProduct()
                }
            } label: {
                HStack(spacing: 10) {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    }

                    Text(isPurchasing ? "Purchasing..." : "Continue")
                        .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 18))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background((selectedProduct == nil || isPurchasing) ? buttonColor.opacity(0.48) : buttonColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(selectedProduct == nil || isPurchasing)
            .padding(.horizontal, 16)
            .padding(.top, 40)

            footerActions
                .padding(.top, 22)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }

    private var topControls: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Color.black.opacity(0.25), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")

            Spacer()
        }
        .padding(.top, 69)
        .padding(.horizontal, 25)
    }

    private var productPicker: some View {
        HStack(spacing: 10) {
            ForEach(Array(products.enumerated()), id: \.offset) { index, product in
                productCard(product, index: index)
            }
        }
        .padding(.horizontal, 16)
    }

    private func productCard(_ product: AdaptyPaywallProduct, index: Int) -> some View {
        Button {
            selectedProductIndex = index
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(productTitle(for: product))
                    .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 17))
                    .foregroundStyle(primaryTextColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 30)

                Text(product.localizedPrice ?? "")
                    .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 17))
                    .foregroundStyle(primaryTextColor)

                Text(productDetail(for: product))
                    .font(FontFamily.Inter24pt.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Color(red: 0.58, green: 0.56, blue: 0.53))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.top, 5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 104)
            .padding(.horizontal, 17)
            .padding(.vertical, 14)
            .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(alignment: .topLeading) {
                if index == 0 {
                    Text("Halloween Offer")
                        .font(FontFamily.Inter24pt.bold.swiftUIFont(size: 14))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .frame(height: 23)
                        .background(buttonColor, in: Capsule())
                        .offset(x: 26, y: -12)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(selectedProductIndex == index ? primaryTextColor : primaryTextColor.opacity(0.78), lineWidth: selectedProductIndex == index ? 2 : 1.4)
            }
        }
        .buttonStyle(.plain)
    }

    private var footerActions: some View {
        HStack(spacing: 0) {
            footerButton("Terms", action: onTerms)

            separator

            footerButton("Privacy", action: onPrivacy)

            separator

            footerButton("Restore", action: onRestore)
        }
        .padding(.horizontal, 34)
    }

    private func footerButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(FontFamily.Inter24pt.regular.swiftUIFont(size: 16))
                .foregroundStyle(primaryTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: 24)
        }
        .buttonStyle(.plain)
    }

    private var separator: some View {
        Rectangle()
            .fill(secondaryTextColor.opacity(0.22))
            .frame(width: 1, height: 24)
    }

    private func loadProducts() async {
        guard products.isEmpty, !isLoadingProducts else { return }

        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            products = try await AdaptyPurchaseService.shared.loadPaywallProducts()
            selectedProductIndex = 0
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func purchaseSelectedProduct() async {
        guard let selectedProduct else { return }

        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await AdaptyPurchaseService.shared.makePurchase(product: selectedProduct)
            switch result {
            case .active:
                onPurchaseCompleted()
            case .pending:
                statusMessage = "Purchase is pending approval."
            case .cancelled:
                break
            case .inactive:
                statusMessage = "Purchase completed, but Pro access is not active yet."
            }
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func productTitle(for product: AdaptyPaywallProduct) -> String {
        guard !product.localizedTitle.isEmpty else {
            return product.vendorProductId
        }

        return product.localizedTitle
    }

    private func productDetail(for product: AdaptyPaywallProduct) -> String {
        guard let period = product.localizedSubscriptionPeriod, !period.isEmpty else {
            return ""
        }

        if let price = product.localizedPrice, !price.isEmpty {
            return "\(price)/\(period)"
        }

        return period
    }
}

#Preview {
    DemoPaywall()
}
