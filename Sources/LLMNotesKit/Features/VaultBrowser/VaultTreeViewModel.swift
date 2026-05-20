import Foundation
import AppKit

@MainActor
@Observable
final class VaultTreeViewModel {
    var rootURL: URL?
    var notes: [Note] = []
    var error: String?

    private var service: VaultService?
    private var watchTask: Task<Void, Never>?

    init() {
        if let url = Bookmarks.resolve() {
            Task { await openVault(at: url, fromBookmark: true) }
        }
    }

    func chooseVault() async {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Open Vault"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        try? Bookmarks.save(url)
        await openVault(at: url, fromBookmark: false)
    }

    func openVault(at url: URL, fromBookmark: Bool) async {
        if fromBookmark { _ = url.startAccessingSecurityScopedResource() }
        rootURL = url
        let service = VaultService(root: url)
        self.service = service
        await reload()
        watchTask?.cancel()
        watchTask = Task { [weak self] in
            guard let self else { return }
            for await event in await service.watch() {
                _ = event
                await self.reload()
            }
        }
    }

    func reload() async {
        guard let service else { return }
        do {
            notes = try await service.listNotes()
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func createNote() async {
        guard let service else { return }
        let name = "Untitled-\(Int(Date().timeIntervalSince1970))"
        _ = try? await service.createNote(name: name)
        await reload()
    }
}
