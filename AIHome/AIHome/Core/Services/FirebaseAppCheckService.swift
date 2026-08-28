import FirebaseAppCheck
import FirebaseCore
import Foundation
#if canImport(Darwin)
import Darwin
#endif

public protocol FirebaseAppCheckProviding {
    func token() async -> String?
}

enum FirebaseAppCheckBootstrap {
    private static var hasConfiguredProvider = false
    private static let simulatorDebugToken = "3DFE6A8B-6D01-4678-BD73-58997F08B973"

    static func configureProviderIfNeeded() {
        guard !hasConfiguredProvider else { return }
        hasConfiguredProvider = true
#if targetEnvironment(simulator) || DEBUG
        setDebugTokenIfNeeded()
#endif
        AppCheck.setAppCheckProviderFactory(FirebaseAppCheckProviderFactory())
    }

#if targetEnvironment(simulator) || DEBUG
    private static func setDebugTokenIfNeeded() {
        guard let cString = simulatorDebugToken.cString(using: .utf8) else { return }
        setenv("AppCheckDebugToken", cString, 1)
    }
#endif
}

private final class FirebaseAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
#if targetEnvironment(simulator) || DEBUG
        return AppCheckDebugProvider(app: app)
#else
        if #available(iOS 14.0, *) {
            return AppAttestProvider(app: app)
        }
        return DeviceCheckProvider(app: app)
#endif
    }
}

public final class FirebaseAppCheckService: FirebaseAppCheckProviding {
    public static let shared = FirebaseAppCheckService()

    private init() {}

    public func token() async -> String? {
        do {
            let appCheckToken = try await AppCheck.appCheck().token(forcingRefresh: false)
            return appCheckToken.token
        } catch {
            AppLogger.logError("Firebase App Check token fetch failed", error: error)
            return nil
        }
    }
}
