# Project: llm-notes

A native macOS app that combines a WYSIWYG Markdown editor with a multi-provider LLM chat panel, inline AI actions on selected text, and MCP tool-use. Modeled on [NotePlus](https://noteplus.com/). Personal project.

## Stack

- **Language:** Swift 6
- **UI:** SwiftUI + AppKit (`NSViewRepresentable` for the editor)
- **Text engine:** TextKit 2
- **Storage:** Plain `.md` files in a user-chosen vault folder. SQLite (GRDB + FTS5) as a disposable search cache.
- **Dependencies (SPM):** `apple/swift-markdown`, `groue/GRDB.swift`, `JohnSundell/Splash` (or `raspu/Highlightr`). No HTTP library — `URLSession` directly.
- **Platform:** macOS 14+, universal binary, notarized direct distribution (no App Sandbox in v1 so MCP subprocesses can spawn).

## Architecture

Layered with one-way dependencies UI → Services → Core. Each capability maps to an OpenSpec spec under `openspec/specs/<capability>/spec.md`.

```
App/              SwiftUI entry, scenes, commands, menus
Features/
  Editor/         WYSIWYG markdown editor
  VaultBrowser/   Sidebar tree + search
  Chat/           LLM chat panel
  InlineAI/       Selection actions
  Settings/       Keys, providers, MCP servers
Services/
  Vault/          File I/O, NSFileCoordinator, FSEvents watcher
  Search/         SQLite FTS5 index
  LLM/            Provider protocol + adapters
  MCP/            MCP client + tool registry
  Keychain/       Secure key storage
Core/
  Models/         Note, Folder, Conversation, Message
  Markdown/       Parser + AST
```

UI features depend on Services only through protocols. New LLM provider = one adapter file. New MCP server = config entry. New editor command = one file under `Features/Editor/Commands/`.

## Capabilities

- `vault` — root folder selection, file I/O, FSEvents watcher, stable note IDs.
- `editor` — TextKit-2 markdown WYSIWYG, incremental AST styling, debounced atomic save.
- `search` — SQLite FTS5 index built from vault events.
- `llm-chat` — multi-provider chat with streaming, BYOK, conversations persisted as `.md`.
- `inline-ai` — selection menu + ghost-overlay accept/reject for AI rewrites.
- `mcp` — JSON-RPC subprocess clients + tool registry merging MCP and built-in tools.
- `settings` — provider/MCP config UI; API keys stored in the Apple Keychain.

## Conventions

- All file/socket access goes through `actor` services (`VaultService`, `MCPClient`, `SearchIndex`).
- UI uses `@Observable` view models.
- One cancellable `Task` per LLM streaming turn, stored on the conversation view model.
- Notes carry a UUID in YAML frontmatter as a stable identifier so renames don't break links/conversations.
- All vault writes use `NSFileCoordinator` for iCloud/Dropbox safety.
- Background work (indexing, embeddings) uses `TaskPriority.background`.

## Non-goals (v1)

- App Sandbox / Mac App Store distribution.
- Embeddings / semantic search.
- iOS or iPadOS target (Core/Services kept platform-agnostic for future reuse).
