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

    init?(flow projectType: ProjectType, initialImageID: UUID? = nil) {
        switch projectType {
        case .interior:
            self = initialImageID.map(AppRoute.interiorFlowWithImage) ?? .interiorFlow
        case .exterior:
            self = initialImageID.map(AppRoute.exteriorFlowWithImage) ?? .exteriorFlow
        case .garden:
            self = initialImageID.map(AppRoute.gardenFlowWithImage) ?? .gardenFlow
        case .referenceStyle:
            self = initialImageID.map(AppRoute.referenceStyleFlowWithImage) ?? .referenceStyleFlow
        case .removeObjects:
            self = initialImageID.map(AppRoute.removeObjectsFlowWithImage) ?? .removeObjectsFlow
        case .replaceObjects:
            self = initialImageID.map(AppRoute.replaceObjectsFlowWithImage) ?? .replaceObjectsFlow
        case .newFlooring:
            self = initialImageID.map(AppRoute.newFlooringFlowWithImage) ?? .newFlooringFlow
        case .newWalls:
            self = initialImageID.map(AppRoute.newWallsFlowWithImage) ?? .newWallsFlow
        case .furnitureFinder:
            self = initialImageID.map(AppRoute.furnitureFinderFlowWithImage) ?? .furnitureFinderFlow
        case .edit:
            return nil
        }
    }

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
