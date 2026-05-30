import Foundation

public struct StatusCheckResponse: Codable, Equatable {
    public let status: String?
    public let inputImage: String?
    public let outputImages: [String]?
    public let message: String?

    enum CodingKeys: String, CodingKey {
        case status
        case inputImage = "input_image"
        case outputImages = "output_images"
        case message
    }

    public var resolvedStatus: GenerationStatus {
        GenerationStatus(apiRawValue: status)
    }
}
