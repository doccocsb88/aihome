import Foundation

public struct ChangeColorTexturesRequest {
    public let designType: DesignType
    public let image: HomeDesignsImageSource
    public let maskedImage: HomeDesignsImageSource
    public let noDesign: Int
    public let prompt: String?
    public let color: String?
    public let materials: String?
    
    public init(designType: DesignType, image: HomeDesignsImageSource, maskedImage: HomeDesignsImageSource, noDesign: Int, prompt: String? = nil, color: String? = nil, materials: String? = nil) {
        self.designType = designType
        self.image = image
        self.maskedImage = maskedImage
        self.noDesign = noDesign
        self.prompt = prompt
        self.color = color
        self.materials = materials
    }
}

extension ChangeColorTexturesRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendField(name: "design_type", value: designType.rawValue)
        builder.appendImageSource(image, fieldName: "image")
        builder.appendImageSource(maskedImage, fieldName: "masked_image")
        builder.appendField(name: "no_design", value: "\\(noDesign)")
        
        if let prompt = prompt {
            builder.appendField(name: "prompt", value: prompt)
        }
        if let color = color {
            builder.appendField(name: "color", value: color)
        }
        if let materials = materials {
            builder.appendField(name: "materials", value: materials)
        }
    }
}
