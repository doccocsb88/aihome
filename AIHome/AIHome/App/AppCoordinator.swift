import SwiftUI
import Observation
import UIKit

@Observable
final class AppCoordinator {
    var path: [AppRoute] = []
    var currentRoot: AppRoute = .splash
    private var initialImages: [UUID: UIImage] = [:]

    // Using @Observation and @State allows this to track navigation

    func push(_ route: AppRoute) {
        if route == .mainTab || route == .onboardingIntro {
            replaceRoot(with: route)
        } else {
            path.append(route)
            AppLogger.logScreen(String(describing: route))
        }
    }

    func pop() {
        if !path.isEmpty {
            let removed = path.removeLast()
            clearInitialImage(for: removed)
            AppLogger.logAction("Pop Navigation", details: "Removed \(String(describing: removed))")
        }
    }

    func popToRoot() {
        path.forEach(clearInitialImage)
        path.removeLast(path.count)
        AppLogger.logAction("Pop to Root")
    }

    func replaceRoot(with route: AppRoute) {
        path.forEach(clearInitialImage)
        path.removeLast(path.count)
        currentRoot = route
        AppLogger.logScreen("Root changed to: \(String(describing: route))")
    }

    func storeInitialImage(_ image: UIImage) -> UUID {
        let id = UUID()
        initialImages[id] = image
        return id
    }

    func initialImage(for id: UUID) -> UIImage? {
        initialImages[id]
    }

    private func clearInitialImage(for route: AppRoute) {
        guard let id = route.initialImageID else { return }
        initialImages.removeValue(forKey: id)
    }
}
