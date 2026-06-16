// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Language {
    /// English
    internal static let english = L10n.tr("Localizable", "language.english", fallback: "English")
    /// French
    internal static let french = L10n.tr("Localizable", "language.french", fallback: "French")
    /// German
    internal static let german = L10n.tr("Localizable", "language.german", fallback: "German")
    /// Spanish
    internal static let spanish = L10n.tr("Localizable", "language.spanish", fallback: "Spanish")
    /// Language
    internal static let title = L10n.tr("Localizable", "language.title", fallback: "Language")
  }
  internal enum Limit {
    /// Upgrade Now
    internal static let upgradeNow = L10n.tr("Localizable", "limit.upgrade_now", fallback: "Upgrade Now")
    internal enum GenerationsLeft {
      /// Unlock unlimited features, designs &
      /// faster processing with Pro.
      internal static let message = L10n.tr("Localizable", "limit.generations_left.message", fallback: "Unlock unlimited features, designs &\nfaster processing with Pro.")
      /// %d/%d Free
      /// Generations Left
      internal static func title(_ p1: Int, _ p2: Int) -> String {
        return L10n.tr("Localizable", "limit.generations_left.title", p1, p2, fallback: "%d/%d Free\nGenerations Left")
      }
    }
    internal enum Reached {
      /// You've used all your free generations.
      /// Unlock unlimited features, designs &
      /// faster processing with Pro.
      internal static let message = L10n.tr("Localizable", "limit.reached.message", fallback: "You've used all your free generations.\nUnlock unlimited features, designs &\nfaster processing with Pro.")
      /// Limit Reached
      internal static let title = L10n.tr("Localizable", "limit.reached.title", fallback: "Limit Reached")
    }
  }
  internal enum Onboarding {
    /// Continue
    internal static let `continue` = L10n.tr("Localizable", "onboarding.continue", fallback: "Continue")
    internal enum Exterior {
      /// Reimagine your facade
      internal static let subtitle = L10n.tr("Localizable", "onboarding.exterior.subtitle", fallback: "Reimagine your facade")
      /// Exterior Design
      internal static let title = L10n.tr("Localizable", "onboarding.exterior.title", fallback: "Exterior Design")
    }
    internal enum Interior {
      /// Redesign your space instantly
      internal static let subtitle = L10n.tr("Localizable", "onboarding.interior.subtitle", fallback: "Redesign your space instantly")
      /// Interior Design
      internal static let title = L10n.tr("Localizable", "onboarding.interior.title", fallback: "Interior Design")
    }
    internal enum Landscape {
      /// Refresh your garden with AI
      internal static let subtitle = L10n.tr("Localizable", "onboarding.landscape.subtitle", fallback: "Refresh your garden with AI")
      /// Landscape Design
      internal static let title = L10n.tr("Localizable", "onboarding.landscape.title", fallback: "Landscape Design")
    }
    internal enum TrialEnabled {
      /// Start Designing
      internal static let startDesigning = L10n.tr("Localizable", "onboarding.trial_enabled.start_designing", fallback: "Start Designing")
      /// You now have full access to all premium features.
      internal static let subtitle = L10n.tr("Localizable", "onboarding.trial_enabled.subtitle", fallback: "You now have full access to all premium features.")
      /// 3-day free trial is enabled!
      internal static let title = L10n.tr("Localizable", "onboarding.trial_enabled.title", fallback: "3-day free trial is enabled!")
    }
    internal enum Welcome {
      /// Get Started
      internal static let getStarted = L10n.tr("Localizable", "onboarding.welcome.get_started", fallback: "Get Started")
      /// Privacy Policy
      internal static let privacyPolicy = L10n.tr("Localizable", "onboarding.welcome.privacy_policy", fallback: "Privacy Policy")
      /// Subscription Terms
      internal static let subscriptionTerms = L10n.tr("Localizable", "onboarding.welcome.subscription_terms", fallback: "Subscription Terms")
      /// Transform your space with AI
      internal static let subtitle = L10n.tr("Localizable", "onboarding.welcome.subtitle", fallback: "Transform your space with AI")
      /// Terms of use
      internal static let termsOfUse = L10n.tr("Localizable", "onboarding.welcome.terms_of_use", fallback: "Terms of use")
      /// Welcome to HomeGPT
      internal static let title = L10n.tr("Localizable", "onboarding.welcome.title", fallback: "Welcome to HomeGPT")
    }
  }
  internal enum Rating {
    /// Rate on App Store
    internal static let rateOnStore = L10n.tr("Localizable", "rating.rate_on_store", fallback: "Rate on App Store")
    /// Write a Review
    internal static let writeReview = L10n.tr("Localizable", "rating.write_review", fallback: "Write a Review")
    internal enum HomeEnjoyment {
      /// Rate your experience and help us build the future of AI home design. It only takes a second!
      internal static let message = L10n.tr("Localizable", "rating.home_enjoyment.message", fallback: "Rate your experience and help us build the future of AI home design. It only takes a second!")
      /// Enjoying HomeGPT?
      internal static let title = L10n.tr("Localizable", "rating.home_enjoyment.title", fallback: "Enjoying HomeGPT?")
    }
    internal enum ResultFeedback {
      /// We'd love to hear your thoughts! If you're enjoying the transformations, please consider leaving a rating. Your feedback helps us build a more powerful AI experience for you.
      internal static let message = L10n.tr("Localizable", "rating.result_feedback.message", fallback: "We'd love to hear your thoughts! If you're enjoying the transformations, please consider leaving a rating. Your feedback helps us build a more powerful AI experience for you.")
      /// Your feedback =
      /// better designs
      internal static let title = L10n.tr("Localizable", "rating.result_feedback.title", fallback: "Your feedback =\nbetter designs")
    }
  }
  internal enum Result {
    /// DOWNLOAD
    internal static let download = L10n.tr("Localizable", "result.download", fallback: "DOWNLOAD")
    /// PRO
    internal static let pro = L10n.tr("Localizable", "result.pro", fallback: "PRO")
    /// REGENERATE
    internal static let regenerate = L10n.tr("Localizable", "result.regenerate", fallback: "REGENERATE")
    /// REMOVE WATERMARK
    internal static let removeWatermark = L10n.tr("Localizable", "result.remove_watermark", fallback: "REMOVE WATERMARK")
    /// SAVE TO ARCHIVE
    internal static let saveToArchive = L10n.tr("Localizable", "result.save_to_archive", fallback: "SAVE TO ARCHIVE")
    /// SHARE
    internal static let share = L10n.tr("Localizable", "result.share", fallback: "SHARE")
    /// Result
    internal static let title = L10n.tr("Localizable", "result.title", fallback: "Result")
  }
  internal enum Settings {
    /// Feedback
    internal static let feedback = L10n.tr("Localizable", "settings.feedback", fallback: "Feedback")
    /// Language
    internal static let language = L10n.tr("Localizable", "settings.language", fallback: "Language")
    /// Privacy Policy
    internal static let privacyPolicy = L10n.tr("Localizable", "settings.privacy_policy", fallback: "Privacy Policy")
    /// Restore Purchase
    internal static let restorePurchase = L10n.tr("Localizable", "settings.restore_purchase", fallback: "Restore Purchase")
    /// Restoring...
    internal static let restoring = L10n.tr("Localizable", "settings.restoring", fallback: "Restoring...")
    /// Terms of Service
    internal static let termsOfService = L10n.tr("Localizable", "settings.terms_of_service", fallback: "Terms of Service")
    /// Setting
    internal static let title = L10n.tr("Localizable", "settings.title", fallback: "Setting")
    /// Version %@
    internal static func version(_ p1: Any) -> String {
      return L10n.tr("Localizable", "settings.version", String(describing: p1), fallback: "Version %@")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static var bundle: Bundle {
    return LanguageManager.shared.currentBundle
  }
}
// swiftlint:enable convenience_type

