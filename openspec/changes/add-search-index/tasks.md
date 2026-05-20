## 1. Database

- [ ] 1.1 Add `GRDB.swift` SPM dependency
- [ ] 1.2 Open `search.sqlite` in `~/Library/Application Support/llm-notes/`
- [ ] 1.3 Define FTS5 virtual table `notes_fts(note_id UNINDEXED, title, body)`
- [ ] 1.4 Migration runner for schema changes

## 2. SearchIndex actor

- [ ] 2.1 Implement `SearchIndex` actor in `Services/Search/SearchIndex.swift`
- [ ] 2.2 `query(_:limit:)` returns `[SearchResult]` ranked by BM25
- [ ] 2.3 `upsert(note:)`, `delete(noteID:)`, `rebuild()`

## 3. Indexer

- [ ] 3.1 Implement `Indexer` in `Services/Search/Indexer.swift`
- [ ] 3.2 Subscribe to `VaultService.watch()`; map events to index ops
- [ ] 3.3 First-launch full scan at `TaskPriority.background`

## 4. UI

- [ ] 4.1 Add search box at the top of `SidebarView`
- [ ] 4.2 Debounce input ~150 ms; cancel in-flight queries on new input
- [ ] 4.3 Result list highlights matched tokens

## 5. Tests

- [ ] 5.1 Single-token query < 50 ms over 10k synthetic notes
- [ ] 5.2 Incremental update: modify a note, query returns updated content
- [ ] 5.3 Rebuild produces same results as incremental
