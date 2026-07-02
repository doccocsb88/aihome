import Foundation
import Observation

struct AppLanguage: Hashable, Identifiable {
    let code: String
    let fallbackName: String

    var id: String { code }
}

@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    private let languageKey = "selected_language_key"
    
    private(set) var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: languageKey)
            updateBundle()
        }
    }

    /// Bumped when language is applied to recreate the entire app from splash.
    private(set) var appRestartID = UUID()
    
    let availableLanguages: [AppLanguage] = [
        AppLanguage(code: "en-US", fallbackName: "English (US)"),
        AppLanguage(code: "ar-SA", fallbackName: "Arabic (Saudi Arabia)"),
        AppLanguage(code: "de-DE", fallbackName: "German (Germany)"),
        AppLanguage(code: "es-ES", fallbackName: "Spanish (Spain)"),
        AppLanguage(code: "fr-FR", fallbackName: "French (France)"),
        AppLanguage(code: "hi", fallbackName: "Hindi"),
        AppLanguage(code: "id", fallbackName: "Indonesian"),
        AppLanguage(code: "it", fallbackName: "Italian"),
        AppLanguage(code: "ja", fallbackName: "Japanese"),
        AppLanguage(code: "ko", fallbackName: "Korean"),
        AppLanguage(code: "ms", fallbackName: "Malay"),
        AppLanguage(code: "pt-BR", fallbackName: "Portuguese (Brazil)"),
        AppLanguage(code: "ru", fallbackName: "Russian"),
        AppLanguage(code: "th", fallbackName: "Thai"),
        AppLanguage(code: "tr", fallbackName: "Turkish")
    ]
    
    var currentBundle: Bundle = .main
    
    private init() {
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey) {
            self.selectedLanguage = Self.normalizedLanguageCode(savedLanguage)
        } else {
            self.selectedLanguage = Self.devicePreferredLanguageCode()
        }
        updateBundle()
    }
    
    private func updateBundle() {
        if let path = Bundle.main.path(forResource: selectedLanguage, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            currentBundle = bundle
        } else if let languageCode = selectedLanguage.split(separator: "-").first,
                  let path = Bundle.main.path(forResource: String(languageCode), ofType: "lproj"),
           let bundle = Bundle(path: path) {
            currentBundle = bundle
        } else {
            currentBundle = .main
        }
    }
    
    var isRightToLeft: Bool {
        selectedLanguage.hasPrefix("ar")
    }

    func applyLanguage(_ languageCode: String) {
        let normalizedCode = Self.normalizedLanguageCode(languageCode)
        guard normalizedCode != selectedLanguage else { return }

        selectedLanguage = normalizedCode
        appRestartID = UUID()
    }

    func localizedName(for language: AppLanguage) -> String {
        currentBundle.localizedString(
            forKey: Self.languageNameKey(for: language.code),
            value: language.fallbackName,
            table: "Localizable"
        )
    }

    func localizedName(forCode code: String) -> String {
        let normalizedCode = Self.normalizedLanguageCode(code)
        guard let language = availableLanguages.first(where: { $0.code == normalizedCode }) else {
            return code
        }
        return localizedName(for: language)
    }

    private static func languageNameKey(for code: String) -> String {
        switch code {
        case "en-US": return "language.english_us"
        case "ar-SA": return "language.arabic_saudi_arabia"
        case "de-DE": return "language.german_germany"
        case "es-ES": return "language.spanish_spain"
        case "fr-FR": return "language.french_france"
        case "hi": return "language.hindi"
        case "id": return "language.indonesian"
        case "it": return "language.italian"
        case "ja": return "language.japanese"
        case "ko": return "language.korean"
        case "ms": return "language.malay"
        case "pt-BR": return "language.portuguese_brazil"
        case "ru": return "language.russian"
        case "th": return "language.thai"
        case "tr": return "language.turkish"
        default: return "language.title"
        }
    }
    
    private static func normalizedLanguageCode(_ savedValue: String) -> String {
        mapLocaleIdentifierToAppLanguage(savedValue) ?? "en-US"
    }

    private static func devicePreferredLanguageCode() -> String {
        for preferredLanguage in Locale.preferredLanguages {
            if let matchedLanguageCode = mapLocaleIdentifierToAppLanguage(preferredLanguage) {
                return matchedLanguageCode
            }
        }

        return mapLocaleIdentifierToAppLanguage(Locale.current.identifier) ?? "en-US"
    }

    private static func mapLocaleIdentifierToAppLanguage(_ identifier: String) -> String? {
        let normalizedIdentifier = identifier.replacingOccurrences(of: "_", with: "-")

        switch normalizedIdentifier {
        case "English", "en", "en-US", "en-GB", "en-AU", "en-CA", "en-NZ", "en-IN", "en-SG", "en-PH", "en-ZA", "en-IE":
            return "en-US"
        case "Arabic", "ar", "ar-SA", "ar-AE", "ar-EG", "ar-QA", "ar-KW", "ar-BH", "ar-OM", "ar-JO", "ar-LB":
            return "ar-SA"
        case "German", "de", "de-DE", "de-AT", "de-CH":
            return "de-DE"
        case "Spanish", "es", "es-ES", "es-MX", "es-AR", "es-CO", "es-CL", "es-PE", "es-VE", "es-US":
            return "es-ES"
        case "French", "fr", "fr-FR", "fr-CA", "fr-BE", "fr-CH":
            return "fr-FR"
        case "Hindi", "hi", "hi-IN":
            return "hi"
        case "Indonesian", "id", "id-ID":
            return "id"
        case "Italian", "it", "it-IT", "it-CH":
            return "it"
        case "Japanese", "ja", "ja-JP":
            return "ja"
        case "Korean", "ko", "ko-KR":
            return "ko"
        case "Malay", "ms", "ms-MY", "ms-SG", "ms-BN":
            return "ms"
        case "Portuguese", "pt", "pt-BR", "pt-PT":
            return "pt-BR"
        case "Russian", "ru", "ru-RU":
            return "ru"
        case "Thai", "th", "th-TH":
            return "th"
        case "Turkish", "tr", "tr-TR":
            return "tr"
        default:
            break
        }

        let lowercasedIdentifier = normalizedIdentifier.lowercased()

        for languageCode in supportedLanguageCodes where lowercasedIdentifier == languageCode.lowercased() {
            return languageCode
        }

        let languagePrefix = lowercasedIdentifier.split(separator: "-").first.map(String.init) ?? lowercasedIdentifier

        for languageCode in supportedLanguageCodes {
            let supportedPrefix = languageCode.split(separator: "-").first.map(String.init) ?? languageCode
            if languagePrefix == supportedPrefix.lowercased() {
                return languageCode
            }
        }

        return nil
    }

    private static let supportedLanguageCodes = [
        "en-US", "ar-SA", "de-DE", "es-ES", "fr-FR", "hi", "id", "it", "ja", "ko", "ms", "pt-BR", "ru", "th", "tr"
    ]
}
