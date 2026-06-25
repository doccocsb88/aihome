import Foundation
import SwiftUI

enum AppRoute: Hashable {
    case splash
    case onboardingIntro
    case mainTab
    case interiorFlow
    case interiorFlowWithImage(UUID)
    case exteriorFlow
    case exteriorFlowWithImage(UUID)
    case gardenFlow
    case gardenFlowWithImage(UUID)
    case referenceStyleFlow
    case referenceStyleFlowWithImage(UUID)
    case removeObjectsFlow
    case removeObjectsFlowWithImage(UUID)
    case replaceObjectsFlow
    case replaceObjectsFlowWithImage(UUID)
    case newFlooringFlow
    case newFlooringFlowWithImage(UUID)
    case newWallsFlow
    case newWallsFlowWithImage(UUID)
    case furnitureFinderFlow
    case furnitureFinderFlowWithImage(UUID)

    var initialImageID: UUID? {
        switch self {
        case .interiorFlowWithImage(let id),
             .exteriorFlowWithImage(let id),
             .gardenFlowWithImage(let id),
             .referenceStyleFlowWithImage(let id),
             .removeObjectsFlowWithImage(let id),
             .replaceObjectsFlowWithImage(let id),
             .newFlooringFlowWithImage(let id),
             .newWallsFlowWithImage(let id),
             .furnitureFinderFlowWithImage(let id):
            return id
        default:
            return nil
        }
    }
}
