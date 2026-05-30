import Foundation
import Observation

@Observable
final class GenerationLimitViewModel {
    var freeGenerationsRemaining: Int = 3
    var isPro: Bool = false
    
    func upgradeNow() {
        // Trigger purchase flow
        isPro = true
    }
}
