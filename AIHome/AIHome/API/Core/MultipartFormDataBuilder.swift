import Foundation

public struct MultipartFormDataBuilder {
    public let boundary: String
    private var data: Data
    
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
        self.data = Data()
    }
    
    public mutating func appendField(name: String, value: String) {
        let fieldString = "--\(boundary)\r\n" +
                          "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n" +
                          "\(value)\r\n"
        if let fieldData = fieldString.data(using: .utf8) {
            data.append(fieldData)
        }
    }
    
    public mutating func appendFile(name: String, filename: String, mimeType: String, fileData: Data) {
        let headerString = "--\(boundary)\r\n" +
                           "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n" +
                           "Content-Type: \(mimeType)\r\n\r\n"
        if let headerData = headerString.data(using: .utf8) {
            data.append(headerData)
            data.append(fileData)
            data.append("\r\n".data(using: .utf8)!)
        }
    }
    
    public func build() -> Data {
        var finalData = data
        let footerString = "--\(boundary)--\r\n"
        if let footerData = footerString.data(using: .utf8) {
            finalData.append(footerData)
        }
        return finalData
    }
}
