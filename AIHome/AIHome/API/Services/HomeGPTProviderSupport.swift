import Foundation

public enum HomeGPTProviderKind: String, Codable, CaseIterable {
    case legacyHomeDesigns = "legacy_home_designs"
    case homeAIBackend = "home_ai_backend"

    var displayName: String {
        switch self {
        case .legacyHomeDesigns:
            return "Legacy HomeDesigns"
        case .homeAIBackend:
            return "Home AI Backend"
        }
    }
}

public protocol HomeGPTGenerationProviderProtocol: HomeGPTAIServiceProtocol {
    var providerKind: HomeGPTProviderKind { get }
}

public enum HomeGPTProviderRegistry {
    private static let storageKey = "home_gpt_provider_kind_override"
    private static var remoteDefaultKind: HomeGPTProviderKind = .homeAIBackend

    public static var selectedKind: HomeGPTProviderKind {
        get {
            if let envValue = ProcessInfo.processInfo.environment["HOME_GPT_PROVIDER_KIND"],
               let kind = HomeGPTProviderKind(rawValue: envValue) {
                return kind
            }

            if let storedValue = UserDefaults.standard.string(forKey: storageKey),
               let kind = HomeGPTProviderKind(rawValue: storedValue) {
                return kind
            }

            return remoteDefaultKind
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: storageKey)
        }
    }

    public static var hasLocalOverride: Bool {
        UserDefaults.standard.string(forKey: storageKey) != nil
    }

    public static func use(_ kind: HomeGPTProviderKind) {
        selectedKind = kind
    }

    public static func clearLocalOverride() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    public static func applyRemoteDefault(_ kind: HomeGPTProviderKind) {
        remoteDefaultKind = kind
    }
}

public enum HomeGPTProviderFactory {
    private static let lock = NSLock()
    private static var cachedKind: HomeGPTProviderKind?
    private static var cachedProvider: (any HomeGPTGenerationProviderProtocol)?

    public static func sharedProvider() -> any HomeGPTGenerationProviderProtocol {
        lock.lock()
        defer { lock.unlock() }

        let selectedKind = HomeGPTProviderRegistry.selectedKind
        if cachedKind == selectedKind, let cachedProvider {
            return cachedProvider
        }

        let provider = makeProvider(kind: selectedKind)
        cachedKind = selectedKind
        cachedProvider = provider
        return provider
    }

    public static func makeProvider(kind: HomeGPTProviderKind) -> any HomeGPTGenerationProviderProtocol {
        switch kind {
        case .legacyHomeDesigns:
            return LegacyHomeDesignsProvider()
        case .homeAIBackend:
            return HomeAIDeepArtProvider(fallbackProvider: LegacyHomeDesignsProvider())
        }
    }
}

enum HomeAIBackendCredentials {
    static var apiKey: String? {
        if let envValue = ProcessInfo.processInfo.environment[APIConstants.HomeAIBackend.apiKeyEnvironmentKey],
           !envValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return envValue
        }

        if let plistValue = Bundle.main.object(forInfoDictionaryKey: APIConstants.HomeAIBackend.apiKeyInfoPlistKey) as? String,
           !plistValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return plistValue
        }

        if let defaultsValue = UserDefaults.standard.string(forKey: APIConstants.HomeAIBackend.apiKeyUserDefaultsKey),
           !defaultsValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return defaultsValue
        }

        if !APIConstants.HomeAIBackend.devAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return APIConstants.HomeAIBackend.devAPIKey
        }

        return nil
    }
}
