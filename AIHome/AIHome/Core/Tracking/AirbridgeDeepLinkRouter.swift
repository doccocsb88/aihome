import Foundation

@MainActor
final class AirbridgeDeepLinkRouter {
    static let shared = AirbridgeDeepLinkRouter()

    private var pendingURL: URL?

    private init() {}

    func enqueue(_ url: URL) {
        pendingURL = url
        NotificationCenter.default.post(name: .airbridgeDeepLinkPending, object: nil)
    }

    func consumePendingRoute(with coordinator: AppCoordinator) {
        guard let url = pendingURL else { return }
        pendingURL = nil
        route(url, with: coordinator)
    }

    @discardableResult
    func route(_ url: URL, with coordinator: AppCoordinator) -> Bool {
        let components = normalizedComponents(from: url)
        guard !components.isEmpty else { return false }

        switch components[0] {
        case "home":
            coordinator.popToRoot()
            coordinator.replaceRoot(with: .mainTab)
            coordinator.selectedTab = .home
            return true
        case "inspiration":
            coordinator.popToRoot()
            coordinator.replaceRoot(with: .mainTab)
            coordinator.selectedTab = .inspiration
            return true
        case "history":
            coordinator.popToRoot()
            coordinator.replaceRoot(with: .mainTab)
            coordinator.selectedTab = .history
            return true
        case "settings":
            coordinator.popToRoot()
            coordinator.replaceRoot(with: .mainTab)
            coordinator.selectedTab = .settings
            return true
        case "feature":
            guard components.count >= 2,
                  let projectType = projectType(for: components[1]) else { return false }
            coordinator.replaceRoot(with: .mainTab)
            coordinator.selectedTab = .home
            coordinator.openFlow(projectType, popToRootFirst: true)
            return true
        default:
            return false
        }
    }

    private func normalizedComponents(from url: URL) -> [String] {
        var components: [String] = []
        if let host = url.host, !host.isEmpty {
            components.append(host)
        }
        components.append(contentsOf: url.pathComponents.filter { $0 != "/" })
        return components.map { $0.lowercased().replacingOccurrences(of: "_", with: "-") }
    }

    private func projectType(for value: String) -> ProjectType? {
        switch value {
        case "interior":
            return .interior
        case "exterior":
            return .exterior
        case "garden":
            return .garden
        case "reference-style", "reference":
            return .referenceStyle
        case "remove-object", "remove-objects":
            return .removeObjects
        case "replace-object", "replace-objects":
            return .replaceObjects
        case "new-flooring", "flooring":
            return .newFlooring
        case "new-wall", "new-walls", "walls":
            return .newWalls
        case "furniture-finder", "furniture":
            return .furnitureFinder
        default:
            return nil
        }
    }
}

extension Notification.Name {
    static let airbridgeDeepLinkPending = Notification.Name("airbridgeDeepLinkPending")
}
