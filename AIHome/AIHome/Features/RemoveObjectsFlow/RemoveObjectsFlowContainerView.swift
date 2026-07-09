import SwiftUI

enum RemoveObjectsFlowState {
    case input
    case loading(GenerationLoadingViewModel)
    case result(ResultViewModel)
}

struct RemoveObjectsFlowContainerView: View {
    @State private var state: RemoveObjectsFlowState = .input
    @State private var currentDraft: RemoveObjectsDraft? = nil
    @State private var pendingConsentDraft: RemoveObjectsDraft?
    @State private var isShowingAIProcessingConsent = false
    @State private var isShowingLimitPopup = false
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var initialImage: UIImage?

    var body: some View {
        Group {
            switch state {
            case .input:
                RemoveObjectsFlowView(initialImage: currentDraft?.sourceImage ?? initialImage, onGenerate: { draft in
                    requestGeneration(with: draft)
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
        .aiProcessingConsentSheet(isPresented: $isShowingAIProcessingConsent) {
            guard let draft = pendingConsentDraft else { return }
            pendingConsentDraft = nil
            startGeneration(with: draft)
        }
    }

    private func requestGeneration(with draft: RemoveObjectsDraft) {
        guard AIProcessingConsentStore.hasAccepted else {
            pendingConsentDraft = draft
            isShowingAIProcessingConsent = true
            return
        }

        startGeneration(with: draft)
    }

    private func startGeneration(with draft: RemoveObjectsDraft) {
        self.currentDraft = draft
        guard let sourceImage = draft.sourceImage else {
            AppLogger.logError("Missing required draft data")
            return
        }
        guard UserManager.shared.canUsePremiumFeature else {
            isShowingLimitPopup = true
            return
        }

        AppLogger.logAction("Start Remove Objects Generation", details: "Prompt: \(draft.prompt)")

        let loadingVM = GenerationLoadingViewModel(projectType: .removeObjects, status: .generating, progressText: L10n.GenerationLoading.generating, canCancel: true, inputImage: sourceImage)
        self.state = .loading(loadingVM)

        Task {
            do {
                guard let imageSource = GenerationImageEncoder.encode(sourceImage) else {
                    throw NSError(domain: "GenerationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }

                let request = RemoveObjectsInput(
                    image: imageSource,
                    prompt: draft.prompt
                )

                let imageUrls = try await HomeGPTAIService.shared.removeObjects(request: request)
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
                    type: .removeObjects,
                    title: "Remove Objects",
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
