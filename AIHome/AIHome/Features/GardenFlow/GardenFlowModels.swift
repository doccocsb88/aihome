import Foundation
import UIKit

struct GardenDraft {
    var sourceImage: UIImage?
    var prompt: String = ""
    var gardenType: String?
    var customStyle: String?
    var designStyle: String?
    var intervention: UIInterventionLevel?
}

enum GardenStep: Int, CaseIterable {
    case photoSelection = 1
    case gardenType = 2
    case designStyle = 3
    case intervention = 4
}
