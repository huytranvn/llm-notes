import Foundation
import SwiftUI

@MainActor
@Observable
public final class AppState {
    public enum SidebarSection: String, CaseIterable, Identifiable {
        case notes, chats
        public var id: String { rawValue }
        public var label: String {
            switch self {
            case .notes: return "Notes"
            case .chats: return "Chats"
            }
        }
        public var icon: String {
            switch self {
            case .notes: return "doc.text"
            case .chats: return "bubble.left.and.bubble.right"
            }
        }
    }

    public var section: SidebarSection = .notes
    public var selectedNoteID: UUID?
    public var selectedConversationID: UUID?
    public var isChatVisible: Bool = true
    public var sidebarQuery: String = ""

    public init() {}
}
