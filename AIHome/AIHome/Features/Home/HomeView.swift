import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                Text("Dashboard")
                    .font(.DesignSystem.title1)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Primary Tools")
                        .font(.DesignSystem.title2)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.primaryTools) { tool in
                        HomeToolRow(tool: tool) {
                            handleNavigation(for: tool)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Advanced Editing")
                        .font(.DesignSystem.title2)
                        .padding(.horizontal)
                    
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
        .onAppear {
            AppLogger.logScreen("HomeView")
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
}

struct HomeToolRow: View {
    let tool: HomeToolItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: tool.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.DesignSystem.primary)
                    .padding(12)
                    .background(Color.DesignSystem.surface)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(tool.title)
                        .font(.DesignSystem.headline)
                        .foregroundColor(.DesignSystem.textPrimary)
                    
                    Text(tool.subtitle)
                        .font(.DesignSystem.caption)
                        .foregroundColor(.DesignSystem.textSecondary)
                }
                
                Spacer()
                
                if tool.isPro {
                    Text("PRO")
                        .font(.caption2)
                        .bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.DesignSystem.accent)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.DesignSystem.textSecondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.DesignSystem.background)
        }
    }
}

#Preview {
    HomeView()
}
