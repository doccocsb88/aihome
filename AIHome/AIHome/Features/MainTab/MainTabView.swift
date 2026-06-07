import SwiftUI

struct MainTabView: View {
    @State private var viewModel = MainTabViewModel()
    @State private var showingInspirationDetail = false
    @State private var showingInspirationFilter = false
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.selectedTab) {
                NavigationStack(path: Bindable(coordinator).path) {
                    HomeView()
                        .navigationDestination(for: AppRoute.self) { route in
                            AppCoordinatorRouter.view(for: route)
                        }
                }
                .id("HomeNavStack")
                .toolbar(.hidden, for: .tabBar)
                .tag(MainTab.home)

                NavigationStack(path: Bindable(coordinator).path) {
                    InspirationView(
                        showingDetail: $showingInspirationDetail,
                        onFilterPresentationChanged: { showingInspirationFilter = $0 }
                    )
                    .navigationDestination(for: AppRoute.self) { route in
                        AppCoordinatorRouter.view(for: route)
                    }
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(MainTab.inspiration)
                
                NavigationStack {
                    HistoryView()
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(MainTab.history)

                NavigationStack {
                    SettingsView()
                }
                .toolbar(.hidden, for: .tabBar)
                .tag(MainTab.settings)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: shouldShowCustomTabBar ? 68 : 0)
            }

            if shouldShowCustomTabBar {
                CustomTabBar(selectedTab: $viewModel.selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.9), value: shouldShowCustomTabBar)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if viewModel.isPro {
                        Text("PRO")
                            .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.DesignSystem.accent)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    } else {
                        Text("\(viewModel.freeGenerationsRemaining)/3")
                            .font(FontFamily.Roboto.regular.swiftUIFont(size: 12))
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

    private var shouldShowCustomTabBar: Bool {
        !showingInspirationDetail && !showingInspirationFilter && coordinator.path.isEmpty
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        HStack {
            TabBarItem(
                iconName: "ic_tab_home",
                isActive: selectedTab == .home,
                action: { selectedTab = .home }
            )
            TabBarItem(
                iconName: "ic_tab_inspiration",
                isActive: selectedTab == .inspiration,
                action: { selectedTab = .inspiration }
            )
            TabBarItem(
                iconName: "ic_tab_history",
                isActive: selectedTab == .history,
                action: { selectedTab = .history }
            )
            TabBarItem(
                iconName: "ic_tab_setting",
                isActive: selectedTab == .settings,
                action: { selectedTab = .settings }
            )
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            Color(uiColor: .systemBackground)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: Color.black.opacity(0.04), radius: 8, y: -4)
        )
    }
}

struct TabBarItem: View {
    let iconName: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(iconName)
                    .renderingMode(.template)
                    .foregroundColor(isActive ? .primary : Color(uiColor: .systemGray2))
                
                Image("ic_tab_active")
                    .opacity(isActive ? 1 : 0)
            }
            .offset(y: isActive ? -6 : 0)
            .animation(.easeOut(duration: 0.2), value: isActive)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48) // Fixed height to prevent layout jumps when offsetting
    }
}

#Preview {
    MainTabView()
}
