import Foundation
import SwiftUI

@Observable
class ResultViewModel {
    var project: LocalProject
    var originalImage: UIImage
    var generatedImages: [UIImage]
    var selectedIndex: Int = 0
    var availableAdvancedTools: [ProjectType]
    var isPro: Bool
    var hasWatermark: Bool
    var isArchived: Bool
    var selectedFeedback: ResultFeedbackAction?
    
    var selectedImage: UIImage? {
        guard !generatedImages.isEmpty, selectedIndex >= 0, selectedIndex < generatedImages.count else { return nil }
        return generatedImages[selectedIndex]
    }
    
    init(project: LocalProject, originalImage: UIImage, generatedImages: [UIImage], availableAdvancedTools: [ProjectType], isPro: Bool = false, hasWatermark: Bool = true) {
        self.project = project
        self.originalImage = originalImage
        self.generatedImages = generatedImages
        self.availableAdvancedTools = project.type.advancedToolsForType
        self.isPro = isPro
        self.hasWatermark = hasWatermark
        self.isArchived = !project.generatedImagePaths.isEmpty
    }
}

enum ResultFeedbackAction {
    case positive
    case negative
}
