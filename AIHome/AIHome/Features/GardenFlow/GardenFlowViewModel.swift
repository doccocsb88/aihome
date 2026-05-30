import Foundation
import SwiftUI

@Observable
class GardenFlowViewModel {
    var draft = GardenDraft()
    var currentStep: GardenStep = .photoSelection
    
    let gardenTypes = [
        "Backyard", "Front yard", "Patio", "Terrace",
        "Courtyard", "Pool area", "Balcony"
    ]
    
    let designStyles = [
        "Custom style", "Modern", "Tropical",
        "Minimalist", "Zen", "Mediterranean", "Rustic"
    ]
    
    func nextStep() {
        if let next = GardenStep(rawValue: currentStep.rawValue + 1) {
            currentStep = next
        }
    }
    
    func previousStep() {
        if let prev = GardenStep(rawValue: currentStep.rawValue - 1) {
            currentStep = prev
        }
    }
    
    var canContinue: Bool {
        switch currentStep {
        case .photoSelection: return draft.sourceImage != nil
        case .gardenType: return draft.gardenType != nil
        case .designStyle: return draft.designStyle != nil && (draft.designStyle != "Custom style" || (draft.customStyle?.isEmpty == false))
        case .intervention: return draft.intervention != nil
        }
    }
}
