import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var selectedLanguage: String = "ENGLISH"
    var isRestoringPurchase: Bool = false
    var purchaseMessage: String?
    
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
}
