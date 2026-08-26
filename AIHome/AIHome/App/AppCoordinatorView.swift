import SwiftUI

struct AppCoordinatorView: View {
    @Environment(LanguageManager.self) private var languageManager
    @State private var coordinator = AppCoordinator()

    var body: some View {
        Group {
            if coordinator.currentRoot == .mainTab {
                MainTabView()
            } else {
                NavigationStack(path: $coordinator.path) {
                    AppCoordinatorRouter.view(for: coordinator.currentRoot, coordinator: coordinator)
                        .navigationDestination(for: AppRoute.self) { route in
                            AppCoordinatorRouter.view(for: route, coordinator: coordinator)
                        }
                }
                .id("RootNavStack")
            }
        }
        // Rebuilds localized UI while keeping coordinator state (tab, navigation path).
        .id(languageManager.localeRefreshID)
        .environment(coordinator)
    }
}

struct AppCoordinatorRouter {
    @ViewBuilder
    static func view(for route: AppRoute, coordinator: AppCoordinator) -> some View {
        switch route {
        case .splash:
            SplashView()
        case .onboardingIntro:
            OnboardingIntroPagerView()
        case .mainTab:
            EmptyView() // Handled by AppCoordinatorView's root switch
        case .interiorFlow:
            InteriorFlowContainerView()
        case .interiorFlowWithImage(let id):
            InteriorFlowContainerView(initialImage: coordinator.initialImage(for: id))
        case .exteriorFlow:
            ExteriorFlowContainerView()
        case .exteriorFlowWithImage(let id):
            ExteriorFlowContainerView(initialImage: coordinator.initialImage(for: id))
        case .gardenFlow:
            GardenFlowContainerView()
        case .gardenFlowWithImage(let id):
            GardenFlowContainerView(initialImage: coordinator.initialImage(for: id))
        case .referenceStyleFlow:
            ReferenceStyleFlowContainerView()
        case .referenceStyleFlowWithImage(let id):
            ReferenceStyleFlowContainerView(initialImage: coordinator.initialImage(for: id))
        case .removeObjectsFlow:
            RemoveObjectsFlowContainerView()
        case .removeObjectsFlowWithImage(let id):
            RemoveObjectsFlowContainerView(initialImage: coordinator.initialImage(for: id))
        case .replaceObjectsFlow:
            ReplaceObjectsFlowContainerView()
        case .replaceObjectsFlowWithImage(let id):
            ReplaceObjectsFlowContainerView(initialImage: coordinator.initialImage(for: id))
        case .newFlooringFlow:
            NewFlooringFlowContainerView()
        case .newFlooringFlowWithImage(let id):
            NewFlooringFlowContainerView(initialImage: coordinator.initialImage(for: id))
        case .newWallsFlow:
            NewWallsFlowContainerView()
        case .newWallsFlowWithImage(let id):
            NewWallsFlowContainerView(initialImage: coordinator.initialImage(for: id))
        case .furnitureFinderFlow:
            FurnitureFinderView()
        case .furnitureFinderFlowWithImage(let id):
            FurnitureFinderView(initialImage: coordinator.initialImage(for: id))
        }
    }
}
