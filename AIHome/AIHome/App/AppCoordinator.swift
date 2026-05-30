import SwiftUI
import Observation

@Observable
final class AppCoordinator {
    var path: [AppRoute] = []
    var currentRoot: AppRoute = .splash
    
    // Using @Observation and @State allows this to track navigation
    
    func push(_ route: AppRoute) {
        if route == .mainTab || route == .welcome {
            replaceRoot(with: route)
        } else {
            path.append(route)
            AppLogger.logScreen(String(describing: route))
        }
    }
    
    func pop() {
        if !path.isEmpty {
            let removed = path.removeLast()
            AppLogger.logAction("Pop Navigation", details: "Removed \(String(describing: removed))")
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
        AppLogger.logAction("Pop to Root")
    }
    
    func replaceRoot(with route: AppRoute) {
        path.removeLast(path.count)
        currentRoot = route
        AppLogger.logScreen("Root changed to: \(String(describing: route))")
    }
}
