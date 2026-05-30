import Foundation

public struct FullHDRequest {
    public let image: HomeDesignsImageSource
    
    public init(image: HomeDesignsImageSource) {
        self.image = image
    }
}

extension FullHDRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
    }
}
