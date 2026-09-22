import Foundation
import TikTokBusinessSDK

enum TikTokTrackingBootstrap {
    static func configure() {
        guard let appSecret = Bundle.main.object(forInfoDictionaryKey: "TikTokAppSecret") as? String,
              !appSecret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !appSecret.contains("$(") else {
            AppLogger.logAction("TikTok SDK Skipped", details: "App Secret is not configured")
            return
        }

        // The iOS SDK names its App Secret parameter accessToken.
        guard let config = TikTokConfig(accessToken: appSecret,
                                       appId: "6777677408",
                                       tiktokAppId: "7687883863927701522") else {
            AppLogger.logError("Invalid TikTok SDK configuration")
            return
        }

        // Adapty owns purchase reporting; TikTok should only collect its other automatic events.
        config.disablePaymentTracking()
        TikTokBusiness.initializeSdk(config) { success, error in
            if success {
                AppLogger.logAction("TikTok SDK Initialized")
            } else {
                AppLogger.logError("TikTok SDK Initialization Failed", error: error)
            }
        }
    }
}
