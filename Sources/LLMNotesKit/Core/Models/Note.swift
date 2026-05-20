import Foundation

public struct Note: Identifiable, Hashable, Sendable {
    public let id: UUID
    public var path: URL
    public var title: String
    public var modifiedAt: Date

    public init(id: UUID, path: URL, title: String, modifiedAt: Date) {
        self.id = id
        self.path = path
        self.title = title
        self.modifiedAt = modifiedAt
    }
}
