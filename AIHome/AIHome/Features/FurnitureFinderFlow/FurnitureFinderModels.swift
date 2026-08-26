import SwiftUI

struct FurnitureFinderDraft {
    var sourceImage: UIImage?
    var prompt: String?
}

struct UIFurnitureProduct: Codable, Identifiable {
    let id: String
    let title: String
    let imageURL: URL?
    let productURL: URL?
    let priceText: String?
    let sourceName: String?
}
