import SwiftUI

struct MainTabView: View {
    @State private var viewModel = MainTabViewModel()
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            NavigationStack(path: Bindable(coordinator).path) {
                HomeView()
                    .navigationDestination(for: AppRoute.self) { route in
                        AppCoordinatorRouter.view(for: route)
                    }
            }
            .id("HomeNavStack")
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(MainTab.home)
            
            NavigationStack {
                InspirationView()
            }
            .tabItem {
                Label("Inspiration", systemImage: "sparkles")
            }
            .tag(MainTab.inspiration)
            
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
            .tag(MainTab.history)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
            .tag(MainTab.settings)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if viewModel.isPro {
                        Text("PRO")
                            .font(.caption)
                            .bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.DesignSystem.accent)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    } else {
                        Text("\(viewModel.freeGenerationsRemaining)/3")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.DesignSystem.surface)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            AppLogger.logScreen("MainTabView")
        }
    }
}

#Preview {
    MainTabView()
}
