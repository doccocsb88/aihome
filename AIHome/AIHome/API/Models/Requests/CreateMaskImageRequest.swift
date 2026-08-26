import Foundation

public struct CreateMaskImageRequest {
    public let image: HomeDesignsImageSource
    public let labels: [String]
    
    public init(image: HomeDesignsImageSource, labels: [String]) {
        self.image = image
        self.labels = labels.compactMap({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
    }

    public var apiLabels: String {
        labels
            .map(MaskObjectLabelCatalog.apiValue(for:))
            .compactMap({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
            .joined(separator: "|")
    }
}

extension CreateMaskImageRequest {
    func appendTo(builder: inout MultipartFormDataBuilder) {
        builder.appendImageSource(image, fieldName: "image")
        builder.appendField(name: "labels", value: apiLabels)
    }
}
