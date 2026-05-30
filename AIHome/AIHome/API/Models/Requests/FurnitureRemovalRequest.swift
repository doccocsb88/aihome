import Foundation

public struct FurnitureRemovalRequest {
    public let image: HomeDesignsImageSource
    public let maskedImage: HomeDesignsImageSource
    
    public init(image: HomeDesignsImageSource, maskedImage: HomeDesignsImageSource) {
        self.image = image
        self.maskedImage = maskedImage
    }
}

extension FurnitureRemovalRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
        builder.appendImageSource(maskedImage, fieldName: "masked_image")
    }
}
