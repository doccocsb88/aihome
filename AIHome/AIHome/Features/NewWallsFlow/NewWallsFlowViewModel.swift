import Foundation
import SwiftUI

@Observable
class NewWallsFlowViewModel {
    var draft = NewWallsDraft()
    
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "",
        subtitle: nil,
        allowsSample: false,
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
