import Foundation

public struct MaterialSwapRequest {
    public let image: HomeDesignsImageSource
    public let maskedImage: HomeDesignsImageSource
    public let noDesign: Int
    public let textureImage: HomeDesignsImageSource
    public let noOfTexture: String
    
    public init(image: HomeDesignsImageSource, maskedImage: HomeDesignsImageSource, noDesign: Int, textureImage: HomeDesignsImageSource, noOfTexture: String) {
        self.image = image
        self.maskedImage = maskedImage
        self.noDesign = noDesign
        self.textureImage = textureImage
        self.noOfTexture = noOfTexture
    }
}

extension MaterialSwapRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
        builder.appendImageSource(maskedImage, fieldName: "masked_image")
        builder.appendField(name: "no_design", value: "\\(noDesign)")
        builder.appendImageSource(textureImage, fieldName: "texture_image")
        builder.appendField(name: "no_of_texture", value: noOfTexture)
    }
}
