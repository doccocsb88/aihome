import Foundation
import SwiftUI

@MainActor
@Observable
class InteriorFlowViewModel {
    var draft = InteriorDraft()
    var currentStep: InteriorStep = .photoSelection
    
    var photoPickerViewModel = PhotoSourcePickerViewModel(
        title: L10n.PhotoSource.Interior.title,
        subtitle: L10n.PhotoSource.Interior.subtitle,
        allowsSample: true,
        sampleImages: PhotoSampleAssets.interior,
        ctaTitle: L10n.PhotoSource.Interior.cta
    )

    init() {
        photoPickerViewModel.onSourceSelected = { source in
            TrackingManager.shared.trackSelectPhoto(
                source: source.trackingSource,
                feature: .interior
            )
        }
    }
    
    // Room types from PDF
    let roomTypes: [InteriorRoomType] = [
        .diningRoom, .bathroom, .bedroom, .homeOffice,
        .studyRoom, .coffeeShop, .livingRoom, .kitchen,
        .restaurant, .gamingRoom, .attic, .office,
        .balcony
    ]
    
    // Styles from PDF
    let designStyles: [InteriorDesignStyle] = [
        .noStyle, .traditional, .scandinavian, .organicModern,
        .modernFarmHouse, .modern, .minimalist, .japandi, .vintageEclectic,
        .tropical, .rustic, .quietLuxury, .maximalist, .luxurious,
        .industrial, .midcenturyModern, .contemporary, .coastal, .biophilic,
        .scandiBoho, .retro, .neon, .modernArabic, .mediterranean,
        .kidsRoom, .desertModernism, .christmas, .candyLand, .brutalist, .artDeco
    ]
    
    func nextStep() {
        if let next = InteriorStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
    
    func previousStep() {
        if let prev = InteriorStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }

    func applyInitialSourceImage(_ image: UIImage) {
        guard draft.sourceImage == nil else { return }
        draft.sourceImage = image
        photoPickerViewModel.selectedImage = image
    }
    
    var canContinue: Bool {
        switch currentStep {
        case .photoSelection: return photoPickerViewModel.selectedImage != nil
        case .roomType: return draft.roomType != nil
        case .designStyle: return draft.designStyle != nil && (draft.designStyle != .noStyle || (draft.customStyle?.isEmpty == false))
        case .intervention: return draft.intervention != nil
        }
    }
}
