import Photos
import SwiftUI

struct ResultView: View {
    @Bindable var viewModel: ResultViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var userManager = UserManager.shared
    @State private var showingBefore = false
    @State private var shareItem: ResultShareItem?
    @State private var alertItem: ResultAlertItem?
    
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
        .sheet(item: $shareItem) { item in
            ResultShareSheet(activityItems: [item.image])
        }
        .alert(item: $alertItem) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            if userManager.isFreeUser {
                AdaptyPaywallButton(placement: .proButton) { isLoading in
                    HStack(spacing: 5) {
                        if isLoading {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        }

                        Text(L10n.Result.pro)
                            .font(FontFamily.Roboto.black.swiftUIFont(size: 11))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.pink)
                    .clipShape(Capsule())
                    .shadow(color: Color.pink.opacity(0.5), radius: 5, x: 0, y: 3)
                }
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
                ResultBeforeAfterImage(
                    beforeImage: viewModel.originalImage,
                    afterImage: selectedImage,
                    showingBefore: showingBefore,
                    showsWatermark: userManager.isFreeUser
                )
                .frame(maxWidth: .infinity)
                
                // Top left overlay
                VStack {
                    HStack {
                        BeforeAfterButton(showingBefore: $showingBefore)
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
                            ResultFeedbackButton(imageName: "hand.thumbsup.fill") { }
                            ResultFeedbackButton(imageName: "hand.thumbsdown.fill") { }
                        }
                        Spacer()
                        if userManager.isFreeUser {
                            RemoveWatermarkButton()
                        }
                    }
                }
                .padding(16)
            }
            .padding(.horizontal, 16)
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
                if let img = viewModel.selectedImage {
                    handleDownload(img)
                }
            })
            Spacer()
            actionCircleButton(title: L10n.Result.share, icon: "ic_result_share", action: {
                if let img = viewModel.selectedImage {
                    handleShare(img)
                }
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

    private func handleDownload(_ image: UIImage) {
        Task {
            do {
                let downloadImage = userManager.isFreeUser
                    ? ResultWatermarkRenderer.apply(to: image) ?? image
                    : image

                try await ResultPhotoLibrarySaver.save(downloadImage)
                onDownload(downloadImage)
                alertItem = ResultAlertItem(
                    title: "Saved",
                    message: "The image has been saved to your photo gallery."
                )
                AppLogger.logAction("Result Image Downloaded")
            } catch {
                alertItem = ResultAlertItem(
                    title: "Save Failed",
                    message: error.localizedDescription
                )
                AppLogger.logError("Result Image Download Failed", error: error)
            }
        }
    }

    private func handleShare(_ image: UIImage) {
        shareItem = ResultShareItem(image: image)
        onShare(image)
        AppLogger.logAction("Result Share Sheet Opened")
    }
}

private struct ResultFeedbackButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 16, height: 16)
                .padding(12)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                        .overlay {
                            Circle()
                                .fill(.black.opacity(0.25))
                        }
                }
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

private struct ResultBeforeAfterImage: View {
    let beforeImage: UIImage
    let afterImage: UIImage
    let showingBefore: Bool
    let showsWatermark: Bool

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .overlay {
                GeometryReader { proxy in
                    ZStack {
                        resultImage(beforeImage, size: proxy.size)
//                        resultImage(afterImage, size: proxy.size)
                        Image(uiImage: afterImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: showingBefore ? 0 : proxy.size.width, height: proxy.size.height)
                            .clipped()
                        if showsWatermark {
                            WatermarkView()
                                .frame(width: proxy.size.width, height: proxy.size.height)

                        }
                        
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .animation(.easeInOut(duration: 0.55), value: showingBefore)
    }

    private func resultImage(_ image: UIImage, size: CGSize) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
    }
}

struct WatermarkView: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { _ in
                            Image("result_watermark_tile")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: proxy.size.width / 3,
                                    height: proxy.size.height / 3
                                )
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

@MainActor
private enum ResultWatermarkRenderer {
    static func apply(to image: UIImage) -> UIImage? {
        guard image.size.width > 0, image.size.height > 0 else { return nil }

        let content = ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: image.size.width, height: image.size.height)
                .clipped()

            WatermarkView()
        }
        .frame(width: image.size.width, height: image.size.height)

        let renderer = ImageRenderer(content: content)
        renderer.scale = image.scale
        return renderer.uiImage
    }
}

private struct RemoveWatermarkButton: View {
    var body: some View {
        AdaptyPaywallButton(placement: .watermark) { isLoading in
            HStack(spacing: 4) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Image("ic_result_watermark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                }

                Text(L10n.Result.removeWatermark.uppercased())
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 9))
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .light)
                    .overlay {
                        Capsule()
                            .fill(.white.opacity(0.4))
                    }
            }
            .overlay {
                Capsule()
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            }
        }
        .accessibilityLabel(L10n.Result.removeWatermark)
    }
}

private struct ResultShareItem: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct ResultAlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private struct ResultShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

private enum ResultPhotoLibrarySaver {
    static func save(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw ResultPhotoLibraryError.accessDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: ResultPhotoLibraryError.saveFailed)
                }
            }
        }
    }
}

private enum ResultPhotoLibraryError: LocalizedError {
    case accessDenied
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .accessDenied:
            "Photo library access is required to save this image."
        case .saveFailed:
            "The image could not be saved to your photo gallery."
        }
    }
}
