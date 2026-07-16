import SwiftUI

enum ExteriorFlowState {
    case input
    case loading(GenerationLoadingViewModel)
    case result(ResultViewModel)
}

struct ExteriorFlowContainerView: View {
    @State private var state: ExteriorFlowState = .input
    @State private var currentDraft: ExteriorDraft? = nil
    @State private var pendingConsentDraft: ExteriorDraft?
    @State private var isShowingAIProcessingConsent = false
    @State private var isShowingLimitPopup = false
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    var initialImage: UIImage?

    var body: some View {
        Group {
            switch state {
            case .input:
                ExteriorFlowView(initialImage: currentDraft?.sourceImage ?? initialImage, onGenerate: { draft in
                    requestGeneration(with: draft)
                })
                .onAppear {
                    TrackingManager.shared.trackScreen(.photoPicker, params: ["feature": TrackingManager.Feature.exterior.rawValue])
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

    private func requestGeneration(with draft: ExteriorDraft) {
        guard AIProcessingConsentStore.hasAccepted else {
            pendingConsentDraft = draft
            isShowingAIProcessingConsent = true
            return
        }

        startGeneration(with: draft)
    }

    private func startGeneration(with draft: ExteriorDraft) {
        self.currentDraft = draft
        guard let sourceImage = draft.sourceImage else {
            AppLogger.logError("Missing required draft data")
            return
        }
        guard UserManager.shared.canUsePremiumFeature else {
            isShowingLimitPopup = true
            return
        }

        AppLogger.logAction("Start Exterior Generation", details: "Prompt: \(draft.prompt)")
        let startedAt = Date()
        TrackingManager.shared.trackGenerationStart(
            feature: .exterior,
            screen: .photoPicker,
            style: "Modern",
            aiIntervention: UIInterventionLevel.medium.rawValue,
            trigger: .new
        )
        TrackingManager.shared.trackScreen(.generating, params: ["feature": TrackingManager.Feature.exterior.rawValue])

        let loadingVM = GenerationLoadingViewModel(projectType: .exterior, status: .generating, progressText: L10n.GenerationLoading.generating, canCancel: true, inputImage: sourceImage)
        self.state = .loading(loadingVM)

        Task {
            do {
                guard let imageSource = GenerationImageEncoder.encode(sourceImage) else {
                    throw NSError(domain: "GenerationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
                
                let request = ExteriorGenerationInput(
                    image: imageSource,
                    aiIntervention: .mid, // Default
                    noDesign: 1,
                    designStyle: "Modern", // Default
                    houseAngle: draft.houseAngle.rawValue,
                    customInstruction: draft.prompt
                )

                let imageUrls = try await HomeGPTAIService.shared.generateExterior(request: request)
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
                TrackingManager.shared.trackGenerationSuccess(feature: .exterior, style: "Modern", durationMs: durationMs)

                let mockProject = LocalProject(
                    id: UUID().uuidString,
                    type: .exterior,
                    title: "Exterior Redesign",
                    styleName: "Modern",
                    roomType: "Exterior",
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
                let failure = failureDetails(for: error)
                AppLogger.logError("Generation Failed", error: error)
                let durationMs = Int(Date().timeIntervalSince(startedAt) * 1000)
                TrackingManager.shared.trackGenerationFail(feature: .exterior, errorType: .init(error: error), durationMs: durationMs)
                await MainActor.run {
                    loadingVM.status = .failed
                    loadingVM.errorMessage = failure.message
                    loadingVM.canRetry = failure.canRetry
                }
            }
        }
    }

    private func failureDetails(for error: Error) -> (message: String, canRetry: Bool) {
        if let apiError = error as? HomeDesignsAPIError,
           case .server(let statusCode, let responseBody) = apiError,
           statusCode == 422 {
            let message = responseBody?.contains("house_angle") == true
                ? L10n.GenerationLoading.Failure.exteriorPhotoMessage
                : L10n.GenerationLoading.Failure.message
            return (message, false)
        }

        let message = (error as? HomeDesignsAPIError)?.localizedDescription ?? error.localizedDescription
        return (message, true)
    }
}
