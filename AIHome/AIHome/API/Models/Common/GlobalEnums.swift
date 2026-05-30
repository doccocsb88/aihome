import Foundation

public enum DesignType: String, Codable, CaseIterable {
    case interior = "Interior"
    case exterior = "Exterior"
    case garden = "Garden"
}

public enum AIIntervention: String, Codable, CaseIterable {
    case veryLow = "Very Low"
    case low = "Low"
    case mid = "Mid"
    case extreme = "Extreme"
}

/// PDF UI mapping:
/// LIGHT  -> .veryLow or .low
/// MEDIUM -> .mid
/// HIGH   -> .extreme
public enum HomeGPTInterventionLevel {
    case light
    case medium
    case high

    var apiValue: AIIntervention {
        switch self {
        case .light: return .low
        case .medium: return .mid
        case .high: return .extreme
        }
    }
}

public enum GenerationStatus: String, Codable {
    case inQueue = "IN_QUEUE"
    case starting = "starting"
    case processing = "processing"
    case success = "SUCCESS"
    case failed = "FAILED"
    case unknown

    public init(apiRawValue: String?) {
        guard let apiRawValue = apiRawValue else {
            self = .unknown
            return
        }

        switch apiRawValue.lowercased() {
        case "in_queue": self = .inQueue
        case "starting": self = .starting
        case "processing": self = .processing
        case "success": self = .success
        case "failed", "error": self = .failed
        default: self = .unknown
        }
    }
}
