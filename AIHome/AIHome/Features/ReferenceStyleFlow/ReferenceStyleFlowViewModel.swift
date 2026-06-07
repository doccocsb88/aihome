import Foundation
import SwiftUI

@Observable
class ReferenceStyleFlowViewModel {
    var draft = ReferenceStyleDraft()
    var currentStep: ReferenceStyleStep = .sourceImage
    
    var sourcePhotoPickerViewModel = PhotoSourcePickerViewModel(
        title: "Upload your room",
        subtitle: "Choose a photo of your current space",
        allowsSample: true,
        sampleImages: [
            "ic_interior_sample_01",
            "ic_interior_sample_02",
            "ic_interior_sample_03",
            "ic_interior_sample_04"
        ],
        sampleTitle: "OR TRY A TEMPLATE",
        ctaTitle: "CONTINUE"
    )
    
    var referencePhotoPickerViewModel = PhotoSourcePickerViewModel(
        title: "Upload reference style",
        subtitle: "Choose an image with the style you want to apply",
        allowsSample: true,
        sampleImages: [
            "ic_interior_sample_01",
            "ic_interior_sample_02",
            "ic_interior_sample_03",
            "ic_interior_sample_04"
        ],
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
