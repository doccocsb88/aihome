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

    func trackGenerationFail(feature: Feature, errorType: GenerationErrorType, durationMs: Int) {
        log(
            name: "generation_fail",
            params: [
                "feature": feature.rawValue,
                "error_type": errorType.rawValue,
                "duration_ms": durationMs
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

extension TrackingManager.GenerationErrorType {
    init(error: Error) {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorTimedOut {
            self = .timeout
            return
        }

        let message = error.localizedDescription.lowercased()
        if message.contains("credit") || message.contains("limit") {
            self = .noCredit
        } else if message.contains("moderat") {
            self = .moderation
        } else {
            self = .apiError
        }
    }
}
