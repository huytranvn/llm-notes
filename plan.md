# Plan: Scalable macOS Note + LLM App (NotePlus-like)

## Context

`/Users/huytran/workspace/personal/llm-notes` is empty. Goal: a native macOS app combining a WYSIWYG Markdown editor with multi-provider LLM chat, inline AI actions, and MCP tool-use — modeled on https://noteplus.com/.

User decisions:
- **Stack:** SwiftUI + AppKit (native Swift, small binary).
- **MVP features:** WYSIWYG Markdown editor, multi-provider LLM chat (BYOK), inline AI actions on selection, MCP / tool-use support.
- **Storage:** plain `.md` files in a user-chosen vault folder.
- **Documentation:** every feature documented via **OpenSpec** (`openspec` CLI, already installed) — change proposals + capability specs, not ad-hoc markdown.

"Scalable" here means: vaults of 10k+ notes without UI jank, many concurrent LLM streams without blocking the editor, and an architecture where new providers / MCP servers / editor features drop in without touching the core.

## OpenSpec Layout (source of truth for features)

Initialize OpenSpec at the repo root, then create one change proposal per capability. Each change carries its own `specs/<capability>/spec.md` delta; once implemented, `openspec archive` promotes it into the stable `openspec/specs/` tree.

```
llm-notes/
├── openspec/
│   ├── project.md                       # project context for AI assistants
│   ├── specs/                           # stable specs (populated via archive)
│   │   ├── vault/spec.md
│   │   ├── editor/spec.md
│   │   ├── search/spec.md
│   │   ├── llm-chat/spec.md
│   │   ├── inline-ai/spec.md
│   │   ├── mcp/spec.md
│   │   └── settings/spec.md
│   └── changes/                         # active proposals
│       ├── add-vault-storage/
│       ├── add-markdown-editor/
│       ├── add-search-index/
│       ├── add-llm-chat/
│       ├── add-inline-ai/
│       ├── add-mcp-tools/
│       └── add-settings-keychain/
```

Each change directory follows OpenSpec convention:
- `proposal.md` — why, what, scope, non-goals.
- `tasks.md` — checklist of work items.
- `specs/<capability>/spec.md` — capability requirements/scenarios.
- `design.md` (optional) — architecture notes.

Validate with `openspec validate <change-name>` before marking done.

## High-Level Architecture

Layered, one-way deps (UI → Services → Core). Each layer maps to OpenSpec capabilities.

```
App/                  SwiftUI entry, scenes, commands, menus
Features/
  Editor/             WYSIWYG markdown editor (NSTextView via NSViewRepresentable)
  VaultBrowser/       Sidebar: folder tree, search, recents
  Chat/               LLM chat panel, conversation list
  InlineAI/           Selection actions (rewrite/summarize/continue)
  Settings/           Keys, providers, MCP servers, appearance
Services/
  Vault/              File I/O, NSFileCoordinator, FSEvents watcher
  Search/             SQLite FTS5 index (cache only; files are truth)
  LLM/                Provider protocol + OpenAI/Anthropic/Gemini/Ollama adapters
  MCP/                MCP client, server registry, tool routing
  Keychain/           Secure key storage
Core/
  Models/             Note, Folder, Conversation, Message, Tool, Provider
  Markdown/           Parser (swift-markdown) + AST
  Concurrency/        Actors, AsyncStream helpers
```

UI features depend on Services through protocols. New LLM provider = one file in `Services/LLM/`. New MCP server = config entry. New editor command = one file in `Features/Editor/Commands/`.

## Capabilities (one OpenSpec change per row)

| Capability | Change name | Summary |
|---|---|---|
| Vault storage | `add-vault-storage` | Pick a root folder via security-scoped bookmark; async `VaultService` actor; FSEvents watcher emits diffs; notes carry a UUID in YAML frontmatter. |
| Markdown editor | `add-markdown-editor` | `NSTextView` (TextKit 2) wrapped in SwiftUI; `swift-markdown` AST drives attributed styling; incremental reparse per paragraph; debounced atomic save through `NSFileCoordinator`. |
| Search index | `add-search-index` | GRDB + FTS5 `(note_id, title, body)`; background indexer subscribes to vault diffs; full reindex on first launch; index is disposable cache. |
| LLM chat | `add-llm-chat` | `LLMProvider` protocol with adapters for OpenAI / Anthropic / Gemini / Ollama / Copilot; `URLSession.bytes` streaming; one cancellable `Task` per turn; conversations persisted as `.md` under `<vault>/.llm-notes/conversations/`. |
| Inline AI | `add-inline-ai` | Selection menu + `⌘⇧A`; pre-built prompts (Rewrite/Summarize/Continue/Translate/Explain) defined as data so users can add their own; ghost-overlay accept (`↵`) / reject (`⎋`). |
| MCP tool-use | `add-mcp-tools` | `MCPClient` actor speaks JSON-RPC over stdio to spawned servers; `ToolRegistry` merges MCP tools with built-ins (read/write/search vault); chat loop dispatches `.toolCall` → `.toolResult` until `.done`. |
| Settings + Keychain | `add-settings-keychain` | API keys stored via `KeychainService` (Apple Keychain); provider/MCP-server config in `~/Library/Application Support/llm-notes/`. |

Dependency order for implementation: `add-vault-storage` → `add-markdown-editor` → `add-settings-keychain` → `add-search-index` → `add-llm-chat` → `add-inline-ai` → `add-mcp-tools`.

## Key Design Notes

### Editor
- TextKit 2 `NSTextContentStorage` holds raw markdown; custom `NSTextLayoutManager` applies attributes from the AST so text renders "as styled" but the buffer remains `.md`.
- Parser: `swift-markdown`; incremental reparse on edit using paragraph-range diffs (not full reparse).
- Code fences highlighted by `Splash` (Swift) or `Highlightr` (multi-language).

### Vault & file model
- Security-scoped bookmark persisted to `UserDefaults`.
- Notes identified by a stable UUID in YAML frontmatter so renames don't break links/conversations.
- All writes through `NSFileCoordinator` for safe iCloud/Dropbox sync.

### LLM provider abstraction
```swift
protocol LLMProvider: Sendable {
    var id: String { get }
    func models() async throws -> [LLMModel]
    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error>
}
// ChatEvent = .delta(String) | .toolCall(ToolCall) | .toolResult(...) | .done(Usage)
```
- One `Task` per turn, stored on the conversation view model; navigating away cancels cleanly.

### MCP
- Subprocess per server, JSON-RPC over stdio (per spec).
- Sandbox: v1 ships **without App Sandbox** (direct-distribution, notarized) to allow subprocess spawning. Mac App Store would need an XPC helper — deferred.

### Concurrency
- `VaultService`, `MCPClient`, `SearchIndex` are actors.
- UI uses `@Observable` view models reading async from services.
- Indexing / background work runs at `TaskPriority.background`.

## Critical Files

```
llm-notes/
├── openspec/                              # see layout above
├── llm-notes.xcodeproj                    # Xcode project (SPM deps inside)
├── App/
│   ├── LLMNotesApp.swift                  # @main, scene, commands
│   └── AppCommands.swift
├── Features/
│   ├── Editor/{EditorView,MarkdownTextView,MarkdownStyler,EditorViewModel}.swift
│   ├── VaultBrowser/{SidebarView,VaultTreeViewModel}.swift
│   ├── Chat/{ChatPaneView,ConversationView,ChatViewModel}.swift
│   ├── InlineAI/{InlineActionMenu,InlineActionRunner}.swift
│   └── Settings/{SettingsView,ProviderSettingsView}.swift
├── Services/
│   ├── Vault/{VaultService,FileWatcher,Bookmarks}.swift
│   ├── Search/{SearchIndex,Indexer}.swift
│   ├── LLM/{LLMProvider,OpenAIProvider,AnthropicProvider,GeminiProvider,
│   │        OllamaProvider,CopilotProvider,ChatRequest,ChatEvent}.swift
│   ├── MCP/{MCPClient,MCPServerRegistry,ToolRegistry}.swift
│   └── Keychain/KeychainService.swift
├── Core/
│   ├── Models/{Note,Folder,Conversation,Message}.swift
│   └── Markdown/{MarkdownParser,MarkdownNode}.swift
└── Tests/
    ├── VaultServiceTests.swift
    ├── MarkdownStylerTests.swift
    ├── ProviderTests.swift                # URLProtocol mocks
    └── SearchIndexTests.swift
```

## Dependencies (SPM)

- `apple/swift-markdown` — Markdown AST.
- `groue/GRDB.swift` — SQLite + FTS5.
- `JohnSundell/Splash` (or `raspu/Highlightr`) — code-fence highlighting.
- No HTTP library — use `URLSession` directly.

## Bootstrap Steps (no calendar, just order)

1. `git init`, create `llm-notes.xcodeproj` (macOS App, SwiftUI lifecycle, Swift 6).
2. Run `openspec init` at repo root; write `openspec/project.md` with the architecture summary above.
3. For each capability in the table, run `openspec new change add-<capability>` and fill in `proposal.md`, `tasks.md`, `specs/<capability>/spec.md`. Validate with `openspec validate`.
4. Implement capabilities in the dependency order listed above. After each capability is shipped + verified, `openspec archive add-<capability>` to fold its delta into `openspec/specs/`.

## Verification

Per-capability tests live in each change's `tasks.md`. Whole-app smoke checks:

- **Editor:** open a 10k-line markdown file; typing latency < 16 ms; switching files < 100 ms.
- **Vault scale:** generate 10,000 dummy `.md` files; sidebar scroll smooth; FTS query for a unique token returns in < 50 ms.
- **External edits:** edit a note in another editor; UI updates within 1 s with no data loss.
- **LLM:** stream a long Anthropic response; cancel mid-stream; confirm the URLSession task closes and no further deltas arrive.
- **MCP:** wire `@modelcontextprotocol/server-filesystem`; ask chat to read a note; verify tool-call round-trip.
- **Sync:** put vault in iCloud Drive; edit on a second Mac; confirm no `.icloud` placeholder breakage and no double-writes.
- **Unit tests:** `swift test` (or Xcode test action) green; provider adapters tested via `URLProtocol` stubs; styler tested against fixture AST → attribute runs.
- **OpenSpec health:** `openspec validate --strict` passes for every active change.

## Open Questions / Deferred

- **App Sandbox / Mac App Store:** v1 = notarized direct download (no sandbox) for MCP subprocess support. Sandboxed App Store build would need an XPC helper or drop MCP — deferred.
- **Embeddings / semantic search:** out of scope; `SearchIndex` can grow a `vectors` table later.
- **iOS/iPad target:** out of scope; `Core/` and `Services/` are platform-agnostic so a future iOS app could reuse them.
