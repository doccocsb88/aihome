import Foundation
import UIKit

enum ExteriorHouseAngle: String {
    case front = "Front of House"
    case side = "Side of House"
    case back = "Back of House"
}

struct ExteriorDraft {
    var sourceImage: UIImage?
    var prompt: String = ""
    var style: String?
    var houseAngle: ExteriorHouseAngle = .front
    var intervention: UIInterventionLevel = .medium
}
