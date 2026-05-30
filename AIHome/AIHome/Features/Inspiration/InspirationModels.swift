import Foundation

enum InspirationCategory: String, Codable, CaseIterable {
    case interior
    case exterior
    case garden
}

struct InspirationItem: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let category: InspirationCategory
    let spaceType: String
    let styleTag: String
    let imageNameOrURL: String
    var isLiked: Bool
}
