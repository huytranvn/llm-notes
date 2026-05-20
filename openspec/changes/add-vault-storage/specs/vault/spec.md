## ADDED Requirements

### Requirement: Vault root selection
The system SHALL allow the user to pick a root folder on disk that contains their notes, and SHALL persist access to that folder across app restarts via a security-scoped bookmark.

#### Scenario: First launch with no vault
- **WHEN** the app starts and no vault bookmark exists in `UserDefaults`
- **THEN** the app SHALL present an "Open Vault" prompt
- **AND** SHALL store a security-scoped bookmark on confirmation

#### Scenario: Subsequent launch with a saved vault
- **WHEN** the app starts and a valid bookmark exists
- **THEN** the app SHALL resolve the bookmark and open the vault without prompting

#### Scenario: Bookmark becomes stale
- **WHEN** the bookmark cannot be resolved (folder moved/deleted)
- **THEN** the app SHALL prompt the user to relocate or re-pick the vault

### Requirement: Async file operations
`VaultService` SHALL expose async methods to list, read, write, move, rename, and delete notes and folders, and SHALL serialize concurrent access via an `actor`.

#### Scenario: Read a note
- **WHEN** a caller invokes `read(noteID:)`
- **THEN** the service SHALL return the note's markdown content and metadata
- **AND** the call SHALL not block the main thread

#### Scenario: Write a note
- **WHEN** a caller invokes `write(noteID:content:)`
- **THEN** the service SHALL persist the content atomically via `NSFileCoordinator`
- **AND** SHALL emit a change event for that note

### Requirement: Stable note identifiers
Every note SHALL carry a UUID in YAML frontmatter (`id:`); renames and moves SHALL preserve this identifier so other capabilities can reference notes durably.

#### Scenario: New note creation
- **WHEN** a caller creates a new note
- **THEN** the service SHALL insert a YAML frontmatter block with a freshly generated UUID

#### Scenario: Existing note without frontmatter
- **WHEN** the vault contains a `.md` file with no `id:` field
- **THEN** the service SHALL inject a UUID on first read
- **AND** SHALL write the updated frontmatter back atomically

#### Scenario: Note rename preserves identity
- **WHEN** a note is renamed via `rename(noteID:to:)`
- **THEN** the note's `id` SHALL remain unchanged
- **AND** consumers tracking the note by ID SHALL continue to resolve it

### Requirement: Change notifications
`VaultService` SHALL expose an `AsyncStream` of vault events (`created`, `modified`, `deleted`, `renamed`) backed by FSEvents, so other capabilities (editor, search index, chat) can react to external edits.

#### Scenario: External edit by another app
- **WHEN** a `.md` file inside the vault is modified by an external editor
- **THEN** subscribers SHALL receive a `modified` event for that file within 1 second

#### Scenario: Burst coalescing
- **WHEN** many files change in a short window (e.g. a bulk sync from iCloud)
- **THEN** the stream SHALL coalesce events to avoid overwhelming subscribers

### Requirement: Sync-safe writes
All writes SHALL be coordinated with `NSFileCoordinator` so that iCloud Drive, Dropbox, and similar file providers do not see partial files or fight the writer.

#### Scenario: iCloud-hosted vault
- **WHEN** the vault folder lives in iCloud Drive
- **THEN** writes SHALL succeed without leaving `.icloud` placeholders behind
- **AND** SHALL not produce duplicated "(conflicted copy)" files in normal operation
