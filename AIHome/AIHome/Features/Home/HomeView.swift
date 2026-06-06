import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var isShowingHomeRating = false
    @State private var hasShownHomeRating = false
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                HStack {
                    Text("Home")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.DesignSystem.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .foregroundColor(Color(red: 255/255, green: 45/255, blue: 85/255))
                            Text("3/3")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.DesignSystem.textPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(20)
                        
                        Text("PRO")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(red: 255/255, green: 45/255, blue: 85/255))
                            .cornerRadius(20)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.primaryTools) { tool in
                        HomeToolRow(tool: tool) {
                            handleNavigation(for: tool)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("ADVANCED EDITING")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Color(UIColor.systemGray2))
                        .kerning(1.2)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    ForEach(viewModel.advancedTools) { tool in
                        HomeToolRow(tool: tool) {
                            handleNavigation(for: tool)
                        }
                    }
                }
                
            }
            .padding(.vertical)
        }
        .background(Color.DesignSystem.background.ignoresSafeArea())
        .ratingPopup(isPresented: $isShowingHomeRating, kind: .homeEnjoyment) {
            AppLogger.logAction("Home Rating", details: "Rate on App Store")
        }
        .onAppear {
            AppLogger.logScreen("HomeView")
            presentHomeRatingIfNeeded()
        }
    }
    
    private func handleNavigation(for tool: HomeToolItem) {
        switch tool.projectType {
        case .interior: coordinator.push(.interiorFlow)
        case .exterior: coordinator.push(.exteriorFlow)
        case .garden: coordinator.push(.gardenFlow)
        case .referenceStyle: coordinator.push(.referenceStyleFlow)
        case .removeObjects: coordinator.push(.removeObjectsFlow)
        case .replaceObjects: coordinator.push(.replaceObjectsFlow)
        case .newFlooring: coordinator.push(.newFlooringFlow)
        case .newWalls: coordinator.push(.newWallsFlow)
        }
    }

    private func presentHomeRatingIfNeeded() {
        guard !hasShownHomeRating else { return }
        hasShownHomeRating = true
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
                                        .font(.headline.weight(.bold))
                                }
                                .foregroundColor(.white)
                                
                                Text(tool.subtitle)
                                    .font(.subheadline)
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
