import Foundation
import UIKit

struct InteriorDraft {
    var sourceImage: UIImage?
    var roomType: String?
    var customStyle: String?
    var designStyle: String?
    var intervention: UIInterventionLevel?
}

enum InteriorStep: Int, CaseIterable {
    case photoSelection = 1
    case roomType = 2
    case designStyle = 3
    case intervention = 4
}
