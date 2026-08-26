import Foundation
import SwiftUI

@MainActor
@Observable
class ReferenceStyleFlowViewModel {
    var draft = ReferenceStyleDraft()
    var currentStep: ReferenceStyleStep = .sourceImage
    
    var sourcePhotoPickerViewModel = PhotoSourcePickerViewModel(
        title: "Upload your room",
        subtitle: "Choose a photo of your current space",
        allowsSample: true,
        sampleImages: PhotoSampleAssets.interior,
        sampleTitle: "OR TRY A TEMPLATE",
        ctaTitle: "CONTINUE"
    )
    
    var referencePhotoPickerViewModel = PhotoSourcePickerViewModel(
        title: "Upload reference style",
        subtitle: "Choose an image with the style you want to apply",
        allowsSample: true,
        sampleImages: PhotoSampleAssets.interior,
        sampleTitle: "OR TRY A TEMPLATE",
        ctaTitle: "CONTINUE"
    )
    
    var canContinue: Bool {
        switch currentStep {
        case .sourceImage:
            return sourcePhotoPickerViewModel.selectedImage != nil
        case .referenceImage:
            return referencePhotoPickerViewModel.selectedImage != nil
        case .intervention:
            return true
        }
    }

    init() {
        sourcePhotoPickerViewModel.onSourceSelected = { source in
            TrackingManager.shared.trackSelectPhoto(source: source.trackingSource, feature: .referenceStyle)
        }
        referencePhotoPickerViewModel.onSourceSelected = { source in
            TrackingManager.shared.trackSelectPhoto(source: source.trackingSource, feature: .referenceStyle)
        }
    }
    
    func nextStep() {
        if currentStep == .sourceImage {
            currentStep = .referenceImage
        } else if currentStep == .referenceImage {
            currentStep = .intervention
        }
    }
    
    func previousStep() {
        if currentStep == .intervention {
            currentStep = .referenceImage
        } else if currentStep == .referenceImage {
            currentStep = .sourceImage
        }
    }
}
