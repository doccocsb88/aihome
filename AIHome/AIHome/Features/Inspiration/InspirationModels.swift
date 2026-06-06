import Foundation

enum InspirationCategory: String, Codable, CaseIterable, Identifiable {
    case interior = "Interior"
    case exterior = "Exterior"
    case garden = "Garden"

    var id: String { rawValue }
}

enum InspirationInterventionLevel: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

struct InspirationItem: Codable, Identifiable, Equatable {
    let id: String
    let category: InspirationCategory
    let spaceType: String
    let styleTag: String
    let beforeImageName: String
    let afterImageName: String
    let title: String
    let subtitle: String
    let interventionLevel: InspirationInterventionLevel
    var isLiked: Bool
}
