import Foundation

public class HomeGPTAIService: HomeGPTAIServiceProtocol {
    public static let shared: HomeGPTAIService = {
        let config = HomeDesignsAPIConfig(
            baseURL: APIConstants.homeDesignsBaseURL,
            authMode: .bearer(token: APIConstants.homeDesignsAPIKey)
        )
        let client = HomeDesignsAPIClient(config: config)
        return HomeGPTAIService(client: client)
    }()
    
    private let client: HomeDesignsAPIClientProtocol
    
    public init(client: HomeDesignsAPIClientProtocol) {
        self.client = client
    }
    
    private func pollForRedesignResult(queueId: String) async throws -> [String] {
        var attempts = 0
        let maxAttempts = 60
        
        while attempts < maxAttempts {
            let status = try await client.checkPerfectRedesignStatus(queueId: queueId)
            switch status.resolvedStatus {
            case .success:
                return status.outputImages ?? []
            case .failed:
                throw HomeDesignsAPIError.apiMessage(status.message ?? "Generation failed")
            case .inQueue, .starting, .processing:
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                attempts += 1
            case .unknown:
                throw HomeDesignsAPIError.apiMessage("Unknown status: \(status.status ?? "")")
            }
        }
        throw HomeDesignsAPIError.queueExpired
    }
    
    public func generateInterior(request: InteriorGenerationInput) async throws -> [String] {
        let req = PerfectRedesignRequest(
            image: request.image,
            designType: .interior,
            aiIntervention: request.aiIntervention,
            noDesign: request.noDesign,
            designStyle: request.designStyle,
            roomType: request.roomType,
            customInstruction: request.customInstruction
        )
        let queue = try await client.perfectRedesign(req)
        if let msg = queue.message, queue.resolvedQueueId == nil {
            throw HomeDesignsAPIError.apiMessage(msg)
        }
        guard let qid = queue.resolvedQueueId else { throw HomeDesignsAPIError.apiMessage("No queue ID") }
        return try await pollForRedesignResult(queueId: qid)
    }
    
    public func generateExterior(request: ExteriorGenerationInput) async throws -> [String] {
        let req = PerfectRedesignRequest(
            image: request.image,
            designType: .exterior,
            aiIntervention: request.aiIntervention,
            noDesign: request.noDesign,
            designStyle: request.designStyle,
            houseAngle: request.houseAngle,
            customInstruction: request.customInstruction
        )
        let queue = try await client.perfectRedesign(req)
        guard let qid = queue.resolvedQueueId else { throw HomeDesignsAPIError.apiMessage("No queue ID") }
        return try await pollForRedesignResult(queueId: qid)
    }
    
    public func generateGarden(request: GardenGenerationInput) async throws -> [String] {
        let req = PerfectRedesignRequest(
            image: request.image,
            designType: .garden,
            aiIntervention: request.aiIntervention,
            noDesign: request.noDesign,
            designStyle: request.designStyle,
            gardenType: request.gardenType,
            customInstruction: request.customInstruction
        )
        let queue = try await client.perfectRedesign(req)
        guard let qid = queue.resolvedQueueId else { throw HomeDesignsAPIError.apiMessage("No queue ID") }
        return try await pollForRedesignResult(queueId: qid)
    }
    
    public func generateReferenceStyle(request: ReferenceStyleInput) async throws -> [String] {
        let req = DesignTransferRequest(
            image: request.image,
            styleImage: request.styleImage,
            aiIntervention: request.aiIntervention
        )
        let res = try await client.designTransfer(req)
        return res.outputImages
    }
    
    public func removeObjects(request: RemoveObjectsInput) async throws -> [String] {
        let labels = PromptMaskLabelMapper.labels(for: request.prompt)
        guard !labels.isEmpty else { throw HomeDesignsAPIError.apiMessage("Could not determine labels from prompt") }
        
        let maskReq = CreateMaskImageRequest(image: request.image, labels: labels)
        let maskRes = try await client.createMaskImage(maskReq)
        if let error = maskRes.error {
            throw HomeDesignsAPIError.apiMessage(error)
        }
        guard let maskUrlString = maskRes.maskedImageURL, let maskUrl = URL(string: maskUrlString) else { throw HomeDesignsAPIError.apiMessage("Mask generation failed") }
        
        let (maskData, _) = try await URLSession.shared.data(from: maskUrl)
        
        let removalReq = FurnitureRemovalRequest(image: request.image, maskedImage: .pngData(maskData, filename: "mask.png"))
        let result = try await client.furnitureRemoval(removalReq)
        return result.outputImages
    }
    
    public func replaceObjects(request: ReplaceObjectsInput) async throws -> [String] {
        let labels = PromptMaskLabelMapper.labels(for: request.prompt)
        guard !labels.isEmpty else { throw HomeDesignsAPIError.apiMessage("Could not determine labels from prompt") }
        
        let maskReq = CreateMaskImageRequest(image: request.image, labels: labels)
        let maskRes = try await client.createMaskImage(maskReq)
        if let error = maskRes.error {
            throw HomeDesignsAPIError.apiMessage(error)
        }
        guard let maskUrlString = maskRes.maskedImageURL, let maskUrl = URL(string: maskUrlString) else { throw HomeDesignsAPIError.apiMessage("Mask generation failed") }
        
        let (maskData, _) = try await URLSession.shared.data(from: maskUrl)
        
        // Use change_color_textures
        let changeReq = ChangeColorTexturesRequest(
            designType: .interior,
            image: request.image,
            maskedImage: .pngData(maskData, filename: "mask.png"),
            noDesign: request.noDesign,
            prompt: request.prompt
        )
        let result = try await client.changeColorTextures(changeReq)
        return result.outputImages
    }
    
    public func generateNewFlooring(request: NewFlooringInput) async throws -> [String] {
        if let texture = request.textureImage {
            let req = FloorEditorRequest(image: request.image, textureImage: texture, noOfTexture: request.noOfTexture)
            let result = try await client.floorEditor(req)
            return result.outputImages
        } else {
            // Fallback
            let labels = ["floor"]
            let maskReq = CreateMaskImageRequest(image: request.image, labels: labels)
            let maskRes = try await client.createMaskImage(maskReq)
            if let error = maskRes.error {
            throw HomeDesignsAPIError.apiMessage(error)
        }
        guard let maskUrlString = maskRes.maskedImageURL, let maskUrl = URL(string: maskUrlString) else { throw HomeDesignsAPIError.apiMessage("Mask generation failed") }
        
        let (maskData, _) = try await URLSession.shared.data(from: maskUrl)
            
            let changeReq = ChangeColorTexturesRequest(
                designType: .interior,
                image: request.image,
                maskedImage: .pngData(maskData, filename: "mask.png"),
                noDesign: 1, // Defaulting to 1 for fallback
                prompt: request.prompt
            )
            let result = try await client.changeColorTextures(changeReq)
            return result.outputImages
        }
    }
    
    public func generateNewWalls(request: NewWallsInput) async throws -> [String] {
        let labels = ["wall"]
        let maskReq = CreateMaskImageRequest(image: request.image, labels: labels)
        let maskRes = try await client.createMaskImage(maskReq)
        if let error = maskRes.error {
            throw HomeDesignsAPIError.apiMessage(error)
        }
        guard let maskUrlString = maskRes.maskedImageURL, let maskUrl = URL(string: maskUrlString) else { throw HomeDesignsAPIError.apiMessage("Mask generation failed") }
        
        let (maskData, _) = try await URLSession.shared.data(from: maskUrl)
        
        let rgb = ColorPromptMapper.rgb(for: request.prompt)
        
        let paintReq = PaintVisualizerRequest(
            image: request.image,
            maskedImage: .pngData(maskData, filename: "mask.png"),
            noDesign: request.noDesign,
            rgbColor: rgb
        )
        
        let result = try await client.paintVisualizer(paintReq)
        return result.outputImages
    }
    
    public func findFurniture(image: HomeDesignsImageSource, countryCode: String?) async throws -> FurnitureFinderResponse {
        let req = FurnitureFinderRequest(image: image, countryCode: countryCode)
        return try await client.furnitureFinder(req)
    }
    
    public func upscale(image: HomeDesignsImageSource) async throws -> [String] {
        let req = FullHDRequest(image: image)
        let result = try await client.fullHD(req)
        return result.outputImages
    }
}
