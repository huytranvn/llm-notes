import Foundation

enum VaultEvent: Sendable, Equatable {
    case created(URL)
    case modified(URL)
    case deleted(URL)
    case renamed(from: URL, to: URL)

    var url: URL {
        switch self {
        case .created(let u), .modified(let u), .deleted(let u): return u
        case .renamed(_, let to): return to
        }
    }
}
