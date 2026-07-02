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
    
    var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: languageKey)
            updateBundle()
        }
    }
    
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
    
    func localizedName(for language: AppLanguage) -> String {
        switch language.code {
        case "en-US": return L10n.Language.englishUs
        case "ar-SA": return L10n.Language.arabicSaudiArabia
        case "de-DE": return L10n.Language.germanGermany
        case "es-ES": return L10n.Language.spanishSpain
        case "fr-FR": return L10n.Language.frenchFrance
        case "hi": return L10n.Language.hindi
        case "id": return L10n.Language.indonesian
        case "it": return L10n.Language.italian
        case "ja": return L10n.Language.japanese
        case "ko": return L10n.Language.korean
        case "ms": return L10n.Language.malay
        case "pt-BR": return L10n.Language.portugueseBrazil
        case "ru": return L10n.Language.russian
        case "th": return L10n.Language.thai
        case "tr": return L10n.Language.turkish
        default: return language.fallbackName
        }
    }

    func localizedName(forCode code: String) -> String {
        let normalizedCode = Self.normalizedLanguageCode(code)
        guard let language = availableLanguages.first(where: { $0.code == normalizedCode }) else {
            return code
        }
        return localizedName(for: language)
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
