import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var remoteConfigManager = RemoteConfigManager.shared
    @State private var isShowingHomeRating = false
    @Environment(AppCoordinator.self) private var coordinator

    private var orderedTools: [HomeToolItem] {
        viewModel.orderedTools(for: remoteConfigManager.homeFeatureOrder)
    }

    var body: some View {
        VStack(spacing: 0) {
            MainTabHeaderView(title: L10n.Home.title)
                .padding(.vertical)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(orderedTools.enumerated()), id: \.element.id) { index, tool in
                            if shouldShowAdvancedHeader(before: index) {
                                Text(L10n.Home.advancedEditing)
                                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                                    .foregroundColor(.DesignSystem.silverSand)
                                    .kerning(1.2)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }

                            HomeToolRow(tool: tool) {
                                handleNavigation(for: tool)
                            }
                        }
                    }

                    Spacer(minLength: 60)
                }
                .padding(.vertical)
            } // Close ScrollView
        } // Close VStack
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .ratingPopup(isPresented: $isShowingHomeRating, kind: .homeEnjoyment) {
            AppLogger.logAction("Home Rating", details: "Rate on App Store")
            TrackingManager.shared.trackRateApp(screen: .home, trigger: .homeBanner)
        }
        .onAppear {
            AppLogger.logScreen("HomeView")
            TrackingManager.shared.trackScreen(.home)
            presentHomeRatingIfNeeded()
        }
    }
    
    private func handleNavigation(for tool: HomeToolItem) {
        if let feature = TrackingManager.Feature(projectType: tool.projectType) {
            TrackingManager.shared.trackSelectFeature(feature: feature, screen: .home)
        }
        coordinator.openFlow(tool.projectType)
    }

    private func shouldShowAdvancedHeader(before index: Int) -> Bool {
        let tools = orderedTools
        guard tools.indices.contains(index), tools[index].isPro else { return false }
        return !tools[..<index].contains { $0.isPro }
    }

    private func presentHomeRatingIfNeeded() {
        guard RatingPromptTracker.shouldShowHomePromptOnAppear() else { return }
        isShowingHomeRating = true
    }
}

struct HomeToolRow: View {
    let tool: HomeToolItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(tool.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.85)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Image(systemName: tool.iconName)
                                        .font(.headline)
                                    Text(tool.title)
                                        .font(FontFamily.Roboto.bold.swiftUIFont(size: 17))
                                }
                                .foregroundColor(.white)
                                
                                Text(tool.subtitle)
                                    .font(FontFamily.Roboto.regular.swiftUIFont(size: 15))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(20)
                    }
                )
                .cornerRadius(24)
                .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environment(AppCoordinator())
}
