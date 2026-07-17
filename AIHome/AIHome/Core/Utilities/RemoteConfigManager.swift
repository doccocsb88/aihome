import FirebaseRemoteConfig
import Foundation
import Observation

@MainActor
@Observable
final class RemoteConfigManager {
    static let shared = RemoteConfigManager()

    private enum Keys {
        static let trialEnable = "trialEnable"
    }

    private let remoteConfig: RemoteConfig
    private(set) var trialEnable: Bool

    private init(remoteConfig: RemoteConfig = .remoteConfig()) {
        self.remoteConfig = remoteConfig
        self.trialEnable = false
        configureDefaults()
        syncValues()
    }

    func fetchAndActivate() async {
        do {
            let status = try await remoteConfig.fetchAndActivate()
            syncValues()
            AppLogger.logAction("Remote Config Activated", details: "\(status.rawValue)")
        } catch {
            AppLogger.logError("Remote Config Fetch Failed", error: error)
        }
    }

    private func configureDefaults() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            Keys.trialEnable: false as NSObject
        ])
    }

    private func syncValues() {
        trialEnable = remoteConfig[Keys.trialEnable].boolValue
        AppLogger.logAction("Remote Config syncValues", details: "\(trialEnable)")
    }
}
