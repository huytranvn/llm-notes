## Why

LLM chat and MCP both depend on user-supplied API keys and server configurations. We need a settings surface and a secure place to store secrets before either capability can ship. Keys must live in the Apple Keychain (not `UserDefaults` or plaintext config) for security and to follow the NotePlus model.

## What Changes

- Add a `SettingsScene` (SwiftUI `Settings { … }`) with tabs for Providers, MCP Servers, and Appearance.
- Introduce `KeychainService` (actor) with `set(key:value:)`, `get(key:)`, `delete(key:)` over the Apple Keychain.
- Persist non-secret config (selected provider, model preferences, MCP server commands/args, theme) in `~/Library/Application Support/llm-notes/config.json`.
- Provide a `ProviderConfigStore` and `MCPServerConfigStore` that other capabilities read from.

## Capabilities

### New Capabilities
- `settings`: user-facing settings UI and secure storage of API keys + provider/MCP config.

### Modified Capabilities
<!-- none -->

## Impact

- New `Features/Settings/` module.
- New `Services/Keychain/` module.
- New on-disk file: `~/Library/Application Support/llm-notes/config.json`.
- No additional SPM dependencies (uses `Security.framework`).
