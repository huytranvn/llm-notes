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

## Build & run

Requires Xcode (not just CommandLineTools) for SwiftUI/XCTest:

```sh
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer   # one time
```

**Run the app:**
```sh
./scripts/run.sh
```
This builds with `swift build`, wraps the binary in a minimal `.app` bundle under `.build/LLMNotes.app`, and launches it via `open` so macOS treats it as a real foreground app (Dock icon, activated window).

**Or open in Xcode:** `xed Package.swift`, pick the **LLMNotes** scheme, hit ⌘R.

**Tests:**
```sh
swift test
```

## Dependency order

Implement changes in the order: `add-vault-storage` → `add-markdown-editor` → `add-settings-keychain` → `add-search-index` → `add-llm-chat` → `add-inline-ai` → `add-mcp-tools`.
