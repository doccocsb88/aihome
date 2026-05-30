import Foundation

public enum HomeDesignsImageSource {
    case jpegData(Data, filename: String = "image.jpg")
    case pngData(Data, filename: String = "image.png")
    case base64(String)
    case remoteURL(String)
}

extension MultipartFormDataBuilder {
    mutating func appendImageSource(_ source: HomeDesignsImageSource, fieldName: String) {
        switch source {
        case .jpegData(let data, let filename):
            self.appendFile(name: fieldName, filename: filename, mimeType: "image/jpeg", fileData: data)
        case .pngData(let data, let filename):
            self.appendFile(name: fieldName, filename: filename, mimeType: "image/png", fileData: data)
        case .base64(let string):
            self.appendField(name: fieldName, value: string)
        case .remoteURL(let urlString):
            self.appendField(name: fieldName, value: urlString)
        }
    }
}
