import Foundation

public struct PaintVisualizerRequest {
    public let image: HomeDesignsImageSource
    public let maskedImage: HomeDesignsImageSource
    public let noDesign: Int
    public let colorImage: HomeDesignsImageSource?
    public let rgbColor: String?
    
    public init(image: HomeDesignsImageSource, maskedImage: HomeDesignsImageSource, noDesign: Int, colorImage: HomeDesignsImageSource? = nil, rgbColor: String? = nil) {
        self.image = image
        self.maskedImage = maskedImage
        self.noDesign = noDesign
        self.colorImage = colorImage
        self.rgbColor = rgbColor
    }
}

extension PaintVisualizerRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
        builder.appendImageSource(maskedImage, fieldName: "masked_image")
        builder.appendField(name: "no_design", value: "\\(noDesign)")
        
        if let colorImage = colorImage {
            builder.appendImageSource(colorImage, fieldName: "color_image")
        }
        if let rgbColor = rgbColor {
            builder.appendField(name: "rgb_color", value: rgbColor)
        }
    }
}
