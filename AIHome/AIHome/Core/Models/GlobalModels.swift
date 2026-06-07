import Foundation

enum ProjectType: String, Codable, CaseIterable {
    case interior
    case exterior
    case garden
    case referenceStyle
    case replaceObjects
    case removeObjects
    case newFlooring
    case newWalls
    case furnitureFinder
}

enum UIInterventionLevel: String, Codable, CaseIterable {
    case light
    case medium
    case high

    var apiValue: String {
        switch self {
        case .light: return "Very Low"
        case .medium: return "Mid"
        case .high: return "Extreme"
        }
    }
}

struct LocalProject: Codable, Identifiable {
    let id: String
    let type: ProjectType
    let title: String
    let styleName: String?
    let roomType: String?
    let createdAt: Date
    let originalImagePath: String
    let generatedImagePaths: [String]
    let selectedGeneratedImagePath: String?
    var isFavorite: Bool
}

enum JobStatus: String, Codable {
    case idle
    case uploading
    case queued
    case generating
    case completed
    case failed
}

struct GenerationJob: Codable, Identifiable {
    let id: String
    let queueId: String?
    let projectType: ProjectType
    let createdAt: Date
    var status: JobStatus
    var inputImagePath: String
    var outputImageURLs: [URL]
    var errorMessage: String?
}
