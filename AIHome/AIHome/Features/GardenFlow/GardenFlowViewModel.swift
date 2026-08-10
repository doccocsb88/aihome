import Foundation
import SwiftUI

@MainActor
@Observable
class GardenFlowViewModel {
    var draft = GardenDraft()
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "",
        subtitle: nil,
        allowsSample: true,
        sampleImages: PhotoSampleAssets.garden,
        ctaTitle: "Continue"
    )

    init() {
        photoPickerViewModel.onSourceSelected = { source in
            TrackingManager.shared.trackSelectPhoto(source: source.trackingSource, feature: .garden)
        }
    }
    
    var canGenerate: Bool {
        return photoPickerViewModel.selectedImage != nil && !draft.prompt.isEmpty
    }
}
