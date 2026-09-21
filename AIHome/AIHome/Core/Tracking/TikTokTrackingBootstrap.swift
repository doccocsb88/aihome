import Foundation
import TikTokBusinessSDK

enum TikTokTrackingBootstrap {
    static func configure() {
        guard let accessToken = Bundle.main.object(forInfoDictionaryKey: "TikTokSDKAccessToken") as? String,
              !accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !accessToken.contains("$(") else {
            AppLogger.logAction("TikTok SDK Skipped", details: "SDK access token is not configured")
            return
        }

        guard let config = TikTokConfig(accessToken: accessToken,
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
