import Foundation
import SwiftUI

@Observable
class ResultViewModel {
    var project: LocalProject
    var originalImage: UIImage
    var generatedImages: [UIImage]
    var selectedIndex: Int = 0
    var availableAdvancedTools: [AdvancedTool]
    var isPro: Bool
    var hasWatermark: Bool
    
    var selectedImage: UIImage? {
        guard !generatedImages.isEmpty, selectedIndex >= 0, selectedIndex < generatedImages.count else { return nil }
        return generatedImages[selectedIndex]
    }
    
    init(project: LocalProject, originalImage: UIImage, generatedImages: [UIImage], availableAdvancedTools: [AdvancedTool], isPro: Bool = false, hasWatermark: Bool = true) {
        self.project = project
        self.originalImage = originalImage
        self.generatedImages = generatedImages
        self.availableAdvancedTools = availableAdvancedTools
        self.isPro = isPro
        self.hasWatermark = hasWatermark
    }
}
