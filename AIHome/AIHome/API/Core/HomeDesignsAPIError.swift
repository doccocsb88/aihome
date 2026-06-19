import Foundation

public enum HomeDesignsAPIError: Error, Equatable {
    case invalidURL
    case invalidImage
    case invalidResponse
    case unauthorized
    case temporaryServerUnavailable(statusCode: Int)
    case server(statusCode: Int, message: String?)
    case decodingFailed(String)
    case queueExpired
    case generationTimedOut
    case apiMessage(String)
    case underlying(String)
}

extension HomeDesignsAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidImage: return "Invalid Image Data"
        case .invalidResponse: return "Invalid API Response"
        case .unauthorized: return "Unauthorized. Check API Key."
        case .temporaryServerUnavailable:
            return "Server is busy. Please try again in a moment."
        case .server(let code, let msg): return "Server Error \(code): \(msg ?? "")"
        case .decodingFailed(let msg): return "Decoding Failed: \(msg)"
        case .queueExpired: return "Queue Expired"
        case .generationTimedOut: return "Generation timed out. Please try again."
        case .apiMessage(let msg): return "API Error: \(msg)"
        case .underlying(let msg): return "Underlying Error: \(msg)"
        }
    }
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
