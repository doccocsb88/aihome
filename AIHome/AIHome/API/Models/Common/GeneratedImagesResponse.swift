import Foundation

public struct GeneratedImagesResponse: Decodable, Equatable {
    public let inputImage: String?
    public let outputImages: [String]

    enum CodingKeys: String, CodingKey {
        case inputImage = "input_image"
        case outputImages = "output_images"
        case originalImage = "original_image"
        case generatedImage = "generated_image"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.inputImage = try container.decodeIfPresent(String.self, forKey: .inputImage) ?? container.decodeIfPresent(String.self, forKey: .originalImage)
        
        if let outputs = try container.decodeIfPresent([String].self, forKey: .outputImages) {
            self.outputImages = outputs
        } else if let generated = try container.decodeIfPresent([String].self, forKey: .generatedImage) {
            self.outputImages = generated
        } else {
            throw DecodingError.keyNotFound(CodingKeys.outputImages, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Neither output_images nor generated_image was found"))
        }
    }
}
