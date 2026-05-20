import Foundation
import AppKit

@MainActor
@Observable
public final class VaultTreeViewModel {
    public var rootURL: URL?
    public var notes: [Note] = []
    public var error: String?

    private var service: VaultService?
    private var watchTask: Task<Void, Never>?

    public init() {
        if let url = Bookmarks.resolve() {
            Task { await openVault(at: url, fromBookmark: true) }
        }
    }

    public func chooseVault() async {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Open Vault"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? Bookmarks.save(url)
        await openVault(at: url, fromBookmark: false)
    }

    public func openVault(at url: URL, fromBookmark: Bool) async {
        if fromBookmark { _ = url.startAccessingSecurityScopedResource() }
        rootURL = url
        let service = VaultService(root: url)
        self.service = service
        await reload()
        watchTask?.cancel()
        watchTask = Task { [weak self] in
            guard let self else { return }
            for await _ in await service.watch() {
                await self.reload()
            }
        }
    }

    public func reload() async {
        guard let service else { return }
        do {
            notes = try await service.listNotes()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    public func createNote() async {
        guard let service else { return }
        let name = "Untitled-\(Int(Date().timeIntervalSince1970))"
        _ = try? await service.createNote(name: name)
        await reload()
    }

    public func loadContent(for id: UUID) async -> String? {
        guard let service, let note = notes.first(where: { $0.id == id }) else { return nil }
        return try? await service.read(at: note.path).content
    }

    public func save(noteID: UUID, content: String) async {
        guard let service, let note = notes.first(where: { $0.id == noteID }) else { return }
        try? await service.write(at: note.path, content: content)
    }
}
