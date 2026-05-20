import Foundation

struct Folder: Identifiable, Hashable, Sendable {
    let id: URL
    var name: String
    var path: URL
}
