import SwiftUI

enum NewFlooringFlowState {
    case input
    case loading(GenerationLoadingViewModel)
    case result(ResultViewModel)
}

struct NewFlooringFlowContainerView: View {
    @State private var state: NewFlooringFlowState = .input
    @State private var currentDraft: NewFlooringDraft? = nil
    @State private var pendingConsentDraft: NewFlooringDraft?
    @State private var isShowingAIProcessingConsent = false
    @State private var isShowingLimitPopup = false
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var initialImage: UIImage?

    var body: some View {
        Group {
            switch state {
            case .input:
                NewFlooringFlowView(initialImage: currentDraft?.sourceImage ?? initialImage, onGenerate: { draft in
                    requestGeneration(with: draft)
                })
                .onAppear {
                    TrackingManager.shared.trackScreen(.photoPicker, params: ["feature": TrackingManager.Feature.newFlooring.rawValue])
                }
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

    private func requestGeneration(with draft: NewFlooringDraft) {
        guard AIProcessingConsentStore.hasAccepted else {
            pendingConsentDraft = draft
            isShowingAIProcessingConsent = true
            return
        }

        startGeneration(with: draft)
    }

    private func startGeneration(with draft: NewFlooringDraft) {
        self.currentDraft = draft
        guard let sourceImage = draft.sourceImage else {
            AppLogger.logError("Missing required draft data")
            return
        }
        guard UserManager.shared.canUsePremiumFeature else {
            isShowingLimitPopup = true
            return
        }

        AppLogger.logAction("Start New Flooring Generation", details: "Prompt: \(draft.prompt)")
        let startedAt = Date()
        TrackingManager.shared.trackGenerationStart(
            feature: .newFlooring,
            screen: .photoPicker,
            style: "Custom",
            trigger: .new
        )
        TrackingManager.shared.trackScreen(.generating, params: ["feature": TrackingManager.Feature.newFlooring.rawValue])

        let loadingVM = GenerationLoadingViewModel(projectType: .newFlooring, status: .generating, progressText: L10n.GenerationLoading.generating, canCancel: true, inputImage: sourceImage)
        self.state = .loading(loadingVM)

        Task {
            do {
                guard let imageSource = GenerationImageEncoder.encode(sourceImage) else {
                    throw NSError(domain: "GenerationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }

                let request = NewFlooringInput(
                    image: imageSource,
                    textureImage: nil,
                    noOfTexture: "1",
                    prompt: draft.prompt
                )

                let imageUrls = try await HomeGPTAIService.shared.generateNewFlooring(request: request)
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
                let durationMs = Int(Date().timeIntervalSince(startedAt) * 1000)
                TrackingManager.shared.trackGenerationSuccess(feature: .newFlooring, style: "Custom", durationMs: durationMs)

                let mockProject = LocalProject(
                    id: UUID().uuidString,
                    type: .newFlooring,
                    title: "New Flooring",
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
                let durationMs = Int(Date().timeIntervalSince(startedAt) * 1000)
                TrackingManager.shared.trackGenerationFail(feature: .newFlooring, errorType: .init(error: error), durationMs: durationMs)
                await MainActor.run {
                    loadingVM.status = .failed
                    loadingVM.errorMessage = errorMessage
                }
            }
        }
    }
}
