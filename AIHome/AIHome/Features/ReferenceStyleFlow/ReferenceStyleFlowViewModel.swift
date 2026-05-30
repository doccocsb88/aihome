import Foundation
import SwiftUI

@Observable
class ReferenceStyleFlowViewModel {
    var draft = ReferenceStyleDraft()
    var currentStep: ReferenceStyleStep = .sourceImage
    
    var canContinue: Bool {
        switch currentStep {
        case .sourceImage:
            return draft.sourceImage != nil
        case .referenceImage:
            return draft.referenceImage != nil
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
