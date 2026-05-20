## Why

The app needs a portable, sync-friendly storage layer before any other feature can be built. Plain `.md` files in a user-chosen folder ("vault") are the foundation — every other capability (editor, search, chat, MCP) reads and writes through this layer. Doing this first gives every later capability a stable async API and a single source of truth.

## What Changes

- Add a user flow to pick a root vault folder and persist a security-scoped bookmark.
- Introduce `VaultService` (actor) with async APIs for listing, reading, writing, moving, renaming, and deleting notes and folders.
- Watch the vault with FSEvents and expose an `AsyncStream` of change events to the rest of the app.
- Establish a stable note identifier: a UUID stored in YAML frontmatter so renames never break links or conversation references.
- All writes go through `NSFileCoordinator` for safe coexistence with iCloud Drive / Dropbox.

## Capabilities

### New Capabilities
- `vault`: portable file-backed storage of notes and folders, with change notifications and stable identifiers.

### Modified Capabilities
<!-- none — first capability -->

## Impact

- New top-level service `Services/Vault/`.
- New model types `Core/Models/Note.swift`, `Folder.swift`.
- Adds `UserDefaults` key for the security-scoped bookmark.
- No external dependencies introduced.
