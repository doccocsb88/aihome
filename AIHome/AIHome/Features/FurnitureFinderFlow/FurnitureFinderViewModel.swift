import SwiftUI
import Observation

@Observable
final class FurnitureFinderViewModel {
    var draft = FurnitureFinderDraft()
    var isGenerating: Bool = false
    var products: [UIFurnitureProduct] = []
    
    func selectImage(_ image: UIImage) {
        draft.sourceImage = image
    }
    
    func findFurniture() {
        guard draft.sourceImage != nil else { return }
        isGenerating = true
        
        // Mock network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            self.products = [
                UIFurnitureProduct(id: "1", title: "Modern Sofa", imageURL: nil, productURL: nil, priceText: "$499", sourceName: "IKEA"),
                UIFurnitureProduct(id: "2", title: "Wooden Coffee Table", imageURL: nil, productURL: nil, priceText: "$150", sourceName: "Wayfair"),
                UIFurnitureProduct(id: "3", title: "Lounge Chair", imageURL: nil, productURL: nil, priceText: "$299", sourceName: "Amazon")
            ]
            self.isGenerating = false
        }
    }
}
