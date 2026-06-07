//
//  AIHomeApp.swift
//  AIHome
//
//  Created by mac on 30/5/26.
//

import SwiftUI
import SwiftData

@main
struct AIHomeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        AdaptyPurchaseService.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
        .modelContainer(sharedModelContainer)
    }
}
