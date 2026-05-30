import Foundation
import SwiftUI

@Observable
class ReplaceObjectsFlowViewModel {
    var draft = ReplaceObjectsDraft()
    
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "Replace Objects",
        subtitle: "Choose an image to modify.",
        allowsSample: true,
        sampleImages: [],
        ctaTitle: "Continue"
    )
    
    var canGenerate: Bool {
        return photoPickerViewModel.selectedImage != nil && !draft.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func prepareDraft() {
        draft.sourceImage = photoPickerViewModel.selectedImage
    }
}
