import UIKit

enum ReferenceStyleStep: Int {
    case sourceImage = 1
    case referenceImage = 2
    case intervention = 3
}

struct ReferenceStyleDraft {
    var sourceImage: UIImage?
    var referenceImage: UIImage?
    var intervention: UIInterventionLevel = .high
}
