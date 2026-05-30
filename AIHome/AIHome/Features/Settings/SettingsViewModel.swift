import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var selectedLanguage: String = "ENGLISH"
    
    func restorePurchase() {
        // Implement restore logic
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
