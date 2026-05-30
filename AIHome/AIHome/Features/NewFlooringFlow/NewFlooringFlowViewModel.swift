import Foundation
import SwiftUI

@Observable
class NewFlooringFlowViewModel {
    var draft = NewFlooringDraft()
    
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "New Flooring",
        subtitle: "Choose a room to update the flooring.",
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
