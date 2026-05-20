## Why

Linear-scan search across a 10k-note vault is unacceptably slow. We need a SQLite FTS5 index built from vault events so queries return in under 50 ms. The index is a disposable cache — files remain the source of truth — so it can be deleted and rebuilt at any time without data loss.

## What Changes

- Add a SQLite database (via GRDB) at `~/Library/Application Support/llm-notes/search.sqlite` with an FTS5 virtual table over `(note_id, title, body)`.
- Introduce a `SearchIndex` actor with `query(_:)` (returns ranked matches) and `rebuild()`.
- Add a background `Indexer` that subscribes to `VaultService.watch()` and incrementally updates the index.
- Sidebar gets a search box that calls `SearchIndex.query(_:)`.

## Capabilities

### New Capabilities
- `search`: full-text search over note titles and bodies, indexed in SQLite FTS5.

### Modified Capabilities
<!-- none — uses vault events read-only -->

## Impact

- New SPM dependency: `groue/GRDB.swift`.
- New on-disk file: `search.sqlite` (regenerable; not part of vault).
- New `Services/Search/` module and a search box in `Features/VaultBrowser/`.
