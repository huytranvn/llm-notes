import Foundation

struct Note: Identifiable, Hashable, Sendable {
    let id: UUID
    var path: URL
    var title: String
    var modifiedAt: Date
}
