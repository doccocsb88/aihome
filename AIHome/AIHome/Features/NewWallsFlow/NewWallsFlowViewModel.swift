import Foundation
import SwiftUI

@MainActor
@Observable
class NewWallsFlowViewModel {
    var draft = NewWallsDraft()
    
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "",
        subtitle: nil,
        allowsSample: true,
        sampleImages: PhotoSampleAssets.interior,
        ctaTitle: "Continue"
    )

    init() {
        photoPickerViewModel.onSourceSelected = { source in
            TrackingManager.shared.trackSelectPhoto(source: source.trackingSource, feature: .newWall)
        }
    }
    
    var canGenerate: Bool {
        return photoPickerViewModel.selectedImage != nil && !draft.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func prepareDraft() {
        draft.sourceImage = photoPickerViewModel.selectedImage
    }
}
