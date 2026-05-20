## 1. Models

- [ ] 1.1 Define `Note` (id: UUID, path: URL, title: String, modifiedAt: Date) in `Core/Models/Note.swift`
- [ ] 1.2 Define `Folder` in `Core/Models/Folder.swift`
- [ ] 1.3 Define `VaultEvent` enum (`created`, `modified`, `deleted`, `renamed`) in `Services/Vault/VaultEvent.swift`

## 2. Bookmarks

- [ ] 2.1 Implement `Bookmarks.save(url:)` / `resolve()` using security-scoped bookmarks in `Services/Vault/Bookmarks.swift`
- [ ] 2.2 Add SwiftUI "Open Vault" prompt at first launch

## 3. VaultService

- [ ] 3.1 Implement `VaultService` actor in `Services/Vault/VaultService.swift`
- [ ] 3.2 Implement `list(folder:)`, `read(noteID:)`, `write(noteID:content:)`, `rename`, `move`, `delete`
- [ ] 3.3 Use `NSFileCoordinator` for all reads/writes
- [ ] 3.4 Frontmatter parsing: inject UUID on first read of legacy files; preserve on rename

## 4. File watcher

- [ ] 4.1 Implement FSEvents wrapper in `Services/Vault/FileWatcher.swift`
- [ ] 4.2 Expose `AsyncStream<VaultEvent>` from `VaultService.watch()`
- [ ] 4.3 Coalesce bursts with a 100 ms debounce

## 5. Tests

- [ ] 5.1 Round-trip read/write tests with a temp vault
- [ ] 5.2 Rename preserves `id` test
- [ ] 5.3 FSEvents emits `modified` after external edit (simulated via `Process` touching a file)
- [ ] 5.4 Legacy-file frontmatter injection test
