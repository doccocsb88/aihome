import Observation
import SwiftUI

enum FirstGenerationPaywallGate {
    private enum Keys {
        static let didHandleFirstGenerationPaywall = "paywall.firstGeneration.didHandle"
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }

    private static var isFirstOpenSession = false

    static func recordAppOpen(userDefaults: UserDefaults = .standard) {
        isFirstOpenSession = !userDefaults.bool(forKey: Keys.hasSeenOnboarding)
    }

    @MainActor
    static func consumePresentationIfNeeded(
        userDefaults: UserDefaults = .standard,
        userManager: UserManager = .shared
    ) -> Bool {
        guard isFirstOpenSession,
              userManager.isFreeUser,
              !userDefaults.bool(forKey: Keys.didHandleFirstGenerationPaywall) else {
            return false
        }

        userDefaults.set(true, forKey: Keys.didHandleFirstGenerationPaywall)
        AppLogger.logAction("First generation paywall gate consumed")
        return true
    }
}

@MainActor
@Observable
final class GenerationAccessCoordinator {
    var isShowingFirstGenerationPaywall = false
    @ObservationIgnored private var pendingFirstGeneration: (() -> Void)?

    func requestGeneration(_ generation: @escaping () -> Void) {
        guard !FirstGenerationPaywallGate.consumePresentationIfNeeded() else {
            pendingFirstGeneration = generation
            isShowingFirstGenerationPaywall = true
            return
        }

        AdsManager.shared.showRewardedGenerateIfNeeded {
            generation()
        }
    }

    func continueAfterFirstGenerationPaywall() {
        guard let generation = pendingFirstGeneration else { return }
        pendingFirstGeneration = nil
        generation()
    }
}

private struct FirstGenerationPaywallModifier: ViewModifier {
    @Bindable var coordinator: GenerationAccessCoordinator

    func body(content: Content) -> some View {
        content.adaptyPaywall(
            isPresented: $coordinator.isShowingFirstGenerationPaywall,
            placement: .firstGeneration,
            onClose: coordinator.continueAfterFirstGenerationPaywall,
            onLoadFailure: coordinator.continueAfterFirstGenerationPaywall,
            onRenderingFailure: coordinator.continueAfterFirstGenerationPaywall,
            onPurchaseCompleted: coordinator.continueAfterFirstGenerationPaywall,
            onRestoreCompleted: coordinator.continueAfterFirstGenerationPaywall
        )
    }
}

extension View {
    func firstGenerationPaywall(coordinator: GenerationAccessCoordinator) -> some View {
        modifier(FirstGenerationPaywallModifier(coordinator: coordinator))
    }
}
