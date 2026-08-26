import Foundation

public struct FurnitureFinderResponse: Codable, Equatable {
    public let resultArray: [String: [FurnitureProduct]]?
}

public struct FurnitureProduct: Codable, Equatable {
    public let position: Int?
    public let title: String?
    public let link: String?
    public let source: String?
    public let sourceIcon: String?
    public let rating: Double?
    public let reviews: Int?
    public let price: FurniturePrice?
    public let thumbnail: String?

    enum CodingKeys: String, CodingKey {
        case position
        case title
        case link
        case source
        case sourceIcon = "source_icon"
        case rating
        case reviews
        case price
        case thumbnail
    }
}

public struct FurniturePrice: Codable, Equatable {
    public let value: String?
}
