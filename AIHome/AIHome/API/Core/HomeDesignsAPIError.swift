import Foundation

public enum HomeDesignsAPIError: Error, Equatable {
    case invalidURL
    case invalidImage
    case invalidResponse
    case unauthorized
    case server(statusCode: Int, message: String?)
    case decodingFailed(String)
    case queueExpired
    case apiMessage(String)
    case underlying(String)
}

public enum HomeDesignsAuthMode {
    case bearer(token: String)
    case customHeader(name: String, value: String)
}

public struct HomeDesignsAPIConfig {
    public let baseURL: URL
    public let authMode: HomeDesignsAuthMode
    
    public init(baseURL: URL, authMode: HomeDesignsAuthMode) {
        self.baseURL = baseURL
        self.authMode = authMode
    }
}
