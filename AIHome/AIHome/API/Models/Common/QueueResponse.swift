import Foundation

public struct QueueResponse: Codable, Equatable {
    public let id: String?
    public let status: String?
    public let message: String?
    public let queueId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case message
        case queueId = "queue_id"
    }

    public var resolvedQueueId: String? {
        id ?? queueId
    }
}
