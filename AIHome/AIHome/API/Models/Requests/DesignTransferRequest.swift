import Foundation

public struct DesignTransferRequest {
    public let image: HomeDesignsImageSource
    public let styleImage: HomeDesignsImageSource
    public let aiIntervention: AIIntervention
    
    public init(image: HomeDesignsImageSource, styleImage: HomeDesignsImageSource, aiIntervention: AIIntervention) {
        self.image = image
        self.styleImage = styleImage
        self.aiIntervention = aiIntervention
    }
}

extension DesignTransferRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
        builder.appendImageSource(styleImage, fieldName: "style_image")
        builder.appendField(name: "ai_intervention", value: aiIntervention.rawValue)
    }
}
