import Foundation

// VaultService — actor wrapping all file operations on the vault folder.
// Spec: openspec/changes/add-vault-storage/specs/vault/spec.md
actor VaultService {
    let root: URL

    private let fileCoordinator = NSFileCoordinator(filePresenter: nil)
    private var watcher: FileWatcher?
    private var eventContinuation: AsyncStream<VaultEvent>.Continuation?

    init(root: URL) {
        self.root = root
    }

    // MARK: - Listing

    func listNotes(in folder: URL? = nil) throws -> [Note] {
        let dir = folder ?? root
        let urls = try FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.contentModificationDateKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        var notes: [Note] = []
        for url in urls where url.pathExtension.lowercased() == "md" {
            let id = try readOrInjectFrontmatterID(at: url)
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
            let modified = attrs[.modificationDate] as? Date ?? .now
            notes.append(Note(id: id, path: url, title: url.deletingPathExtension().lastPathComponent, modifiedAt: modified))
        }
        return notes.sorted { $0.modifiedAt > $1.modifiedAt }
    }

    func listFolders(in folder: URL? = nil) throws -> [Folder] {
        let dir = folder ?? root
        let urls = try FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )
        return urls.compactMap { url in
            let isDir = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            guard isDir else { return nil }
            return Folder(id: url, name: url.lastPathComponent, path: url)
        }
    }

    // MARK: - Read / write

    func read(at url: URL) throws -> (id: UUID, content: String) {
        var data = Data()
        var coordinationError: NSError?
        var ioError: Error?
        fileCoordinator.coordinate(readingItemAt: url, options: [], error: &coordinationError) { actualURL in
            do { data = try Data(contentsOf: actualURL) } catch { ioError = error }
        }
        if let coordinationError { throw coordinationError }
        if let ioError { throw ioError }
        let text = String(decoding: data, as: UTF8.self)
        let (id, _) = parseFrontmatter(text)
        if let id { return (id, text) }
        // Inject ID and persist atomically.
        let injected = injectFrontmatterID(into: text, id: UUID())
        try write(at: url, content: injected.text)
        return (injected.id, injected.text)
    }

    func write(at url: URL, content: String) throws {
        var coordinationError: NSError?
        var ioError: Error?
        fileCoordinator.coordinate(writingItemAt: url, options: [.forReplacing], error: &coordinationError) { actualURL in
            do {
                try content.data(using: .utf8)!.write(to: actualURL, options: [.atomic])
            } catch {
                ioError = error
            }
        }
        if let coordinationError { throw coordinationError }
        if let ioError { throw ioError }
        eventContinuation?.yield(.modified(url))
    }

    func createNote(name: String, in folder: URL? = nil) throws -> Note {
        let dir = folder ?? root
        let url = dir.appendingPathComponent(name).appendingPathExtension("md")
        let id = UUID()
        let body = "---\nid: \(id.uuidString)\n---\n\n# \(name)\n"
        try write(at: url, content: body)
        eventContinuation?.yield(.created(url))
        return Note(id: id, path: url, title: name, modifiedAt: .now)
    }

    func rename(from src: URL, to dst: URL) throws {
        var coordinationError: NSError?
        var ioError: Error?
        fileCoordinator.coordinate(writingItemAt: src, options: [.forMoving],
                                   writingItemAt: dst, options: [.forReplacing],
                                   error: &coordinationError) { srcURL, dstURL in
            do { try FileManager.default.moveItem(at: srcURL, to: dstURL) } catch { ioError = error }
        }
        if let coordinationError { throw coordinationError }
        if let ioError { throw ioError }
        eventContinuation?.yield(.renamed(from: src, to: dst))
    }

    func delete(at url: URL) throws {
        var coordinationError: NSError?
        var ioError: Error?
        fileCoordinator.coordinate(writingItemAt: url, options: [.forDeleting], error: &coordinationError) { actualURL in
            do { try FileManager.default.removeItem(at: actualURL) } catch { ioError = error }
        }
        if let coordinationError { throw coordinationError }
        if let ioError { throw ioError }
        eventContinuation?.yield(.deleted(url))
    }

    // MARK: - Watch

    func watch() -> AsyncStream<VaultEvent> {
        AsyncStream { continuation in
            self.eventContinuation = continuation
            let watcher = FileWatcher(root: self.root) { [weak self] events in
                Task { await self?.forwardWatchEvents(events) }
            }
            watcher.start()
            self.watcher = watcher
            continuation.onTermination = { [weak self] _ in
                Task { await self?.stopWatching() }
            }
        }
    }

    private func forwardWatchEvents(_ events: [VaultEvent]) {
        for event in events { eventContinuation?.yield(event) }
    }

    private func stopWatching() {
        watcher?.stop()
        watcher = nil
        eventContinuation = nil
    }

    // MARK: - Frontmatter

    private func readOrInjectFrontmatterID(at url: URL) throws -> UUID {
        let data = try Data(contentsOf: url)
        let text = String(decoding: data, as: UTF8.self)
        let (id, _) = parseFrontmatter(text)
        if let id { return id }
        let injected = injectFrontmatterID(into: text, id: UUID())
        try write(at: url, content: injected.text)
        return injected.id
    }
}

// MARK: - Frontmatter helpers (free functions, also exercised in tests)

func parseFrontmatter(_ text: String) -> (id: UUID?, body: String) {
    guard text.hasPrefix("---\n") else { return (nil, text) }
    let afterOpen = text.index(text.startIndex, offsetBy: 4)
    guard let closeRange = text.range(of: "\n---\n", range: afterOpen..<text.endIndex) else {
        return (nil, text)
    }
    let yaml = String(text[afterOpen..<closeRange.lowerBound])
    let body = String(text[closeRange.upperBound...])
    for line in yaml.split(separator: "\n") {
        let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 2, parts[0] == "id", let uuid = UUID(uuidString: parts[1]) {
            return (uuid, body)
        }
    }
    return (nil, text)
}

func injectFrontmatterID(into text: String, id: UUID) -> (id: UUID, text: String) {
    if text.hasPrefix("---\n"),
       let closeRange = text.range(of: "\n---\n", range: text.index(text.startIndex, offsetBy: 4)..<text.endIndex) {
        // Existing frontmatter without id — splice id in.
        let yaml = text[text.index(text.startIndex, offsetBy: 4)..<closeRange.lowerBound]
        let newYaml = "id: \(id.uuidString)\n" + yaml
        let body = text[closeRange.upperBound...]
        return (id, "---\n\(newYaml)\n---\n\(body)")
    }
    return (id, "---\nid: \(id.uuidString)\n---\n\n" + text)
}

