import SwiftUI

struct AppCoordinatorView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        Group {
            if coordinator.currentRoot == .mainTab {
                MainTabView()
            } else {
                NavigationStack(path: $coordinator.path) {
                    AppCoordinatorRouter.view(for: coordinator.currentRoot)
                        .navigationDestination(for: AppRoute.self) { route in
                            AppCoordinatorRouter.view(for: route)
                        }
                }
                .id("RootNavStack")
            }
        }
        .environment(coordinator)
    }
}

struct AppCoordinatorRouter {
    @ViewBuilder
    static func view(for route: AppRoute) -> some View {
        switch route {
        case .splash:
            SplashView()
        case .welcome:
            WelcomeView()
        case .onboardingInterior:
            InteriorIntroView()
        case .onboardingExterior:
            ExteriorIntroView()
        case .onboardingLandscape:
            LandscapeIntroView()
        case .trialEnabled:
            TrialEnabledView()
        case .mainTab:
            EmptyView() // Handled by AppCoordinatorView's root switch
        case .interiorFlow:
            InteriorFlowContainerView()
        case .exteriorFlow:
            ExteriorFlowContainerView()
        case .gardenFlow:
            GardenFlowContainerView()
        case .referenceStyleFlow:
            ReferenceStyleFlowContainerView()
        case .removeObjectsFlow:
            RemoveObjectsFlowContainerView()
        case .replaceObjectsFlow:
            ReplaceObjectsFlowContainerView()
        case .newFlooringFlow:
            NewFlooringFlowContainerView()
        case .newWallsFlow:
            NewWallsFlowContainerView()
        }
    }
}
