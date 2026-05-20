## ADDED Requirements

### Requirement: Secure API key storage
The system SHALL store user-supplied API keys in the Apple Keychain via `KeychainService`, and SHALL NOT persist keys to `UserDefaults`, plaintext config files, or logs.

#### Scenario: Save a provider key
- **WHEN** the user enters an API key in Provider Settings and clicks Save
- **THEN** the key SHALL be written to the Keychain under a stable service identifier
- **AND** no plaintext copy SHALL be written to disk

#### Scenario: Read a provider key
- **WHEN** an LLM adapter requests a key for a provider
- **THEN** `KeychainService` SHALL return the stored value
- **AND** the key SHALL not be cached unencrypted on disk

#### Scenario: Delete a provider key
- **WHEN** the user clears a provider key in Settings
- **THEN** the corresponding Keychain item SHALL be removed

### Requirement: Settings UI
The app SHALL present a Settings scene with tabs for Providers, MCP Servers, and Appearance, reachable via `⌘,` and the standard app menu.

#### Scenario: Open Settings
- **WHEN** the user presses `⌘,`
- **THEN** the Settings window SHALL open with the last-used tab focused

#### Scenario: Provider tab
- **WHEN** the user opens the Providers tab
- **THEN** the app SHALL list every supported provider (OpenAI, Anthropic, Gemini, Ollama, Copilot)
- **AND** for each provider SHALL show key entry, default model selection, and an "active" toggle

#### Scenario: MCP Servers tab
- **WHEN** the user opens the MCP Servers tab
- **THEN** the app SHALL allow adding, editing, and removing server entries
- **AND** each entry SHALL capture name, command, args, and env vars

### Requirement: Provider and MCP configuration persistence
Non-secret configuration SHALL be persisted to `~/Library/Application Support/llm-notes/config.json` and made available to other capabilities through async stores.

#### Scenario: Read provider config
- **WHEN** an LLM adapter starts
- **THEN** it SHALL read provider config from `ProviderConfigStore`
- **AND** the store SHALL return the latest persisted values

#### Scenario: Live updates
- **WHEN** the user changes config in Settings
- **THEN** subscribers to the stores SHALL receive the updated config without restarting the app
