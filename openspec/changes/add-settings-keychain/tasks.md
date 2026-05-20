## 1. Keychain service

- [ ] 1.1 Implement `KeychainService` actor in `Services/Keychain/KeychainService.swift` using `Security.framework`
- [ ] 1.2 Define stable service identifiers for each provider (e.g. `com.llm-notes.openai`)
- [ ] 1.3 Round-trip unit tests with a per-test access group

## 2. Config stores

- [ ] 2.1 Define `ProviderConfig` and `MCPServerConfig` Codable models in `Core/Models/`
- [ ] 2.2 Implement `ProviderConfigStore` and `MCPServerConfigStore` actors persisting to `config.json`
- [ ] 2.3 Publish changes via `AsyncStream` so consumers update live

## 3. Settings UI

- [ ] 3.1 Add `SettingsScene` to `LLMNotesApp.swift`
- [ ] 3.2 Implement `ProviderSettingsView` (key field uses `SecureField`, never logs the value)
- [ ] 3.3 Implement `MCPServerSettingsView` with add/edit/remove
- [ ] 3.4 Implement `AppearanceSettingsView` (theme, editor font)

## 4. Tests

- [ ] 4.1 KeychainService round-trip + delete
- [ ] 4.2 Config store JSON round-trip
- [ ] 4.3 Subscriber receives update on config change
