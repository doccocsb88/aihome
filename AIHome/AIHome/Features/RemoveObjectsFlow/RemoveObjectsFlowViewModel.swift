import Foundation
import SwiftUI

@MainActor
@Observable
class RemoveObjectsFlowViewModel {
    var draft = RemoveObjectsDraft()
    
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "",
        subtitle: nil,
        allowsSample: true,
        sampleImages: PhotoSampleAssets.interior,
        ctaTitle: "Continue"
    )

    init() {
        photoPickerViewModel.onSourceSelected = { source in
            TrackingManager.shared.trackSelectPhoto(source: source.trackingSource, feature: .removeObject)
        }
    }
    
    var canGenerate: Bool {
        return photoPickerViewModel.selectedImage != nil && !draft.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func prepareDraft() {
        draft.sourceImage = photoPickerViewModel.selectedImage
    }
}
