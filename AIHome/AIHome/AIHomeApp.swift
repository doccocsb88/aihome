//
//  AIHomeApp.swift
//  AIHome
//
//  Created by mac on 30/5/26.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAnalytics
import FacebookCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0"
        Analytics.setUserProperty(version, forName: "current_app_version")
        _ = RemoteConfigManager.shared
        Task { @MainActor in
            await RemoteConfigManager.shared.fetchAndActivate()
        }
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        return true
    }
}

@main
struct AIHomeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var languageManager = LanguageManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            LocalProjectRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        RatingPromptTracker.recordSessionOpen()
        AdaptyPurchaseService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environment(languageManager)
                .environment(\.layoutDirection, languageManager.isRightToLeft ? .rightToLeft : .leftToRight)
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
