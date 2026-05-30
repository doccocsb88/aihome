import Foundation

public enum AppLogger {
    public static func logScreen(_ screenName: String) {
        print("📱 [SCREEN] Navigated to: \(screenName)")
    }
    
    public static func logAction(_ actionName: String, details: String? = nil) {
        if let details = details {
            print("⚡️ [ACTION] \(actionName) - \(details)")
        } else {
            print("⚡️ [ACTION] \(actionName)")
        }
    }
    
    public static func logError(_ errorName: String, error: Error? = nil) {
        if let error = error {
            print("❌ [ERROR] \(errorName): \(error.localizedDescription)")
        } else {
            print("❌ [ERROR] \(errorName)")
        }
    }
}
