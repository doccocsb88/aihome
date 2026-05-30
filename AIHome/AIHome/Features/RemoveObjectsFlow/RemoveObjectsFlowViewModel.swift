import Foundation
import SwiftUI

@Observable
class RemoveObjectsFlowViewModel {
    var draft = RemoveObjectsDraft()
    
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "Remove Objects",
        subtitle: "Choose an image to clean up.",
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
