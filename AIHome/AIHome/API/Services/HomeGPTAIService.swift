import Foundation

public final class HomeGPTAIService: HomeGPTAIServiceProtocol {
    public static let shared = HomeGPTAIService()

    private let providerResolver: () -> any HomeGPTGenerationProviderProtocol

    public init(
        providerResolver: @escaping () -> any HomeGPTGenerationProviderProtocol = {
            HomeGPTProviderFactory.sharedProvider()
        }
    ) {
        self.providerResolver = providerResolver
    }

    public convenience init(provider: any HomeGPTGenerationProviderProtocol) {
        self.init(providerResolver: { provider })
    }

    private var provider: any HomeGPTGenerationProviderProtocol {
        providerResolver()
    }

    public static var selectedProviderKind: HomeGPTProviderKind {
        HomeGPTProviderRegistry.selectedKind
    }

    public static func useProvider(_ kind: HomeGPTProviderKind) {
        HomeGPTProviderRegistry.selectedKind = kind
    }

    public func generateInterior(request: InteriorGenerationInput) async throws -> [String] {
        try await provider.generateInterior(request: request)
    }

    public func generateExterior(request: ExteriorGenerationInput) async throws -> [String] {
        try await provider.generateExterior(request: request)
    }

    public func generateGarden(request: GardenGenerationInput) async throws -> [String] {
        try await provider.generateGarden(request: request)
    }

    public func generateReferenceStyle(request: ReferenceStyleInput) async throws -> [String] {
        try await provider.generateReferenceStyle(request: request)
    }

    public func removeObjects(request: RemoveObjectsInput) async throws -> [String] {
        try await provider.removeObjects(request: request)
    }

    public func replaceObjects(request: ReplaceObjectsInput) async throws -> [String] {
        try await provider.replaceObjects(request: request)
    }

    public func generateNewFlooring(request: NewFlooringInput) async throws -> [String] {
        try await provider.generateNewFlooring(request: request)
    }

    public func generateNewWalls(request: NewWallsInput) async throws -> [String] {
        try await provider.generateNewWalls(request: request)
    }

    public func findFurniture(image: HomeDesignsImageSource, countryCode: String?) async throws -> FurnitureFinderResponse {
        try await provider.findFurniture(image: image, countryCode: countryCode)
    }

    public func upscale(image: HomeDesignsImageSource) async throws -> [String] {
        try await provider.upscale(image: image)
    }
}
