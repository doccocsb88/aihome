import Foundation

public struct GeneratedImagesResponse: Codable, Equatable {
    public let inputImage: String?
    public let outputImages: [String]

    enum CodingKeys: String, CodingKey {
        case inputImage = "input_image"
        case outputImages = "output_images"
    }
}
