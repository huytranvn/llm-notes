## Why

The LLM chat panel is the second pillar of the app alongside the editor. Users bring their own keys for OpenAI, Anthropic, Gemini, Ollama, and GitHub Copilot. Architecturally we need a single provider abstraction so adding a new provider is one file and so streaming/cancellation/tool-use work the same everywhere. Conversations live in the vault as `.md` files so they sync with the rest of the user's notes.

## What Changes

- Define `LLMProvider` protocol returning `AsyncThrowingStream<ChatEvent, Error>` from `stream(_:)`.
- Implement adapters: `OpenAIProvider`, `AnthropicProvider`, `GeminiProvider`, `OllamaProvider`, `CopilotProvider`.
- Stream via `URLSession.bytes(for:)`; one cancellable `Task` per chat turn.
- Persist conversations as `.md` files in `<vault>/.llm-notes/conversations/`.
- Add the chat pane UI to the right side of the main window, toggleable.
- Support `@note-title` mentions that attach note content as context with token-budget enforcement.

## Capabilities

### New Capabilities
- `llm-chat`: multi-provider streaming chat with BYOK; conversations stored in the vault.

### Modified Capabilities
- `vault`: reserves `.llm-notes/conversations/` for chat storage; no spec change.
- `settings`: provider config and keys are consumed read-only.

## Impact

- New `Features/Chat/` module.
- New `Services/LLM/` module with 5 adapters + protocol.
- New on-disk path: `<vault>/.llm-notes/conversations/*.md`.
- No new SPM dependencies (URLSession only).
