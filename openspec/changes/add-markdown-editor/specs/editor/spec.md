## ADDED Requirements

### Requirement: Markdown buffer with rendered styling
The editor SHALL store plain markdown in its underlying text buffer, and SHALL render that markdown with visible styling (heading sizes, bold, italic, lists, links, inline code, code blocks, blockquotes, checklists).

#### Scenario: Heading is styled
- **WHEN** the buffer contains `# Title`
- **THEN** the rendered text SHALL appear in a heading-sized font
- **AND** the underlying buffer SHALL still equal `# Title`

#### Scenario: Saved file is plain markdown
- **WHEN** the editor saves a note
- **THEN** the on-disk file SHALL be plain markdown with no proprietary encoding

### Requirement: Incremental reparse
The editor SHALL reparse only the affected paragraph(s) on edit, not the whole document, so typing latency stays under 16 ms even in files with 10,000+ lines.

#### Scenario: Edit in a large file
- **WHEN** the user types into a 10,000-line file
- **THEN** keystroke-to-paint latency SHALL be under 16 ms on Apple Silicon
- **AND** the rest of the document SHALL not be restyled

### Requirement: Code fence syntax highlighting
Fenced code blocks SHALL be syntax-highlighted using their declared language tag.

#### Scenario: Swift fence
- **WHEN** the buffer contains a fence tagged `swift`
- **THEN** Swift keywords, strings, and types SHALL be colored
- **AND** unknown languages SHALL fall back to monospace plain styling

### Requirement: Debounced atomic save
The editor SHALL persist changes to the vault through `VaultService` no more than ~500 ms after the last edit, using atomic writes via `NSFileCoordinator`.

#### Scenario: Rapid typing
- **WHEN** the user is typing continuously
- **THEN** the editor SHALL not write to disk on every keystroke
- **AND** SHALL flush at most ~500 ms after typing stops

#### Scenario: Switching notes mid-edit
- **WHEN** the user navigates to another note before the debounce fires
- **THEN** the editor SHALL flush the current note's pending changes before opening the next

### Requirement: External edit reconciliation
When the vault emits a `modified` event for the currently open note, the editor SHALL reload the buffer without losing the user's caret position when possible, and SHALL not overwrite the external change.

#### Scenario: External app edits the open file
- **WHEN** another app modifies the file currently open in the editor
- **THEN** the editor SHALL reload from disk
- **AND** SHALL show a non-blocking indicator that the file changed externally

#### Scenario: Concurrent local + external edit
- **WHEN** the user has unsaved local changes and an external modification arrives
- **THEN** the editor SHALL prompt the user to keep local or accept external content

### Requirement: Inline content rendering
The editor SHALL render images (inline thumbnails for local image links), clickable links, and GFM tables.

#### Scenario: Local image link
- **WHEN** the buffer contains `![alt](./image.png)` referencing an existing file
- **THEN** the editor SHALL render the image inline at a reasonable max size

#### Scenario: External link click
- **WHEN** the user `⌘`-clicks a `http(s)://` link
- **THEN** the editor SHALL open it in the default browser
