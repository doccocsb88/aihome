import Foundation

public struct InteriorGenerationInput {
    let image: HomeDesignsImageSource
    let aiIntervention: AIIntervention
    let noDesign: Int
    let designStyle: String
    let roomType: String
    let customInstruction: String?
}

public struct ExteriorGenerationInput {
    let image: HomeDesignsImageSource
    let aiIntervention: AIIntervention
    let noDesign: Int
    let designStyle: String
    let houseAngle: String
    let customInstruction: String?
}

public struct GardenGenerationInput {
    let image: HomeDesignsImageSource
    let aiIntervention: AIIntervention
    let noDesign: Int
    let designStyle: String
    let gardenType: String
    let customInstruction: String?
}

public struct ReferenceStyleInput {
    let image: HomeDesignsImageSource
    let styleImage: HomeDesignsImageSource
    let aiIntervention: AIIntervention
}

public struct RemoveObjectsInput {
    let image: HomeDesignsImageSource
    let prompt: String
}

public struct ReplaceObjectsInput {
    let image: HomeDesignsImageSource
    let prompt: String
    let noDesign: Int
}

public struct NewFlooringInput {
    let image: HomeDesignsImageSource
    let textureImage: HomeDesignsImageSource?
    let noOfTexture: String
    let prompt: String?
}

public struct NewWallsInput {
    let image: HomeDesignsImageSource
    let prompt: String
    let noDesign: Int
}

public protocol HomeGPTAIServiceProtocol {
    func generateInterior(request: InteriorGenerationInput) async throws -> [String]
    func generateExterior(request: ExteriorGenerationInput) async throws -> [String]
    func generateGarden(request: GardenGenerationInput) async throws -> [String]
    func generateReferenceStyle(request: ReferenceStyleInput) async throws -> [String]
    func removeObjects(request: RemoveObjectsInput) async throws -> [String]
    func replaceObjects(request: ReplaceObjectsInput) async throws -> [String]
    func generateNewFlooring(request: NewFlooringInput) async throws -> [String]
    func generateNewWalls(request: NewWallsInput) async throws -> [String]
    func findFurniture(image: HomeDesignsImageSource, countryCode: String?) async throws -> FurnitureFinderResponse
    func upscale(image: HomeDesignsImageSource) async throws -> [String]
}
