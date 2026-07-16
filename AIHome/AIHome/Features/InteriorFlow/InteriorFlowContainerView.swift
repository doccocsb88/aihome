import SwiftUI

enum InteriorFlowState {
    case input
    case loading(GenerationLoadingViewModel)
    case result(ResultViewModel)
}

struct InteriorFlowContainerView: View {
    @State private var state: InteriorFlowState = .input
    @State private var currentDraft: InteriorDraft? = nil
    @State private var pendingConsentDraft: InteriorDraft?
    @State private var isShowingAIProcessingConsent = false
    @State private var isShowingLimitPopup = false
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    var initialImage: UIImage?

    var body: some View {
        Group {
            switch state {
            case .input:
                InteriorFlowView(initialImage: currentDraft?.sourceImage ?? initialImage, onGenerate: { draft in
                    requestGeneration(with: draft)
                })
                .onAppear {
                    TrackingManager.shared.trackScreen(.photoPicker, params: ["feature": TrackingManager.Feature.interior.rawValue])
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

    private func requestGeneration(with draft: InteriorDraft) {
        guard AIProcessingConsentStore.hasAccepted else {
            pendingConsentDraft = draft
            isShowingAIProcessingConsent = true
            return
        }

        startGeneration(with: draft)
    }

    private func startGeneration(with draft: InteriorDraft) {
        self.currentDraft = draft
        guard let sourceImage = draft.sourceImage,
              let roomType = draft.roomType,
              let designStyle = draft.designStyle,
              let interventionLevel = draft.intervention else {
            AppLogger.logError("Missing required draft data")
            return
        }

        let isCustomStyle = designStyle == .noStyle
        let customStylePrompt = draft.customStyle?.trimmingCharacters(in: .whitespacesAndNewlines)
        if isCustomStyle && (customStylePrompt?.isEmpty ?? true) {
            AppLogger.logError("Missing custom style prompt")
            return
        }
        guard UserManager.shared.canUsePremiumFeature else {
            isShowingLimitPopup = true
            return
        }
        let requestDesignStyle = isCustomStyle ? "Modern" : designStyle.rawValue
        let requestCustomInstruction = isCustomStyle ? customStylePrompt : nil
        let displayStyle = isCustomStyle ? (customStylePrompt ?? L10n.Interior.CustomStyle.title) : designStyle.rawValue

        let aiIntervention: AIIntervention
        switch interventionLevel {
        case .light: aiIntervention = .low
        case .medium: aiIntervention = .mid
        case .high: aiIntervention = .extreme
        }

        AppLogger.logAction("Start Interior Generation", details: "Room: \(roomType.rawValue), Style: \(displayStyle), Intervention: \(aiIntervention.rawValue)")
        let startedAt = Date()
        TrackingManager.shared.trackGenerationStart(
            feature: .interior,
            screen: .photoPicker,
            roomType: roomType.rawValue,
            style: displayStyle,
            aiIntervention: interventionLevel.rawValue,
            trigger: .new
        )
        TrackingManager.shared.trackScreen(.generating, params: ["feature": TrackingManager.Feature.interior.rawValue])

        let loadingVM = GenerationLoadingViewModel(projectType: .interior, status: .generating, progressText: L10n.GenerationLoading.generating, canCancel: true, inputImage: sourceImage)
        self.state = .loading(loadingVM)

        Task {
            do {
                guard let imageSource = GenerationImageEncoder.encode(sourceImage) else {
                    throw NSError(domain: "GenerationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
                
                let request = InteriorGenerationInput(
                    image: imageSource,
                    aiIntervention: aiIntervention,
                    noDesign: 1, // Generate 1 image for MVP
                    designStyle: requestDesignStyle,
                    roomType: roomType.rawValue,
                    customInstruction: requestCustomInstruction
                )

                let imageUrls = try await HomeGPTAIService.shared.generateInterior(request: request)
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
                TrackingManager.shared.trackGenerationSuccess(feature: .interior, style: displayStyle, durationMs: durationMs)

                let mockProject = LocalProject(
                    id: UUID().uuidString,
                    type: .interior,
                    title: "Interior Design",
                    styleName: displayStyle,
                    roomType: roomType.rawValue,
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
                TrackingManager.shared.trackGenerationFail(feature: .interior, errorType: .init(error: error), durationMs: durationMs)
                await MainActor.run {
                    loadingVM.status = .failed
                    loadingVM.errorMessage = errorMessage
                }
            }
        }
    }
}
