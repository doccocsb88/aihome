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
            InteriorFlowView { _ in }
        case .exteriorFlow:
            ExteriorFlowView { _ in }
        case .gardenFlow:
            GardenFlowView { _ in }
        case .referenceStyleFlow:
            ReferenceStyleFlowView { _ in }
        case .removeObjectsFlow:
            RemoveObjectsFlowView { _ in }
        case .replaceObjectsFlow:
            ReplaceObjectsFlowView { _ in }
        case .newFlooringFlow:
            NewFlooringFlowView { _ in }
        case .newWallsFlow:
            NewWallsFlowView { _ in }
        }
    }
}
