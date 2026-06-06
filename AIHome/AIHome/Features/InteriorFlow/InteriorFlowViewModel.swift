import Foundation
import SwiftUI

@Observable
class InteriorFlowViewModel {
    var draft = InteriorDraft()
    var currentStep: InteriorStep = .photoSelection
    
    // Room types from PDF
    let roomTypes = [
        "Dining room", "Bathroom", "Bedroom", "Home office",
        "Study room", "Coffee shop", "Living room", "Kitchen",
        "Restaurant", "Gaming room", "Attic", "Office",
        "Toilet", "Balcony"
    ]
    
    // Styles from PDF
    let designStyles = [
        "Custom style", "Contemporary", "Luxurious",
        "St. Valentines", "Industrial", "Cozy Cabin"
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
        currentStep = .roomType
    }
    
    var canContinue: Bool {
        switch currentStep {
        case .photoSelection: return draft.sourceImage != nil
        case .roomType: return draft.roomType != nil
        case .designStyle: return draft.designStyle != nil && (draft.designStyle != "Custom style" || (draft.customStyle?.isEmpty == false))
        case .intervention: return draft.intervention != nil
        }
    }
}
