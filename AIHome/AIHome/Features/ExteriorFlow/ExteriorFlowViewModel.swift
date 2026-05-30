import Foundation
import SwiftUI

@Observable
class ExteriorFlowViewModel {
    var draft = ExteriorDraft()
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "Exterior Redesign",
        subtitle: "Choose your photo. For better results, use a horizontal direction.",
        allowsSample: true,
        sampleImages: [],
        ctaTitle: "Generate"
    )
    
    var canGenerate: Bool {
        return photoPickerViewModel.selectedImage != nil
    }
    
    func prepareDraft() {
        draft.sourceImage = photoPickerViewModel.selectedImage
    }
}
