import Foundation

public final class LegacyHomeDesignsProvider: HomeGPTGenerationProviderProtocol {
    public let providerKind: HomeGPTProviderKind = .legacyHomeDesigns

    private let client: any HomeDesignsAPIClientProtocol

    public init(client: any HomeDesignsAPIClientProtocol) {
        self.client = client
    }

    public convenience init() {
        let config = HomeDesignsAPIConfig(
            baseURL: APIConstants.homeDesignsBaseURL,
            authMode: .bearer(token: APIConstants.homeDesignsAPIKey)
        )
        self.init(client: HomeDesignsAPIClient(config: config))
    }

    private func submitPerfectRedesign(_ request: PerfectRedesignRequest) async throws -> QueueResponse {
        do {
            return try await client.perfectRedesign(request)
        } catch {
            guard isTransient(error) else { throw error }

            AppLogger.logAction("Retry Perfect Redesign", details: "Retrying once in 10 seconds")
            try await Task.sleep(nanoseconds: 10_000_000_000)
            return try await client.perfectRedesign(request)
        }
    }

    private func checkPerfectRedesignStatus(queueId: String) async throws -> StatusCheckResponse {
        let maxRetryCount = 3
        var retryCount = 0

        while true {
            do {
                return try await client.checkPerfectRedesignStatus(queueId: queueId)
            } catch {
                guard isTransient(error), retryCount < maxRetryCount else { throw error }

                let delaySeconds = 2 << retryCount
                retryCount += 1
                AppLogger.logAction(
                    "Retry Redesign Status",
                    details: "Attempt \(retryCount)/\(maxRetryCount) in \(delaySeconds) seconds"
                )
                try await Task.sleep(nanoseconds: UInt64(delaySeconds) * 1_000_000_000)
            }
        }
    }

    private func isTransient(_ error: Error) -> Bool {
        if let apiError = error as? HomeDesignsAPIError,
           case .temporaryServerUnavailable = apiError {
            return true
        }

        guard let urlError = error as? URLError else { return false }
        return urlError.code == .timedOut || urlError.code == .networkConnectionLost
    }

    private func pollForRedesignResult(queueId: String) async throws -> [String] {
        let deadline = Date().addingTimeInterval(10 * 60)

        while Date() < deadline {
            let status = try await checkPerfectRedesignStatus(queueId: queueId)
            switch status.resolvedStatus {
            case .success:
                return status.outputImages ?? []
            case .failed:
                throw HomeDesignsAPIError.apiMessage(status.message ?? "Generation failed")
            case .inQueue, .starting, .processing:
                try await Task.sleep(nanoseconds: 4_000_000_000)
            case .unknown:
                throw HomeDesignsAPIError.apiMessage("Unknown status: \(status.status ?? "")")
            }
        }
        throw HomeDesignsAPIError.generationTimedOut
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
        let queue = try await submitPerfectRedesign(req)
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
        let queue = try await submitPerfectRedesign(req)
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
        let queue = try await submitPerfectRedesign(req)
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
        guard let maskUrlString = maskRes.maskedImageURL, let maskUrl = URL(string: maskUrlString) else {
            throw HomeDesignsAPIError.apiMessage("Mask generation failed")
        }

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
        guard let maskUrlString = maskRes.maskedImageURL, let maskUrl = URL(string: maskUrlString) else {
            throw HomeDesignsAPIError.apiMessage("Mask generation failed")
        }

        let (maskData, _) = try await URLSession.shared.data(from: maskUrl)

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
        }

        let labels = ["floor"]
        let maskReq = CreateMaskImageRequest(image: request.image, labels: labels)
        let maskRes = try await client.createMaskImage(maskReq)
        if let error = maskRes.error {
            throw HomeDesignsAPIError.apiMessage(error)
        }
        guard let maskUrlString = maskRes.maskedImageURL, let maskUrl = URL(string: maskUrlString) else {
            throw HomeDesignsAPIError.apiMessage("Mask generation failed")
        }

        let (maskData, _) = try await URLSession.shared.data(from: maskUrl)

        let changeReq = ChangeColorTexturesRequest(
            designType: .interior,
            image: request.image,
            maskedImage: .pngData(maskData, filename: "mask.png"),
            noDesign: 1,
            prompt: "Change the floor to: \(request.prompt ?? request.noOfTexture)"
        )
        let result = try await client.changeColorTextures(changeReq)
        return result.outputImages
    }

    public func generateNewWalls(request: NewWallsInput) async throws -> [String] {
        let labels = ["wall"]
        let maskReq = CreateMaskImageRequest(image: request.image, labels: labels)
        let maskRes = try await client.createMaskImage(maskReq)
        if let error = maskRes.error {
            throw HomeDesignsAPIError.apiMessage(error)
        }
        guard let maskUrlString = maskRes.maskedImageURL, let maskUrl = URL(string: maskUrlString) else {
            throw HomeDesignsAPIError.apiMessage("Mask generation failed")
        }

        let (maskData, _) = try await URLSession.shared.data(from: maskUrl)

        let changeReq = ChangeColorTexturesRequest(
            designType: .interior,
            image: request.image,
            maskedImage: .pngData(maskData, filename: "mask.png"),
            noDesign: request.noDesign,
            prompt: "Change the wall to: \(request.prompt)"
        )
        let result = try await client.changeColorTextures(changeReq)
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

