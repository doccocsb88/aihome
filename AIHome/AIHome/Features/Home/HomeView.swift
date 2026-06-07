import Adapty
import AdaptyUI
import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var isShowingHomeRating = false
    @State private var hasShownHomeRating = false
    @State private var isShowingAdaptyPaywall = false
    @State private var isLoadingAdaptyPaywall = false
    @State private var adaptyPaywallConfiguration: AdaptyUI.PaywallConfiguration?
    @State private var paywallErrorMessage: String?
#if DEBUG || DEBUB
    @State private var isShowingPhotoTips = false
#endif
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                HStack {
                    Text("Home")
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 36))
                        .foregroundColor(.DesignSystem.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.DesignSystem.folly)
                            Text("3/3")
                                .font(FontFamily.Roboto.medium.swiftUIFont(size: 15))
                                .foregroundColor(.DesignSystem.textPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.DesignSystem.ghostWhite)
                        .cornerRadius(20)
                        
                        Button {
                            Task {
                                await presentAdaptyPaywall()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if isLoadingAdaptyPaywall {
                                    ProgressView()
                                        .tint(.white)
                                }

                                Text("PRO")
                                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 15))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.DesignSystem.folly)
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoadingAdaptyPaywall)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.primaryTools) { tool in
                        HomeToolRow(tool: tool) {
                            handleNavigation(for: tool)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("ADVANCED EDITING")
                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                        .foregroundColor(.DesignSystem.silverSand)
                        .kerning(1.2)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    ForEach(viewModel.advancedTools) { tool in
                        HomeToolRow(tool: tool) {
                            handleNavigation(for: tool)
                        }
                    }
                }
                
            }
            .padding(.vertical)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .ratingPopup(isPresented: $isShowingHomeRating, kind: .homeEnjoyment) {
            AppLogger.logAction("Home Rating", details: "Rate on App Store")
        }
        .paywall(
            isPresented: $isShowingAdaptyPaywall,
            fullScreen: true,
            paywallConfiguration: adaptyPaywallConfiguration,
            didPerformAction: handleAdaptyPaywallAction,
            didFinishPurchase: handleAdaptyPurchase,
            didFailPurchase: handleAdaptyPurchaseFailure,
            didFinishRestore: handleAdaptyRestore,
            didFailRestore: handleAdaptyRestoreFailure,
            didFailRendering: handleAdaptyRenderingFailure
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
        .onAppear {
            AppLogger.logScreen("HomeView")
            presentHomeRatingIfNeeded()
#if DEBUG || DEBUB
            isShowingPhotoTips = true
#endif
        }
#if DEBUG || DEBUB
        .sheet(isPresented: $isShowingPhotoTips) {
            PhotoTipsView()
        }
#endif
    }
    
    private func handleNavigation(for tool: HomeToolItem) {
        switch tool.projectType {
        case .interior: coordinator.push(.interiorFlow)
        case .exterior: coordinator.push(.exteriorFlow)
        case .garden: coordinator.push(.gardenFlow)
        case .referenceStyle: coordinator.push(.referenceStyleFlow)
        case .removeObjects: coordinator.push(.removeObjectsFlow)
        case .replaceObjects: coordinator.push(.replaceObjectsFlow)
        case .newFlooring: coordinator.push(.newFlooringFlow)
        case .newWalls: coordinator.push(.newWallsFlow)
        }
    }

    private func presentHomeRatingIfNeeded() {
        guard !hasShownHomeRating else { return }
        hasShownHomeRating = true
        isShowingHomeRating = true
    }

    private func presentAdaptyPaywall() async {
        guard !isLoadingAdaptyPaywall else { return }

        isLoadingAdaptyPaywall = true
        defer { isLoadingAdaptyPaywall = false }

        do {
            adaptyPaywallConfiguration = try await AdaptyPurchaseService.shared.loadSDKPaywallConfiguration()
            isShowingAdaptyPaywall = true
        } catch {
            paywallErrorMessage = error.localizedDescription
        }
    }

    private func handleAdaptyPaywallAction(_ action: AdaptyUI.Action) {
        switch action {
        case .close:
            isShowingAdaptyPaywall = false
        case let .openURL(url, _):
            UIApplication.shared.open(url)
        case let .custom(id):
            AppLogger.logAction("Adapty Paywall Custom Action", details: id)
        }
    }

    private func handleAdaptyPurchase(_ product: AdaptyPaywallProduct, result: AdaptyPurchaseResult) {
        guard !result.isPurchaseCancelled else { return }
        AppLogger.logAction("Adapty Paywall Purchase Completed", details: product.vendorProductId)
        isShowingAdaptyPaywall = false
    }

    private func handleAdaptyPurchaseFailure(_ product: AdaptyPaywallProduct, error: AdaptyError) {
        AppLogger.logAction("Adapty Paywall Purchase Failed", details: "\(product.vendorProductId): \(error.localizedDescription)")
        paywallErrorMessage = error.localizedDescription
    }

    private func handleAdaptyRestore(_ profile: AdaptyProfile) {
        AppLogger.logAction("Adapty Paywall Restore Completed")
        UserDefaults.standard.set(profile.accessLevels["premium"]?.isActive ?? false, forKey: "isProCached")
    }

    private func handleAdaptyRestoreFailure(_ error: AdaptyError) {
        AppLogger.logAction("Adapty Paywall Restore Failed", details: error.localizedDescription)
        paywallErrorMessage = error.localizedDescription
    }

    private func handleAdaptyRenderingFailure(_ error: AdaptyUIError) {
        AppLogger.logAction("Adapty Paywall Rendering Failed", details: error.localizedDescription)
        paywallErrorMessage = error.localizedDescription
        isShowingAdaptyPaywall = false
    }
}

struct HomeToolRow: View {
    let tool: HomeToolItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(tool.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.85)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Image(systemName: tool.iconName)
                                        .font(.headline)
                                    Text(tool.title)
                                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
                                }
                                .foregroundColor(.white)
                                
                                Text(tool.subtitle)
                                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(20)
                    }
                )
                .cornerRadius(24)
                .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environment(AppCoordinator())
}
