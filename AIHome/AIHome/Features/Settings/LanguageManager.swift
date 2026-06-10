import Foundation
import Observation

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
    
    let availableLanguages = ["English", "Spanish", "French", "German"]
    
    var currentBundle: Bundle = .main
    
    private init() {
        self.selectedLanguage = UserDefaults.standard.string(forKey: languageKey) ?? "English"
        updateBundle()
    }
    
    private func updateBundle() {
        let code = languageCode(for: selectedLanguage)
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            currentBundle = bundle
        } else {
            currentBundle = .main
        }
    }
    
    private func languageCode(for language: String) -> String {
        switch language {
        case "Spanish": return "es"
        case "French": return "fr"
        case "German": return "de"
        default: return "en"
        }
    }
    
    func localizedName(for language: String) -> String {
        switch language {
        case "English": return L10n.Language.english
        case "Spanish": return L10n.Language.spanish
        case "French": return L10n.Language.french
        case "German": return L10n.Language.german
        default: return language
        }
    }
}
