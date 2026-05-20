import XCTest
@testable import LLMNotesKit

final class PlaceholderTests: XCTestCase {
    func testNoteHasStableID() {
        let id = UUID()
        let note = Note(id: id, path: URL(fileURLWithPath: "/tmp/a.md"), title: "a", modifiedAt: .now)
        XCTAssertEqual(note.id, id)
    }
}
