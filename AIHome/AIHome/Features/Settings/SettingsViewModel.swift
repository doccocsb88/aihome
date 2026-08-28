import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var providerKind: HomeGPTProviderKind {
        didSet {
            guard providerKind != oldValue else { return }
            HomeGPTProviderRegistry.use(providerKind)
        }
    }

    var selectedLanguage: String {
        LanguageManager.shared.selectedLanguage
    }
    var isRestoringPurchase: Bool = false
    var purchaseMessage: String?

    init() {
        providerKind = HomeGPTProviderRegistry.selectedKind
    }

    var providerTitle: String {
        providerKind.displayName
    }

    var remoteProviderTitle: String {
        RemoteConfigManager.shared.homeGPTProviderKind.displayName
    }

    var isUsingLocalProviderOverride: Bool {
        HomeGPTProviderRegistry.hasLocalOverride
    }

    var canShowProviderMenu: Bool {
        !AppEnvironmentService.shared.isAppStore
    }

    var usesHomeAIBackend: Bool {
        providerKind == .homeAIBackend
    }

    func setUsesHomeAIBackend(_ enabled: Bool) {
        let newKind: HomeGPTProviderKind = enabled ? .homeAIBackend : .legacyHomeDesigns
        guard newKind != providerKind else { return }
        providerKind = newKind
    }

    func selectProvider(_ kind: HomeGPTProviderKind) {
        guard providerKind != kind else { return }
        providerKind = kind
    }

    func followRemoteDefault() {
        HomeGPTProviderRegistry.clearLocalOverride()
        providerKind = HomeGPTProviderRegistry.selectedKind
    }

    func syncProviderFromRemoteDefault() {
        guard !HomeGPTProviderRegistry.hasLocalOverride else { return }
        let remoteKind = RemoteConfigManager.shared.homeGPTProviderKind
        guard providerKind != remoteKind else { return }
        providerKind = remoteKind
    }
    
    func restorePurchase() async {
        guard !isRestoringPurchase else { return }

        isRestoringPurchase = true
        defer { isRestoringPurchase = false }

        do {
            let restored = try await AdaptyPurchaseService.shared.restorePurchases()
            purchaseMessage = restored ? "Purchase restored successfully." : "No active Pro purchase was found."
        } catch {
            purchaseMessage = error.localizedDescription
        }
    }
    
    func openPrivacyPolicy() {
        // Implement open URL
    }
    
    func openTermsOfService() {
        // Implement open URL
    }
    
    func sendFeedback() {
        // Implement feedback
    }

    func fetchAppCheckToken() async -> String? {
        await FirebaseAppCheckService.shared.token()
    }
}
