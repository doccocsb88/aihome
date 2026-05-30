import Foundation

public struct CreateMaskImageResponse: Codable, Equatable {
    public let success: MaskSuccess?

    public struct MaskSuccess: Codable, Equatable {
        public let maskedImage: String

        enum CodingKeys: String, CodingKey {
            case maskedImage = "masked_image"
        }
    }

    public var maskedImageURL: String? {
        success?.maskedImage
    }
}
