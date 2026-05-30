import Foundation

protocol InspirationServiceProtocol {
    func getInspirations() -> [InspirationItem]
    func toggleLike(for id: String)
}

final class MockInspirationService: InspirationServiceProtocol {
    private var items: [InspirationItem] = [
        InspirationItem(id: "1", title: "THE CURVE LOFT", subtitle: "Modern Workspace", category: .interior, spaceType: "Living room", styleTag: "Minimalist", imageNameOrURL: "dummy_image_1", isLiked: false),
        InspirationItem(id: "2", title: "MODERN LOFT", subtitle: "Urban Living", category: .interior, spaceType: "Bedroom", styleTag: "Industrial", imageNameOrURL: "dummy_image_2", isLiked: true),
        InspirationItem(id: "3", title: "MONOLITH KITCHEN", subtitle: "Dark Stone", category: .interior, spaceType: "Kitchen", styleTag: "Modern", imageNameOrURL: "dummy_image_3", isLiked: false),
        InspirationItem(id: "4", title: "VILLA FACADE", subtitle: "Luxury Exterior", category: .exterior, spaceType: "Villa", styleTag: "Luxury", imageNameOrURL: "dummy_image_4", isLiked: false),
        InspirationItem(id: "5", title: "ZEN GARDEN", subtitle: "Peaceful Retreat", category: .garden, spaceType: "Garden", styleTag: "Zen", imageNameOrURL: "dummy_image_5", isLiked: true)
    ]
    
    func getInspirations() -> [InspirationItem] {
        return items
    }
    
    func toggleLike(for id: String) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].isLiked.toggle()
        }
    }
}
