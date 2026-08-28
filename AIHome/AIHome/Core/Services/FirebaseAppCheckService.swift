import FirebaseAppCheck
import FirebaseCore
import Foundation

public protocol FirebaseAppCheckProviding {
    func token() async -> String?
}

enum FirebaseAppCheckBootstrap {
    private static var hasConfiguredProvider = false

    static func configureProviderIfNeeded() {
        guard !hasConfiguredProvider else { return }
        hasConfiguredProvider = true
        AppCheck.setAppCheckProviderFactory(FirebaseAppCheckProviderFactory())
    }
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
