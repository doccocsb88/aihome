import Foundation
import SwiftUI

@Observable
class NewWallsFlowViewModel {
    var draft = NewWallsDraft()
    
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "New Walls",
        subtitle: "Choose a room to update the walls.",
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
