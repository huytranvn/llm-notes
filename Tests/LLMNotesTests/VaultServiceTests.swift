import XCTest
@testable import LLMNotesKit

final class VaultServiceTests: XCTestCase {
    private var tempRoot: URL!

    override func setUpWithError() throws {
        tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("vault-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempRoot, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempRoot)
    }

    func testCreateNoteHasFrontmatterID() async throws {
        let svc = VaultService(root: tempRoot)
        let note = try await svc.createNote(name: "Hello")
        let (id, content) = try await svc.read(at: note.path)
        XCTAssertEqual(id, note.id)
        XCTAssertTrue(content.contains("id: \(note.id.uuidString)"))
    }

    func testLegacyFileGetsIDInjectedOnRead() async throws {
        let url = tempRoot.appendingPathComponent("legacy.md")
        try "# Just a note\nbody".write(to: url, atomically: true, encoding: .utf8)
        let svc = VaultService(root: tempRoot)
        let (id1, _) = try await svc.read(at: url)
        let (id2, _) = try await svc.read(at: url)
        XCTAssertEqual(id1, id2, "ID must be stable across reads")
        let raw = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(raw.hasPrefix("---\n"))
        XCTAssertTrue(raw.contains("id: \(id1.uuidString)"))
    }

    func testRenamePreservesID() async throws {
        let svc = VaultService(root: tempRoot)
        let note = try await svc.createNote(name: "Original")
        let newURL = tempRoot.appendingPathComponent("Renamed.md")
        try await svc.rename(from: note.path, to: newURL)
        let (id, _) = try await svc.read(at: newURL)
        XCTAssertEqual(id, note.id)
    }

    func testParseFrontmatter() {
        let uuid = UUID()
        let text = "---\nid: \(uuid.uuidString)\nfoo: bar\n---\nbody here"
        let (id, body) = parseFrontmatter(text)
        XCTAssertEqual(id, uuid)
        XCTAssertEqual(body, "body here")
    }

    func testListNotesSortedByModified() async throws {
        let svc = VaultService(root: tempRoot)
        _ = try await svc.createNote(name: "First")
        try await Task.sleep(nanoseconds: 50_000_000)
        let second = try await svc.createNote(name: "Second")
        let notes = try await svc.listNotes()
        XCTAssertEqual(notes.first?.id, second.id)
    }

    func testWriteEmitsModifiedEvent() async throws {
        let svc = VaultService(root: tempRoot)
        let note = try await svc.createNote(name: "Watch")

        let stream = await svc.watch()
        let expectation = expectation(description: "modified event")
        let collector = Task {
            for await event in stream {
                if case .modified = event { expectation.fulfill(); return }
            }
        }
        // Give the stream a moment to set its continuation.
        try await Task.sleep(nanoseconds: 50_000_000)
        try await svc.write(at: note.path, content: "---\nid: \(note.id.uuidString)\n---\nedited")
        await fulfillment(of: [expectation], timeout: 2)
        collector.cancel()
    }
}
