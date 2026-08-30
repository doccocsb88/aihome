import FacebookCore
import FirebaseAnalytics
import Foundation

@MainActor
final class TrackingManager {
    static let shared = TrackingManager()

    enum Screen: String {
        case splash = "screen_splash"
        case welcome = "screen_welcome"
        case onboarding1 = "screen_onboarding_1"
        case onboarding2 = "screen_onboarding_2"
        case onboarding3 = "screen_onboarding_3"
        case paywall = "screen_paywall"
        case trialEnabled = "screen_trial_enabled"
        case home = "screen_home"
        case inspiration = "screen_inspiration"
        case inspirationDetail = "screen_inspiration_detail"
        case history = "screen_history"
        case settings = "screen_settings"
        case language = "screen_language"
        case photoPicker = "screen_photo_picker"
        case roomType = "screen_room_type"
        case stylePicker = "screen_style_picker"
        case customStyle = "screen_custom_style"
        case aiIntervention = "screen_ai_intervention"
        case generating = "screen_generating"
        case result = "screen_result"
        case resultRating = "screen_result_rating"
        case limitPopup = "screen_limit_popup"
    }

    enum Feature: String {
        case interior
        case exterior
        case garden
        case referenceStyle = "reference_style"
        case removeObject = "remove_object"
        case replaceObject = "replace_object"
        case newFlooring = "new_flooring"
        case newWall = "new_wall"
    }

    enum PhotoSource: String {
        case gallery
        case camera
        case sample
    }

    enum RateTrigger: String {
        case homeBanner = "home_banner"
        case resultRating = "result_rating"
    }

    enum GenerationTrigger: String {
        case new
        case regenerate
    }

    enum PaywallPlacement: String {
        case onboarding = "onboarding"
        case bannerSettings = "banner_settings"
        case proButton = "pro_button"
        case watermark
        case session
        case limitToken = "limit_token"
    }

    enum PaywallDismissMethod: String {
        case close
        case swipe
    }

    enum HistoryState: String {
        case list
        case empty
    }

    enum GenerationErrorType: String {
        case apiError = "api_error"
        case timeout
        case moderation
        case noCredit = "no_credit"
        case network
        case invalidInput = "invalid_input"
        case server5xx = "server_5xx"
        case unknown
    }

    enum ATTStatus: String {
        case authorized
        case denied
        case restricted
        case notDetermined = "not_determined"
    }

    enum TrialScreenAction: String {
        case `continue`
        case skip
        case back
    }

    private init() {}

    func trackScreen(_ screen: Screen, params: [String: Any?] = [:]) {
        log(name: screen.rawValue, params: params)
    }

    func trackSelectFeature(feature: Feature, screen: Screen) {
        log(
            name: "select_feature",
            params: [
                "screen_name": screen.rawValue,
                "feature": feature.rawValue
            ]
        )
    }

    func trackSelectPhoto(source: PhotoSource, feature: Feature) {
        log(
            name: "select_photo",
            params: [
                "screen_name": Screen.photoPicker.rawValue,
                "source": source.rawValue,
                "feature": feature.rawValue
            ]
        )
    }

    func trackRoomTypeScreen(feature: Feature) {
        trackScreen(.roomType, params: ["feature": feature.rawValue])
    }

    func trackStylePickerScreen(feature: Feature) {
        trackScreen(.stylePicker, params: ["feature": feature.rawValue])
    }

    func trackCustomStyleScreen(feature: Feature) {
        trackScreen(.customStyle, params: ["feature": feature.rawValue])
    }

    func trackAIInterventionScreen(feature: Feature) {
        trackScreen(.aiIntervention, params: ["feature": feature.rawValue])
    }

    func trackSaveResult(feature: Feature) {
        log(name: "save_result", params: ["screen_name": Screen.result.rawValue, "feature": feature.rawValue])
    }

    func trackSaveArchive(feature: Feature) {
        log(name: "save_archive", params: ["screen_name": Screen.result.rawValue, "feature": feature.rawValue])
    }

    func trackShareResult(feature: Feature) {
        log(name: "share_result", params: ["screen_name": Screen.result.rawValue, "feature": feature.rawValue])
    }

    func trackCreateProject() {
        log(name: "create_project", params: ["screen_name": Screen.history.rawValue])
    }

    func trackRateApp(screen: Screen, trigger: RateTrigger) {
        log(name: "rate_app", params: ["screen_name": screen.rawValue, "trigger": trigger.rawValue])
    }

    func trackRestorePurchase() {
        log(name: "restore_purchase", params: ["screen_name": Screen.settings.rawValue])
    }

    func trackSendFeedback() {
        log(name: "send_feedback", params: ["screen_name": Screen.settings.rawValue])
    }

    func trackChangeLanguage(languageCode: String) {
        let isoCode = languageCode.split(separator: "-").first.map(String.init) ?? languageCode
        log(
            name: "change_language",
            params: [
                "screen_name": Screen.language.rawValue,
                "language": isoCode
            ]
        )
    }

    func trackGenerationStart(
        feature: Feature,
        screen: Screen,
        roomType: String? = nil,
        style: String? = nil,
        aiIntervention: String? = nil,
        trigger: GenerationTrigger
    ) {
        log(
            name: "generation_start",
            params: [
                "screen_name": screen.rawValue,
                "feature": feature.rawValue,
                "room_type": roomType,
                "style": style,
                "ai_intervention": aiIntervention,
                "trigger": trigger.rawValue
            ]
        )
    }

    func trackGenerationSuccess(feature: Feature, style: String? = nil, durationMs: Int) {
        log(
            name: "generation_success",
            params: [
                "feature": feature.rawValue,
                "style": style,
                "duration_ms": durationMs
            ]
        )
    }

    func trackGenerationFail(
        feature: Feature,
        errorType: GenerationErrorType,
        durationMs: Int,
        retryCount: Int = 0
    ) {
        log(
            name: "generation_fail",
            params: [
                "feature": feature.rawValue,
                "error_type": errorType.rawValue,
                "duration_ms": durationMs,
                "retry_count": retryCount
            ]
        )
    }

    func trackLimitPopup(remainingCredit: Int, feature: Feature) {
        trackScreen(
            .limitPopup,
            params: [
                "credit_remaining": remainingCredit,
                "trigger_feature": feature.rawValue
            ]
        )
    }

    func trackCreditConsumed(
        feature: Feature,
        creditBefore: Int,
        creditAfter: Int,
        isSubscriber: Bool
    ) {
        log(
            name: "credit_consumed",
            params: [
                "screen_name": Screen.generating.rawValue,
                "feature": feature.rawValue,
                "credit_before": creditBefore,
                "credit_after": creditAfter,
                "is_subscriber": isSubscriber
            ]
        )
    }

    func trackRewardEarned(
        placement: AdsPlacement,
        adUnitIdentifier: String,
        limitBefore: Int,
        limitAfter: Int,
        remainingBefore: Int,
        remainingAfter: Int,
        bonusBefore: Int,
        bonusAfter: Int
    ) {
        log(
            name: "reward_earned",
            params: [
                "placement": placement.rawValue,
                "ad_unit": adUnitIdentifier,
                "limit_before": limitBefore,
                "limit_after": limitAfter,
                "remaining_before": remainingBefore,
                "remaining_after": remainingAfter,
                "bonus_before": bonusBefore,
                "bonus_after": bonusAfter
            ]
        )
    }

    func trackATTPromptShown() {
        log(name: "att_prompt_shown", params: [:])
    }

    func trackATTResult(status: ATTStatus) {
        log(name: "att_result", params: ["status": status.rawValue])
    }

    func trackTrialEnabled(action: TrialScreenAction, timeOnScreenMs: Int) {
        trackScreen(
            .trialEnabled,
            params: [
                "action": action.rawValue,
                "time_on_screen_ms": timeOnScreenMs
            ]
        )
    }

    func trackPaywallShown(placement: PaywallPlacement, paywallID: String? = nil) {
        log(
            name: Screen.paywall.rawValue,
            params: [
                "placement": placement.rawValue,
                "paywall_id": paywallID
            ]
        )
    }

    func trackPaywallDismiss(placement: PaywallPlacement, method: PaywallDismissMethod) {
        log(
            name: "paywall_dismiss",
            params: [
                "screen_name": Screen.paywall.rawValue,
                "placement": placement.rawValue,
                "method": method.rawValue
            ]
        )
    }

    func trackMetaPurchase(
        productID: String,
        amount: Double,
        currency: String,
        source: String,
        transactionID: String,
        originalTransactionID: String
    ) {
        let currency = currency.trimmingCharacters(in: .whitespacesAndNewlines)

        guard amount > 0, !currency.isEmpty else {
            AppLogger.logError("Meta Purchase Event skipped: invalid value for \(productID)")
            return
        }

        AppEvents.shared.logPurchase(amount: amount, currency: currency)

        AppLogger.logAction(
            "Meta Purchase Event Logged",
            details: "\(productID) amount=\(amount) currency=\(currency) source=\(source) transaction_id=\(transactionID) original_transaction_id=\(originalTransactionID)"
        )
    }

    private func log(name: String, params: [String: Any?]) {
        Analytics.logEvent(name, parameters: sanitize(params))
    }

    private func sanitize(_ params: [String: Any?]) -> [String: Any] {
        var sanitized: [String: Any] = [:]
        for (key, value) in params {
            guard let value else { continue }
            if let stringValue = value as? String, !stringValue.isEmpty {
                sanitized[key] = stringValue
            } else if let numberValue = value as? NSNumber {
                sanitized[key] = numberValue
            } else if let intValue = value as? Int {
                sanitized[key] = intValue
            } else if let doubleValue = value as? Double {
                sanitized[key] = doubleValue
            } else if let boolValue = value as? Bool {
                sanitized[key] = boolValue
            }
        }
        return sanitized
    }
}

extension TrackingManager.Feature {
    init?(projectType: ProjectType) {
        switch projectType {
        case .interior:
            self = .interior
        case .exterior:
            self = .exterior
        case .garden:
            self = .garden
        case .referenceStyle:
            self = .referenceStyle
        case .replaceObjects:
            self = .replaceObject
        case .removeObjects:
            self = .removeObject
        case .newFlooring:
            self = .newFlooring
        case .newWalls:
            self = .newWall
        case .furnitureFinder, .edit:
            return nil
        }
    }
}

extension TrackingManager.GenerationErrorType {
    init(error: Error) {
        let nsError = error as NSError

        if let apiError = error as? HomeDesignsAPIError {
            switch apiError {
            case .invalidImage, .invalidURL, .invalidResponse:
                self = .invalidInput
            case .generationTimedOut:
                self = .timeout
            case .temporaryServerUnavailable, .server:
                self = .server5xx
            case .apiMessage, .underlying, .decodingFailed, .queueExpired, .unauthorized:
                self = .apiError
            }
            return
        }

        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorTimedOut:
                self = .timeout
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost, NSURLErrorCannotConnectToHost:
                self = .network
            default:
                self = .network
            }
            return
        }

        let lowercasedDescription = nsError.localizedDescription.lowercased()
        if lowercasedDescription.contains("moderation") {
            self = .moderation
        } else if lowercasedDescription.contains("credit") || lowercasedDescription.contains("limit") {
            self = .noCredit
        } else {
            self = .unknown
        }
    }
}

extension TrackingManager.PaywallPlacement {
    init(placement: AdaptyPurchaseService.Placement) {
        switch placement {
        case .onboarding:
            self = .onboarding
        case .bannerSettings:
            self = .bannerSettings
        case .proButton:
            self = .proButton
        case .watermark:
            self = .watermark
        case .session:
            self = .session
        case .limitToken:
            self = .limitToken
        }
    }
}
