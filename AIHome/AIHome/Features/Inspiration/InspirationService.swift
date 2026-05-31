import Foundation

protocol InspirationServiceProtocol {
    func getInspirations() -> [InspirationItem]
    func toggleLike(for id: String)
}

final class MockInspirationService: InspirationServiceProtocol {
    private var items: [InspirationItem] = [
        InspirationItem(
            id: "1", 
            title: "THE CURVE LOFT", 
            subtitle: "A fluid architectural approach where organic shapes meet rigid industrial structures.", 
            category: .interior, 
            spaceType: "Loft", 
            styleTag: "Modern", 
            imageNameOrURL: "ic_Inspiration_the_curve_loft", 
            isLiked: false
        ),
        InspirationItem(
            id: "2", 
            title: "MODERN VILLA", 
            subtitle: "Clean lines and expansive glass walls create a seamless transition to nature.", 
            category: .exterior, 
            spaceType: "Villa", 
            styleTag: "Modern", 
            imageNameOrURL: "ic_home_exterior", // Reusing home asset
            isLiked: true
        ),
        InspirationItem(
            id: "3", 
            title: "ZEN RETREAT", 
            subtitle: "Minimalist garden design focused on tranquility and natural materials.", 
            category: .garden, 
            spaceType: "Garden", 
            styleTag: "Zen", 
            imageNameOrURL: "ic_home_garden", // Reusing home asset
            isLiked: false
        )
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
