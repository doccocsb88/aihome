import Foundation
import SwiftUI

@MainActor
@Observable
class ExteriorFlowViewModel {
    var draft = ExteriorDraft()
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: "",
        subtitle: nil,
        allowsSample: true,
        sampleImages: PhotoSampleAssets.exterior,
        ctaTitle: "Continue"
    )

    init() {
        photoPickerViewModel.onSourceSelected = { source in
            TrackingManager.shared.trackSelectPhoto(source: source.trackingSource, feature: .exterior)
        }
    }
    
    var canGenerate: Bool {
        return photoPickerViewModel.selectedImage != nil && !draft.prompt.isEmpty
    }
}
