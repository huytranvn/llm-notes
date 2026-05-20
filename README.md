# llm-notes

Native macOS notes app with WYSIWYG Markdown editor and multi-provider LLM chat. Modeled on [NotePlus](https://noteplus.com/).

## Status

Skeleton + OpenSpec specs only. No feature is implemented yet.

## Where things live

- **Plan:** `plan.md`
- **Project context for AI assistants:** `openspec/project.md`
- **Capability specs (built up via archive):** `openspec/specs/`
- **Active change proposals:** `openspec/changes/`
  - `add-vault-storage` — file-backed vault with stable note IDs and FSEvents
  - `add-markdown-editor` — TextKit-2 WYSIWYG markdown editor
  - `add-settings-keychain` — settings UI + Keychain-backed API keys
  - `add-search-index` — SQLite FTS5 search
  - `add-llm-chat` — multi-provider streaming chat (OpenAI / Anthropic / Gemini / Ollama / Copilot)
  - `add-inline-ai` — selection actions with ghost-overlay accept/reject
  - `add-mcp-tools` — MCP subprocess clients + tool dispatch in the chat loop

## OpenSpec workflow

```sh
openspec list                       # see active changes
openspec show add-vault-storage     # view a change
openspec validate --all --strict    # validate every change + spec
openspec archive add-vault-storage  # after implementation, fold into openspec/specs/
```

## Build

This is a SwiftPM package targeting macOS 14+ with Swift 6.

```sh
swift build
swift test
```

For the full macOS app target, open `Package.swift` in Xcode and add an App target — or generate an `.xcodeproj` once the implementation is fleshed out.

## Dependency order

Implement changes in the order: `add-vault-storage` → `add-markdown-editor` → `add-settings-keychain` → `add-search-index` → `add-llm-chat` → `add-inline-ai` → `add-mcp-tools`.
