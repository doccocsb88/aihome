import SwiftUI

enum InteriorFlowState {
    case input
    case loading(GenerationLoadingViewModel)
    case result(ResultViewModel)
}

struct InteriorFlowContainerView: View {
    @State private var state: InteriorFlowState = .input
    @State private var currentDraft: InteriorDraft? = nil
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    var initialImage: UIImage?

    var body: some View {
        Group {
            switch state {
            case .input:
                InteriorFlowView(initialImage: currentDraft?.sourceImage ?? initialImage, onGenerate: { draft in
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
        let requestDesignStyle = isCustomStyle ? "Modern" : designStyle.rawValue
        let requestCustomInstruction = isCustomStyle ? customStylePrompt : nil
        let displayStyle = isCustomStyle ? (customStylePrompt ?? "Custom Style") : designStyle.rawValue

        let aiIntervention: AIIntervention
        switch interventionLevel {
        case .light: aiIntervention = .low
        case .medium: aiIntervention = .mid
        case .high: aiIntervention = .extreme
        }

        AppLogger.logAction("Start Interior Generation", details: "Room: \(roomType.rawValue), Style: \(displayStyle), Intervention: \(aiIntervention.rawValue)")

        let loadingVM = GenerationLoadingViewModel(projectType: .interior, status: .generating, progressText: "Generating...", canCancel: true, inputImage: sourceImage)
        self.state = .loading(loadingVM)

        Task {
            do {
                guard let imageData = sourceImage.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "GenerationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
                
                let request = InteriorGenerationInput(
                    image: .jpegData(imageData),
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
