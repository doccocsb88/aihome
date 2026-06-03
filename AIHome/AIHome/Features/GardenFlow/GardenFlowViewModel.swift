import Foundation
import SwiftUI

@Observable
class GardenFlowViewModel {
    var draft = GardenDraft()
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "",
        subtitle: nil,
        allowsSample: false,
        sampleImages: [],
        ctaTitle: "Continue"
    )
    
    var canGenerate: Bool {
        return photoPickerViewModel.selectedImage != nil && !draft.prompt.isEmpty
    }
}
