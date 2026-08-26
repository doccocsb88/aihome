import Foundation

public struct FurnitureFinderRequest {
    public let image: HomeDesignsImageSource
    public let countryCode: String?
    
    public init(image: HomeDesignsImageSource, countryCode: String? = nil) {
        self.image = image
        self.countryCode = countryCode
    }
}

extension FurnitureFinderRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
        if let countryCode = countryCode {
            builder.appendField(name: "countryCode", value: countryCode)
        }
    }
}
