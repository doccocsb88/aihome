import SwiftUI

struct ResultView: View {
    @Bindable var viewModel: ResultViewModel
    @Environment(AppCoordinator.self) private var coordinator
    
    
    var onRegenerate: () -> Void
    var onDownload: (UIImage) -> Void
    var onShare: (UIImage) -> Void
    var onSaveArchive: () -> Void
    var onRemoveWatermark: () -> Void
    var onToolSelected: (ProjectType, UIImage) -> Void
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            VStack(spacing: 4) {
                imageSection
                advancedToolsSection
                actionButtonsSection
                
                Spacer(minLength: 16)
                
                saveToArchiveButton
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            if viewModel.isPro {
                Text(L10n.Result.pro)
                    .font(FontFamily.Roboto.black.swiftUIFont(size: 11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.pink)
                    .clipShape(Capsule())
                    .shadow(color: Color.pink.opacity(0.5), radius: 5, x: 0, y: 3)
            } else {
                Spacer().frame(width: 40)
            }
            
            Spacer()
            Text(L10n.Result.title)
                .font(FontFamily.Roboto.medium.swiftUIFont(size: 17))
            Spacer()
            
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder
    private var imageSection: some View {
        if let selectedImage = viewModel.selectedImage {
            ZStack {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(24)
                
                // Top left overlay
                VStack {
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "square.split.2x1")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(16)
                
                // Bottom overlays
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        HStack(spacing: 8) {
                            Button(action: {}) {
                                Image(systemName: "hand.thumbsup.fill")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .environment(\.colorScheme, .dark)
                                            .overlay(Circle().fill(Color.black.opacity(0.25)))
                                    )
                                    .overlay(
                                        Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            Button(action: {}) {
                                Image(systemName: "hand.thumbsdown.fill")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .environment(\.colorScheme, .dark)
                                            .overlay(Circle().fill(Color.black.opacity(0.25)))
                                    )
                                    .overlay(
                                        Circle().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 6) {
                            if viewModel.hasWatermark {
                                Button(action: onRemoveWatermark) {
                                    HStack(spacing: 4) {
                                        Image("ic_result_watermark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 14, height: 14)
                                        Text(L10n.Result.removeWatermark)
                                            .font(FontFamily.Roboto.bold.swiftUIFont(size: 10))
                                    }
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(.ultraThinMaterial)
                                            .environment(\.colorScheme, .light)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.white.opacity(0.4))
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 16)
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
        }
    }
    
    @ViewBuilder
    private var advancedToolsSection: some View {
        if !viewModel.availableAdvancedTools.isEmpty {
            AdvancedToolsSection(
                tools: viewModel.availableAdvancedTools,
                onSelect: { tool in
                    handleNavigation(for: tool)
                    
                    if let image = viewModel.selectedImage {
                        onToolSelected(tool, image)
                    }
                }
            )
        }
    }
    
    @ViewBuilder
    private var actionButtonsSection: some View {
        HStack(spacing: 0) {
            actionCircleButton(title: L10n.Result.regenerate, icon: "ic_result_regenerate", action: onRegenerate)
            Spacer()
            actionCircleButton(title: L10n.Result.download, icon: "ic_result_download", action: {
                if let img = viewModel.selectedImage { onDownload(img) }
            })
            Spacer()
            actionCircleButton(title: L10n.Result.share, icon: "ic_result_share", action: {
                if let img = viewModel.selectedImage { onShare(img) }
            })
        }
        .padding(.horizontal, 40)
        .padding(.top, 10)
    }
    
    @ViewBuilder
    private var saveToArchiveButton: some View {
        Button(action: onSaveArchive) {
            Text(L10n.Result.saveToArchive)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.black)
                .cornerRadius(20)
                .shadow(color: Color(red: 17/255, green: 24/255, blue: 39/255).opacity(0.15), radius: 30, x: 0, y: 10)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func actionCircleButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Button(action: action) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.primary)
                    .padding(24)
                    .background(Circle().fill(Color(UIColor.systemGray6)))
            }
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 10))
                .kerning(0.5)
                .foregroundColor(Color(UIColor.systemGray2))
        }
    }
    
    private func handleNavigation(for tool: ProjectType) {
        if tool != .edit {
            coordinator.popToRoot()
        }
        
        switch tool {
        case .interior: coordinator.push(.interiorFlow)
        case .exterior: coordinator.push(.exteriorFlow)
        case .garden: coordinator.push(.gardenFlow)
        case .referenceStyle: coordinator.push(.referenceStyleFlow)
        case .removeObjects: coordinator.push(.removeObjectsFlow)
        case .replaceObjects: coordinator.push(.replaceObjectsFlow)
        case .newFlooring: coordinator.push(.newFlooringFlow)
        case .newWalls: coordinator.push(.newWallsFlow)
        case .furnitureFinder: coordinator.push(.furnitureFinderFlow)
        case .edit:
            onRegenerate()
        }
    }
}
