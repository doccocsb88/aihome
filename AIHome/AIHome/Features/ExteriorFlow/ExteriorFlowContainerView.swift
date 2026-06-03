import SwiftUI

enum ExteriorFlowState {
    case input
    case loading(GenerationLoadingViewModel)
    case result(ResultViewModel)
}

struct ExteriorFlowContainerView: View {
    @State private var state: ExteriorFlowState = .input
    @State private var currentDraft: ExteriorDraft? = nil
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            switch state {
            case .input:
                ExteriorFlowView(onGenerate: { draft in
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

    private func startGeneration(with draft: ExteriorDraft) {
        self.currentDraft = draft
        guard let sourceImage = draft.sourceImage else {
            AppLogger.logError("Missing required draft data")
            return
        }

        AppLogger.logAction("Start Exterior Generation", details: "Prompt: \(draft.prompt)")

        let loadingVM = GenerationLoadingViewModel(projectType: .exterior, status: .generating, progressText: "Generating...", canCancel: true, inputImage: sourceImage)
        self.state = .loading(loadingVM)

        Task {
            do {
                guard let imageData = sourceImage.jpegData(compressionQuality: 0.8) else {
                    throw NSError(domain: "GenerationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
                }
                
                let request = ExteriorGenerationInput(
                    image: .jpegData(imageData),
                    aiIntervention: .mid, // Default
                    noDesign: 1,
                    designStyle: "Modern", // Default
                    houseAngle: "Front of house", // Default
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

                let resultVM = ResultViewModel(
                    project: mockProject,
                    originalImage: sourceImage,
                    generatedImages: downloadedImages,
                    availableAdvancedTools: [
                        .edit,
                        .replace,
                        .remove
                    ],
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
