import Foundation

enum AppEnvironment: Equatable {
    case debug
    case testFlight
    case appStore

    var displayName: String {
        switch self {
        case .debug:
            return "Debug"
        case .testFlight:
            return "TestFlight"
        case .appStore:
            return "App Store"
        }
    }

    var isDebug: Bool {
        self == .debug
    }

    var isTestFlight: Bool {
        self == .testFlight
    }

    var isAppStore: Bool {
        self == .appStore
    }
}

final class AppEnvironmentService {
    static let shared = AppEnvironmentService()

    let current: AppEnvironment

    private init() {
        current = Self.resolveCurrentEnvironment()
    }

    var isDebug: Bool {
        current.isDebug
    }

    var isTestFlight: Bool {
        current.isTestFlight
    }

    var isAppStore: Bool {
        current.isAppStore
    }

    private static func resolveCurrentEnvironment() -> AppEnvironment {
#if DEBUG || targetEnvironment(simulator)
        return .debug
#else
        if isRunningInTestFlight {
            return .testFlight
        }

        return .appStore
#endif
    }

    private static var isRunningInTestFlight: Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return false
        }

        return receiptURL.lastPathComponent == "sandboxReceipt"
    }
}
