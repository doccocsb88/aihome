import Foundation

public struct FloorEditorRequest {
    public let image: HomeDesignsImageSource
    public let textureImage: HomeDesignsImageSource
    public let noOfTexture: String
    
    public init(image: HomeDesignsImageSource, textureImage: HomeDesignsImageSource, noOfTexture: String) {
        self.image = image
        self.textureImage = textureImage
        self.noOfTexture = noOfTexture
    }
}

extension FloorEditorRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
        builder.appendImageSource(textureImage, fieldName: "texture_image")
        builder.appendField(name: "no_of_texture", value: noOfTexture)
    }
}
