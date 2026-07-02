// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  internal enum Common {
    /// Cancel
    internal static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Close
    internal static let close = L10n.tr("Localizable", "common.close", fallback: "Close")
    /// Delete
    internal static let delete = L10n.tr("Localizable", "common.delete", fallback: "Delete")
    /// OK
    internal static let ok = L10n.tr("Localizable", "common.ok", fallback: "OK")
  }
  internal enum ExteriorFlow {
    /// Tailor the prompt with your own instructions...
    internal static let promptPlaceholder = L10n.tr("Localizable", "exterior_flow.prompt_placeholder", fallback: "Tailor the prompt with your own instructions...")
    /// Exterior Redesign
    internal static let title = L10n.tr("Localizable", "exterior_flow.title", fallback: "Exterior Redesign")
  }
  internal enum GenerationLoading {
    internal enum Failure {
      /// BACK TO DESIGN
      internal static let backToDesign = L10n.tr("Localizable", "generation_loading.failure.back_to_design", fallback: "BACK TO DESIGN")
      /// Choose a clear exterior photo showing the front, side, or back of the house, then try again.
      internal static let exteriorPhotoMessage = L10n.tr("Localizable", "generation_loading.failure.exterior_photo_message", fallback: "Choose a clear exterior photo showing the front, side, or back of the house, then try again.")
      /// We couldn't process your redesign request this time. Please check your photo or instructions and try again.
      internal static let message = L10n.tr("Localizable", "generation_loading.failure.message", fallback: "We couldn't process your redesign request this time. Please check your photo or instructions and try again.")
      /// Generation Failed
      internal static let title = L10n.tr("Localizable", "generation_loading.failure.title", fallback: "Generation Failed")
      /// TRY AGAIN
      internal static let tryAgain = L10n.tr("Localizable", "generation_loading.failure.try_again", fallback: "TRY AGAIN")
    }
  }
  internal enum History {
    /// Delete (%d)
    internal static func deleteSelected(_ p1: Int) -> String {
      return L10n.tr("Localizable", "history.delete_selected", p1, fallback: "Delete (%d)")
    }
    /// History
    internal static let title = L10n.tr("Localizable", "history.title", fallback: "History")
    internal enum DeleteConfirmation {
      /// This action cannot be undone.
      internal static let message = L10n.tr("Localizable", "history.delete_confirmation.message", fallback: "This action cannot be undone.")
      /// Delete selected projects?
      internal static let title = L10n.tr("Localizable", "history.delete_confirmation.title", fallback: "Delete selected projects?")
    }
    internal enum Empty {
      /// Create New Project
      internal static let createProject = L10n.tr("Localizable", "history.empty.create_project", fallback: "Create New Project")
      /// Create a new space and watch your
      /// ideas come to life.
      internal static let message = L10n.tr("Localizable", "history.empty.message", fallback: "Create a new space and watch your\nideas come to life.")
      /// Start your first project
      internal static let title = L10n.tr("Localizable", "history.empty.title", fallback: "Start your first project")
    }
    internal enum FilterEmpty {
      /// Try adjusting or resetting your filters.
      internal static let message = L10n.tr("Localizable", "history.filter_empty.message", fallback: "Try adjusting or resetting your filters.")
      /// Reset Filters
      internal static let resetFilters = L10n.tr("Localizable", "history.filter_empty.reset_filters", fallback: "Reset Filters")
      /// No matching projects
      internal static let title = L10n.tr("Localizable", "history.filter_empty.title", fallback: "No matching projects")
    }
  }
  internal enum Home {
    /// ADVANCED EDITING
    internal static let advancedEditing = L10n.tr("Localizable", "home.advanced_editing", fallback: "ADVANCED EDITING")
    /// Home
    internal static let title = L10n.tr("Localizable", "home.title", fallback: "Home")
  }
  internal enum Inspiration {
    /// Like inspiration
    internal static let like = L10n.tr("Localizable", "inspiration.like", fallback: "Like inspiration")
    /// Inspiration
    internal static let title = L10n.tr("Localizable", "inspiration.title", fallback: "Inspiration")
    /// Unlike inspiration
    internal static let unlike = L10n.tr("Localizable", "inspiration.unlike", fallback: "Unlike inspiration")
  }
  internal enum Language {
    /// Arabic (Saudi Arabia)
    internal static let arabicSaudiArabia = L10n.tr("Localizable", "language.arabic_saudi_arabia", fallback: "Arabic (Saudi Arabia)")
    /// English (US)
    internal static let englishUs = L10n.tr("Localizable", "language.english_us", fallback: "English (US)")
    /// French (France)
    internal static let frenchFrance = L10n.tr("Localizable", "language.french_france", fallback: "French (France)")
    /// German (Germany)
    internal static let germanGermany = L10n.tr("Localizable", "language.german_germany", fallback: "German (Germany)")
    /// Hindi
    internal static let hindi = L10n.tr("Localizable", "language.hindi", fallback: "Hindi")
    /// Indonesian
    internal static let indonesian = L10n.tr("Localizable", "language.indonesian", fallback: "Indonesian")
    /// Italian
    internal static let italian = L10n.tr("Localizable", "language.italian", fallback: "Italian")
    /// Japanese
    internal static let japanese = L10n.tr("Localizable", "language.japanese", fallback: "Japanese")
    /// Korean
    internal static let korean = L10n.tr("Localizable", "language.korean", fallback: "Korean")
    /// Malay
    internal static let malay = L10n.tr("Localizable", "language.malay", fallback: "Malay")
    /// Portuguese (Brazil)
    internal static let portugueseBrazil = L10n.tr("Localizable", "language.portuguese_brazil", fallback: "Portuguese (Brazil)")
    /// Russian
    internal static let russian = L10n.tr("Localizable", "language.russian", fallback: "Russian")
    /// Spanish (Spain)
    internal static let spanishSpain = L10n.tr("Localizable", "language.spanish_spain", fallback: "Spanish (Spain)")
    /// Thai
    internal static let thai = L10n.tr("Localizable", "language.thai", fallback: "Thai")
    /// Language
    internal static let title = L10n.tr("Localizable", "language.title", fallback: "Language")
    /// Turkish
    internal static let turkish = L10n.tr("Localizable", "language.turkish", fallback: "Turkish")
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
    /// After
    internal static let after = L10n.tr("Localizable", "onboarding.after", fallback: "After")
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
      /// 3-day free trial
      internal static let titleLine1 = L10n.tr("Localizable", "onboarding.trial_enabled.title_line1", fallback: "3-day free trial")
      /// is enabled!
      internal static let titleLine2 = L10n.tr("Localizable", "onboarding.trial_enabled.title_line2", fallback: "is enabled!")
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
      internal enum Terms {
        /// and
        internal static let and = L10n.tr("Localizable", "onboarding.welcome.terms.and", fallback: "and")
        /// ,
        internal static let comma = L10n.tr("Localizable", "onboarding.welcome.terms.comma", fallback: ",")
        /// By continuing, you agree with
        internal static let leading = L10n.tr("Localizable", "onboarding.welcome.terms.leading", fallback: "By continuing, you agree with")
        /// along with our use of third-party tools for app functionality.
        internal static let thirdPartyTools = L10n.tr("Localizable", "onboarding.welcome.terms.third_party_tools", fallback: "along with our use of third-party tools for app functionality.")
      }
    }
  }
  internal enum PhotoTips {
    /// BAD EXAMPLES:
    internal static let badExamples = L10n.tr("Localizable", "photo_tips.bad_examples", fallback: "BAD EXAMPLES:")
    /// **Bright Lighting:** Ensure the room is well-lit to eliminate shadows.
    internal static let brightLighting = L10n.tr("Localizable", "photo_tips.bright_lighting", fallback: "**Bright Lighting:** Ensure the room is well-lit to eliminate shadows.")
    /// Close
    internal static let close = L10n.tr("Localizable", "photo_tips.close", fallback: "Close")
    /// The file dimensions must be at least 512x512.
    internal static let fileDimensions = L10n.tr("Localizable", "photo_tips.file_dimensions", fallback: "The file dimensions must be at least 512x512.")
    /// The file size must be less than 20 MB.
    internal static let fileSize = L10n.tr("Localizable", "photo_tips.file_size", fallback: "The file size must be less than 20 MB.")
    /// GOOD EXAMPLES:
    internal static let goodExamples = L10n.tr("Localizable", "photo_tips.good_examples", fallback: "GOOD EXAMPLES:")
    /// GOT IT
    internal static let gotIt = L10n.tr("Localizable", "photo_tips.got_it", fallback: "GOT IT")
    /// **Landscape Mode:** Capture your image horizontally.
    internal static let landscapeMode = L10n.tr("Localizable", "photo_tips.landscape_mode", fallback: "**Landscape Mode:** Capture your image horizontally.")
    /// FOR OPTIMAL RESULTS:
    internal static let optimalResults = L10n.tr("Localizable", "photo_tips.optimal_results", fallback: "FOR OPTIMAL RESULTS:")
    /// REQUIREMENTS:
    internal static let requirements = L10n.tr("Localizable", "photo_tips.requirements", fallback: "REQUIREMENTS:")
    /// **Stay Steady:** Keep the camera still for a sharp, detailed image.
    internal static let staySteady = L10n.tr("Localizable", "photo_tips.stay_steady", fallback: "**Stay Steady:** Keep the camera still for a sharp, detailed image.")
    /// Photo Tips
    internal static let title = L10n.tr("Localizable", "photo_tips.title", fallback: "Photo Tips")
    /// **Wide Framing:** Capture all key angles in a single frame.
    internal static let wideFraming = L10n.tr("Localizable", "photo_tips.wide_framing", fallback: "**Wide Framing:** Capture all key angles in a single frame.")
  }
  internal enum Rating {
    /// Five star rating
    internal static let fiveStarRating = L10n.tr("Localizable", "rating.five_star_rating", fallback: "Five star rating")
    /// Rate on App Store
    internal static let rateOnStore = L10n.tr("Localizable", "rating.rate_on_store", fallback: "Rate on App Store")
    /// %d star rating
    internal static func starRating(_ p1: Int) -> String {
      return L10n.tr("Localizable", "rating.star_rating", p1, fallback: "%d star rating")
    }
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
    internal enum ArchiveSuccess {
      /// Saved to Archive
      internal static let title = L10n.tr("Localizable", "result.archive_success.title", fallback: "Saved to Archive")
    }
    internal enum SaveFailure {
      /// The image could not be saved to your photo gallery.
      internal static let message = L10n.tr("Localizable", "result.save_failure.message", fallback: "The image could not be saved to your photo gallery.")
      /// Photo library access is required to save this image.
      internal static let photoAccessRequired = L10n.tr("Localizable", "result.save_failure.photo_access_required", fallback: "Photo library access is required to save this image.")
      /// Save Failed
      internal static let title = L10n.tr("Localizable", "result.save_failure.title", fallback: "Save Failed")
    }
    internal enum SaveSuccess {
      /// The image has been saved to your photo gallery.
      internal static let message = L10n.tr("Localizable", "result.save_success.message", fallback: "The image has been saved to your photo gallery.")
      /// Saved
      internal static let title = L10n.tr("Localizable", "result.save_success.title", fallback: "Saved")
    }
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

