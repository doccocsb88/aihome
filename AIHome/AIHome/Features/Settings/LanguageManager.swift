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
        self.selectedLanguage = Self.normalizedLanguageCode(
            UserDefaults.standard.string(forKey: languageKey)
        )
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
    
    private static func normalizedLanguageCode(_ savedValue: String?) -> String {
        switch savedValue {
        case "English", "en", "en-US": return "en-US"
        case "Arabic", "ar", "ar-SA": return "ar-SA"
        case "German", "de", "de-DE": return "de-DE"
        case "Spanish", "es", "es-ES": return "es-ES"
        case "French", "fr", "fr-FR": return "fr-FR"
        case "Hindi", "hi": return "hi"
        case "Indonesian", "id": return "id"
        case "Italian", "it": return "it"
        case "Japanese", "ja": return "ja"
        case "Korean", "ko": return "ko"
        case "Malay", "ms": return "ms"
        case "Portuguese", "pt", "pt-BR": return "pt-BR"
        case "Russian", "ru": return "ru"
        case "Thai", "th": return "th"
        case "Turkish", "tr": return "tr"
        default: return "en-US"
        }
    }
}
