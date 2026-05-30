import Foundation

public protocol HomeDesignsAPIClientProtocol {
    func perfectRedesign(_ request: PerfectRedesignRequest) async throws -> QueueResponse
    func checkPerfectRedesignStatus(queueId: String) async throws -> StatusCheckResponse

    func designTransfer(_ request: DesignTransferRequest) async throws -> GeneratedImagesResponse

    func createMaskImage(_ request: CreateMaskImageRequest) async throws -> CreateMaskImageResponse
    func furnitureRemoval(_ request: FurnitureRemovalRequest) async throws -> GeneratedImagesResponse

    func changeColorTextures(_ request: ChangeColorTexturesRequest) async throws -> GeneratedImagesResponse
    func materialSwap(_ request: MaterialSwapRequest) async throws -> GeneratedImagesResponse

    func floorEditor(_ request: FloorEditorRequest) async throws -> GeneratedImagesResponse
    func paintVisualizer(_ request: PaintVisualizerRequest) async throws -> GeneratedImagesResponse

    func furnitureFinder(_ request: FurnitureFinderRequest) async throws -> FurnitureFinderResponse
    func fullHD(_ request: FullHDRequest) async throws -> GeneratedImagesResponse
}
