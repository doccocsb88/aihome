import Photos
import SwiftUI

struct ResultView: View {
    @Bindable var viewModel: ResultViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @State private var userManager = UserManager.shared
    @State private var showingBefore = false
    @State private var shareItem: ResultShareItem?
    @State private var alertItem: ResultAlertItem?
    @State private var isShowingArchiveToast = false
    @State private var isShowingResultRating = false

    var onRegenerate: () -> Void
    var onDownload: (UIImage) -> Void
    var onShare: (UIImage) -> Void
    var onSaveArchive: () -> Void
    var onRemoveWatermark: () -> Void
    var onToolSelected: (ProjectType, UIImage) -> Void
    var onClose: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView

                VStack(spacing: 4) {
                    ScrollView(.vertical) {
                        VStack(spacing: 4) {
                            imageSection
                                .padding(.horizontal, 24)

                            advancedToolsSection
                                .padding(.horizontal, 24)

                            actionButtonsSection

                            Spacer(minLength: 16)

                        }
                    }
                    saveToArchiveButton
                }
            }

            if isShowingArchiveToast {
                archiveToast
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
                    .zIndex(2)
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
                dismissButton: .default(Text(L10n.Common.ok))
            )
        }
        .ratingPopup(isPresented: $isShowingResultRating, kind: .resultFeedback) {
            AppLogger.logAction("Result Rating", details: "Rate on App Store")
        }
        .onAppear {
            presentResultRatingIfNeeded()
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
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
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
                            ResultFeedbackButton(
                                imageName: "hand.thumbsup.fill",
                                isSelected: viewModel.selectedFeedback == .positive
                            ) {
                                selectFeedback(.positive)
                            }
                            ResultFeedbackButton(
                                imageName: "hand.thumbsdown.fill",
                                isSelected: viewModel.selectedFeedback == .negative
                            ) {
                                selectFeedback(.negative)
                            }
                        }
                        Spacer()
                        if userManager.isFreeUser {
                            RemoveWatermarkButton()
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    @ViewBuilder
    private var advancedToolsSection: some View {
        if !viewModel.availableAdvancedTools.isEmpty {
            AdvancedToolsSection(
                tools: viewModel.availableAdvancedTools,
                horizontalPadding: 0,
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
    }

    @ViewBuilder
    private var saveToArchiveButton: some View {
        if !viewModel.isArchived {
            Button(action: handleSaveArchive) {
                Text(L10n.Result.saveToArchive)
                    .font(FontFamily.Roboto.bold.swiftUIFont(size: 12))
                    .kerning(2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.black)
                    .cornerRadius(20)
                    .shadow(color: Color(red: 17/255, green: 24/255, blue: 39/255).opacity(0.15), radius: 30, x: 0, y: 10)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 8)
        }
    }

    private var archiveToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

            Text(NSLocalizedString("result.archive_success.title", comment: ""))
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 14))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background {
            Capsule()
                .fill(Color.black.opacity(0.86))
                .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 8)
        }
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
                    .padding(20)
                    .background(Circle().fill(Color(UIColor.systemGray6)))
            }
            Text(title)
                .font(FontFamily.Roboto.bold.swiftUIFont(size: 10))
                .kerning(0.5)
                .foregroundColor(Color(UIColor.systemGray2))
        }
    }

    private func handleNavigation(for tool: ProjectType) {
        if tool == .edit {
            onRegenerate()
            return
        }

        coordinator.popToRoot()

        let initialImageID = viewModel.selectedImage.map { coordinator.storeInitialImage($0) }

        switch tool {
        case .interior:
            coordinator.push(initialImageID.map(AppRoute.interiorFlowWithImage) ?? .interiorFlow)
        case .exterior:
            coordinator.push(initialImageID.map(AppRoute.exteriorFlowWithImage) ?? .exteriorFlow)
        case .garden:
            coordinator.push(initialImageID.map(AppRoute.gardenFlowWithImage) ?? .gardenFlow)
        case .referenceStyle:
            coordinator.push(initialImageID.map(AppRoute.referenceStyleFlowWithImage) ?? .referenceStyleFlow)
        case .removeObjects:
            coordinator.push(initialImageID.map(AppRoute.removeObjectsFlowWithImage) ?? .removeObjectsFlow)
        case .replaceObjects:
            coordinator.push(initialImageID.map(AppRoute.replaceObjectsFlowWithImage) ?? .replaceObjectsFlow)
        case .newFlooring:
            coordinator.push(initialImageID.map(AppRoute.newFlooringFlowWithImage) ?? .newFlooringFlow)
        case .newWalls:
            coordinator.push(initialImageID.map(AppRoute.newWallsFlowWithImage) ?? .newWallsFlow)
        case .furnitureFinder:
            coordinator.push(initialImageID.map(AppRoute.furnitureFinderFlowWithImage) ?? .furnitureFinderFlow)
        case .edit:
            break
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
                    title: L10n.Result.SaveSuccess.title,
                    message: L10n.Result.SaveSuccess.message
                )
                AppLogger.logAction("Result Image Downloaded")
            } catch {
                alertItem = ResultAlertItem(
                    title: L10n.Result.SaveFailure.title,
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

    private func handleSaveArchive() {
        do {
            let savedProject = try GenerationHistoryRecorder.save(
                project: viewModel.project,
                originalImage: viewModel.originalImage,
                generatedImages: viewModel.generatedImages
            )

            viewModel.project = savedProject
            viewModel.isArchived = true
            onSaveArchive()
            showArchiveToast()
            AppLogger.logAction("Result Saved To Archive")
        } catch {
            alertItem = ResultAlertItem(
                title: L10n.Result.SaveFailure.title,
                message: error.localizedDescription
            )
            AppLogger.logError("Result Save To Archive Failed", error: error)
        }
    }

    private func showArchiveToast() {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
            isShowingArchiveToast = true
        }

        Task {
            try? await Task.sleep(nanoseconds: 1_600_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.2)) {
                    isShowingArchiveToast = false
                }
            }
        }
    }

    private func selectFeedback(_ feedback: ResultFeedbackAction) {
        viewModel.selectedFeedback = feedback
        AppLogger.logAction("Result Feedback Selected", details: "\(feedback)")
    }

    private func presentResultRatingIfNeeded() {
        guard viewModel.isGeneratedResult,
              RatingPromptTracker.shouldShowFirstResultPrompt() else {
            return
        }

        isShowingResultRating = true
    }
}

private struct ResultFeedbackButton: View {
    let imageName: String
    let isSelected: Bool
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
                        .fill(isSelected ? Color.DesignSystem.folly : Color.black.opacity(0.25))
                        .overlay {
                            if !isSelected {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .environment(\.colorScheme, .dark)
                            }
                        }
                }
                .overlay {
                    Circle()
                        .stroke(isSelected ? .white.opacity(0.6) : .white.opacity(0.2), lineWidth: 1)
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
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color(red: 243/255, green: 244/255, blue: 246/255), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 25)
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
            L10n.Result.SaveFailure.photoAccessRequired
        case .saveFailed:
            L10n.Result.SaveFailure.message
        }
    }
}
