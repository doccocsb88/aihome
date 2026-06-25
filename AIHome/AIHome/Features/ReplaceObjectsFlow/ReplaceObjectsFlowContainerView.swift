import SwiftUI

enum ReplaceObjectsFlowState {
    case input
    case loading(GenerationLoadingViewModel)
    case result(ResultViewModel)
}

struct ReplaceObjectsFlowContainerView: View {
    @State private var state: ReplaceObjectsFlowState = .input
    @State private var currentDraft: ReplaceObjectsDraft? = nil
    @State private var isShowingLimitPopup = false
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var initialImage: UIImage?

    var body: some View {
        Group {
            switch state {
            case .input:
                ReplaceObjectsFlowView(initialImage: currentDraft?.sourceImage ?? initialImage, onGenerate: { draft in
                    startGeneration(with: draft)
                })
            case .loading(let viewModel):
                GenerationLoadingView(
                    viewModel: viewModel,
                    onRetry: {
                        if let draft = currentDraft {
                            startGeneration(with: draft)
                        }
                    },
                    onCancel: {
                        state = .input
                    }
                )
            case .result(let viewModel):
                ResultView(
                    viewModel: viewModel,
                    onRegenerate: {
                        state = .input
                    },
                    onDownload: { _ in },
                    onShare: { _ in },
                    onSaveArchive: { },
                    onRemoveWatermark: { },
                    onToolSelected: { _, _ in },
                    onClose: { dismiss() }
                )
            }
        }
        .generationUsageLimit(isPresented: $isShowingLimitPopup)
    }

    private func startGeneration(with draft: ReplaceObjectsDraft) {
        self.currentDraft = draft
        guard let sourceImage = draft.sourceImage else {
            AppLogger.logError("Missing required draft data")
            return
        }
        guard UserManager.shared.canUsePremiumFeature else {
            isShowingLimitPopup = true
            return
        }

        AppLogger.logAction("Start Replace Objects Generation", details: "Prompt: \(draft.prompt)")

        let loadingVM = GenerationLoadingViewModel(projectType: .replaceObjects, status: .generating, progressText: "Generating...", canCancel: true, inputImage: sourceImage)
        self.state = .loading(loadingVM)

        Task {
            do {
                guard let imageSource = GenerationImageEncoder.encode(sourceImage) else {
                    throw NSError(domain: "GenerationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }

                let request = ReplaceObjectsInput(
                    image: imageSource,
                    prompt: draft.prompt,
                    noDesign: 1
                )

                let imageUrls = try await HomeGPTAIService.shared.replaceObjects(request: request)
                AppLogger.logAction("Received image URLs from API", details: "\(imageUrls.count) images")

                var downloadedImages: [UIImage] = []
                for urlString in imageUrls {
                    if let url = URL(string: urlString) {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            downloadedImages.append(image)
                        }
                    }
                }

                guard !downloadedImages.isEmpty else {
                    throw NSError(domain: "GenerationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to download images"])
                }

                AppLogger.logAction("Images downloaded successfully")

                let mockProject = LocalProject(
                    id: UUID().uuidString,
                    type: .replaceObjects,
                    title: "Replace Objects",
                    styleName: "Custom",
                    roomType: "Room",
                    createdAt: Date(),
                    originalImagePath: "",
                    generatedImagePaths: [],
                    selectedGeneratedImagePath: nil,
                    isFavorite: false
                )

                let didConsumeUsage = await MainActor.run {
                    guard UserManager.shared.consumeUsageIfAllowed() else {
                        self.isShowingLimitPopup = true
                        self.state = .input
                        return false
                    }
                    return true
                }
                guard didConsumeUsage else { return }

                let resultVM = ResultViewModel(
                    project: mockProject,
                    originalImage: sourceImage,
                    generatedImages: downloadedImages,
                    availableAdvancedTools: ProjectType.resultAdvancedTools,
                    isPro: true,
                    hasWatermark: false
                )

                await MainActor.run {
                    self.state = .result(resultVM)
                }
            } catch {
                let errorMessage = (error as? HomeDesignsAPIError)?.localizedDescription ?? error.localizedDescription
                AppLogger.logError("Generation Failed", error: error)
                await MainActor.run {
                    loadingVM.status = .failed
                    loadingVM.errorMessage = errorMessage
                }
            }
        }
    }
}
