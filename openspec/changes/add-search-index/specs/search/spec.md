## ADDED Requirements

### Requirement: Full-text search
The system SHALL provide full-text search over note titles and bodies using SQLite FTS5, and SHALL return ranked results within 50 ms for vaults of up to 10,000 notes on Apple Silicon.

#### Scenario: Single-token query
- **WHEN** the user types a unique token in the search box
- **THEN** results SHALL appear within 50 ms
- **AND** SHALL be ranked by FTS5 BM25 relevance

#### Scenario: Multi-token query
- **WHEN** the user types multiple tokens
- **THEN** results SHALL match notes containing all tokens (implicit AND)

#### Scenario: No matches
- **WHEN** no note matches the query
- **THEN** the search box SHALL render an empty-results state

### Requirement: Files-are-truth
The search index SHALL be a disposable cache; deleting `search.sqlite` SHALL not lose user data, and the index SHALL be rebuildable from the vault.

#### Scenario: Missing index on launch
- **WHEN** `search.sqlite` does not exist on launch
- **THEN** the indexer SHALL perform a full scan of the vault and build the index
- **AND** SHALL not block the UI during the build

#### Scenario: Manual rebuild
- **WHEN** the user invokes a "Rebuild Index" command
- **THEN** the system SHALL drop and recreate the FTS5 table
- **AND** SHALL re-index every note

### Requirement: Incremental updates
The indexer SHALL subscribe to vault change events and update the FTS5 table incrementally — adding rows on `created`, replacing on `modified`, deleting on `deleted`, updating note IDs on `renamed`.

#### Scenario: Note modified externally
- **WHEN** an external app modifies a note
- **THEN** the index SHALL reflect the new content within 2 seconds of the FSEvent

#### Scenario: Note deleted
- **WHEN** a note is removed from the vault
- **THEN** the index SHALL no longer return it from queries

### Requirement: Background indexing
Indexing work SHALL run at `TaskPriority.background` so the editor and chat remain responsive during bulk reindex.

#### Scenario: First-launch full scan
- **WHEN** a full scan of 10,000 notes is running
- **THEN** the editor's typing latency SHALL remain under 16 ms
- **AND** the UI SHALL not stutter
