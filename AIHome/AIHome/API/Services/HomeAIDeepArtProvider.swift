import Foundation

public final class HomeAIDeepArtProvider: HomeGPTGenerationProviderProtocol {
    public let providerKind: HomeGPTProviderKind = .homeAIBackend

    private struct APIConfig {
        let baseURL: URL
        let apiKey: String
    }

    private struct JobCreatedResponse: Decodable {
        let jobID: String?
        let pollAfterMs: Int?
        let message: String?

        enum CodingKeys: String, CodingKey {
            case jobID = "job_id"
            case pollAfterMs = "poll_after_ms"
            case message
        }
    }

    private struct JobStatusResponse: Decodable {
        let status: String?
        let resultURL: String?
        let error: String?
        let pollAfterMs: Int?
        let queuePosition: Int?

        enum CodingKeys: String, CodingKey {
            case status
            case resultURL = "result_url"
            case error
            case pollAfterMs = "poll_after_ms"
            case queuePosition = "queue_position"
        }

        var resolvedStatus: GenerationStatus {
            if let resultURL, !resultURL.isEmpty {
                return .success
            }
            return GenerationStatus(apiRawValue: status)
        }
    }

    private let config: APIConfig
    private let session: URLSession
    private let decoder: JSONDecoder
    private let fallbackProvider: any HomeGPTGenerationProviderProtocol

    public init(
        baseURL: URL = APIConstants.homeAIBackendBaseURL,
        apiKey: String? = nil,
        fallbackProvider: any HomeGPTGenerationProviderProtocol = LegacyHomeDesignsProvider(),
        session: URLSession? = nil
    ) {
        let resolvedAPIKey = apiKey ?? HomeAIBackendCredentials.apiKey
        self.config = APIConfig(baseURL: baseURL, apiKey: resolvedAPIKey?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        self.fallbackProvider = fallbackProvider

        if let session {
            self.session = session
        } else {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 60
            sessionConfig.timeoutIntervalForResource = 120
            self.session = URLSession(configuration: sessionConfig)
        }

        self.decoder = JSONDecoder()
    }

    private func makeRequest(
        path: String,
        method: String,
        builder: MultipartFormDataBuilder? = nil
    ) throws -> URLRequest {
        guard !config.apiKey.isEmpty else {
            throw HomeDesignsAPIError.underlying("Missing \(APIConstants.HomeAIBackend.apiKeyEnvironmentKey)")
        }

        guard let url = URL(string: config.baseURL.absoluteString + path) else {
            throw HomeDesignsAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("\(APIConstants.HomeAIBackend.authorizationHeaderName) \(config.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let builder {
            request.setValue("multipart/form-data; boundary=\(builder.boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = builder.build()
        }

        AppLogger.logAction("Home AI Backend Request", details: "\(method) \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            AppLogger.logAction("Home AI Backend Headers", details: "\(headers)")
        }

        return request
    }

    private func perform<T: Decodable>(request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HomeDesignsAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            if [502, 503, 504, 524].contains(httpResponse.statusCode) {
                throw HomeDesignsAPIError.temporaryServerUnavailable(statusCode: httpResponse.statusCode)
            }

            let message = String(data: data, encoding: .utf8)
            if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                throw HomeDesignsAPIError.unauthorized
            }
            throw HomeDesignsAPIError.server(statusCode: httpResponse.statusCode, message: message)
        }

        if let responseString = String(data: data, encoding: .utf8) {
            AppLogger.logAction("Home AI Backend Response", details: responseString)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            if let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                for key in ["success", "data", "result"] {
                    if let nested = dict[key],
                       let nestedData = try? JSONSerialization.data(withJSONObject: nested, options: []),
                       let result = try? decoder.decode(T.self, from: nestedData) {
                        return result
                    }
                }
            }

            throw HomeDesignsAPIError.decodingFailed(error.localizedDescription)
        }
    }

    private func submitJob(
        feature: String,
        image: HomeDesignsImageSource,
        textFields: [String: String] = [:],
        fileAttachments: [String: HomeDesignsImageSource] = [:]
    ) async throws -> [String] {
        var builder = MultipartFormDataBuilder()
        builder.appendField(name: "feature", value: feature)
        builder.appendImageSource(image, fieldName: "image")

        for (key, value) in textFields.sorted(by: { $0.key < $1.key }) {
            builder.appendField(name: key, value: value)
        }

        for (key, value) in fileAttachments.sorted(by: { $0.key < $1.key }) {
            builder.appendImageSource(value, fieldName: key)
        }

        let request = try makeRequest(path: "/deepart/jobs", method: "POST", builder: builder)
        let created: JobCreatedResponse = try await perform(request: request)

        if let message = created.message, created.jobID == nil {
            throw HomeDesignsAPIError.apiMessage(message)
        }

        guard let jobID = created.jobID, !jobID.isEmpty else {
            throw HomeDesignsAPIError.apiMessage("Missing job_id")
        }

        return try await poll(jobID: jobID, initialPollDelayMs: created.pollAfterMs)
    }

    private func poll(jobID: String, initialPollDelayMs: Int?) async throws -> [String] {
        let deadline = Date().addingTimeInterval(120)
        var currentDelayMs = max(initialPollDelayMs ?? 2_000, 1_000)

        while Date() < deadline {
            let status = try await fetchJobStatus(jobID: jobID)

            if let resultURL = status.resultURL, !resultURL.isEmpty {
                return [resultURL]
            }

            switch status.resolvedStatus {
            case .success:
                if let resultURL = status.resultURL, !resultURL.isEmpty {
                    return [resultURL]
                }
                throw HomeDesignsAPIError.apiMessage("Completed job missing result_url")
            case .failed:
                throw HomeDesignsAPIError.apiMessage(status.error ?? "Generation failed")
            case .inQueue, .starting, .processing:
                break
            case .unknown:
                break
            }

            if let pollAfterMs = status.pollAfterMs, pollAfterMs > 0 {
                currentDelayMs = min(pollAfterMs, 30_000)
            }

            try await Task.sleep(nanoseconds: UInt64(currentDelayMs) * 1_000_000)
            currentDelayMs = min(currentDelayMs * 8 / 5, 30_000)
        }

        throw HomeDesignsAPIError.generationTimedOut
    }

    private func fetchJobStatus(jobID: String) async throws -> JobStatusResponse {
        let request = try makeRequest(path: "/deepart/jobs/\(jobID)", method: "GET")

        do {
            return try await perform(request: request)
        } catch {
            guard isTransient(error) else { throw error }

            AppLogger.logAction("Home AI Backend Retry", details: "job_id=\(jobID)")
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return try await perform(request: request)
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

    private func joinedText(_ parts: [String?], separator: String = ", ") -> String? {
        let values = parts
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !values.isEmpty else { return nil }
        return values.joined(separator: separator)
    }

    private func backendText(from request: InteriorGenerationInput) -> String {
        joinedText([request.designStyle, request.customInstruction]) ?? request.designStyle
    }

    private func backendText(from request: ExteriorGenerationInput) -> String {
        joinedText([request.designStyle, request.houseAngle, request.customInstruction]) ?? request.designStyle
    }

    private func backendPrompt(from request: GardenGenerationInput) -> String {
        joinedText([request.designStyle, request.gardenType, request.customInstruction], separator: ". ")
            ?? request.designStyle
    }

    public func generateInterior(request: InteriorGenerationInput) async throws -> [String] {
        var fields: [String: String] = [
            "ai_intervention": request.aiIntervention.rawValue,
            "style": backendText(from: request)
        ]

        if !request.roomType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fields["room"] = request.roomType
        }

        return try await submitJob(feature: "interior", image: request.image, textFields: fields)
    }

    public func generateExterior(request: ExteriorGenerationInput) async throws -> [String] {
        let fields: [String: String] = [
            "ai_intervention": request.aiIntervention.rawValue,
            "style": backendText(from: request)
        ]

        return try await submitJob(feature: "exterior", image: request.image, textFields: fields)
    }

    public func generateGarden(request: GardenGenerationInput) async throws -> [String] {
        let fields: [String: String] = [
            "ai_intervention": request.aiIntervention.rawValue,
            "prompt": backendPrompt(from: request)
        ]

        return try await submitJob(feature: "garden", image: request.image, textFields: fields)
    }

    public func generateReferenceStyle(request: ReferenceStyleInput) async throws -> [String] {
        let fields: [String: String] = [
            "ai_intervention": request.aiIntervention.rawValue
        ]

        return try await submitJob(
            feature: "stylematch",
            image: request.image,
            textFields: fields,
            fileAttachments: ["ref": request.styleImage]
        )
    }

    public func removeObjects(request: RemoveObjectsInput) async throws -> [String] {
        let fields: [String: String] = [
            "prompt": request.prompt
        ]
        return try await submitJob(feature: "remove", image: request.image, textFields: fields)
    }

    public func replaceObjects(request: ReplaceObjectsInput) async throws -> [String] {
        let fields: [String: String] = [
            "prompt": request.prompt
        ]
        return try await submitJob(feature: "replace", image: request.image, textFields: fields)
    }

    public func generateNewFlooring(request: NewFlooringInput) async throws -> [String] {
        if request.textureImage != nil {
            return try await fallbackProvider.generateNewFlooring(request: request)
        }

        let fields: [String: String] = [
            "prompt": request.prompt ?? request.noOfTexture
        ]
        return try await submitJob(feature: "flooring", image: request.image, textFields: fields)
    }

    public func generateNewWalls(request: NewWallsInput) async throws -> [String] {
        let fields: [String: String] = [
            "prompt": request.prompt
        ]
        return try await submitJob(feature: "walls", image: request.image, textFields: fields)
    }

    public func findFurniture(image: HomeDesignsImageSource, countryCode: String?) async throws -> FurnitureFinderResponse {
        try await fallbackProvider.findFurniture(image: image, countryCode: countryCode)
    }

    public func upscale(image: HomeDesignsImageSource) async throws -> [String] {
        try await fallbackProvider.upscale(image: image)
    }
}
