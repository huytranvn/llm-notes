## ADDED Requirements

### Requirement: Provider abstraction
The system SHALL expose a single `LLMProvider` protocol that all provider adapters implement, with a streaming `stream(_:)` method returning `AsyncThrowingStream<ChatEvent, Error>` and a `models()` method listing available models.

#### Scenario: Add a new provider
- **WHEN** a developer adds a new provider adapter conforming to `LLMProvider`
- **THEN** registering it SHALL make it selectable in Settings
- **AND** SHALL not require changes to chat UI or conversation persistence

#### Scenario: ChatEvent variants
- **WHEN** a stream is active
- **THEN** the adapter SHALL emit events of types `delta`, `toolCall`, `toolResult`, and `done(usage)`

### Requirement: Supported providers
The system SHALL ship adapters for OpenAI, Anthropic, Gemini, Ollama, and GitHub Copilot.

#### Scenario: OpenAI streaming
- **WHEN** the user sends a message with an OpenAI provider selected and a valid key
- **THEN** the adapter SHALL stream deltas from `chat/completions` with `stream: true`

#### Scenario: Anthropic streaming
- **WHEN** the user sends a message with an Anthropic provider selected
- **THEN** the adapter SHALL stream `message_delta` events from the Messages API

#### Scenario: Ollama local
- **WHEN** an Ollama base URL is configured
- **THEN** the adapter SHALL stream from the local server with no API key required

### Requirement: BYOK with Keychain
Provider adapters SHALL read API keys from `KeychainService` at request time and SHALL NOT cache keys on disk.

#### Scenario: Missing key
- **WHEN** a provider is selected but no key is stored
- **THEN** the chat UI SHALL prompt the user to add a key in Settings
- **AND** SHALL not attempt the request

### Requirement: Cancellable streams
Each chat turn SHALL run in a dedicated `Task` that the chat view model owns; cancelling the task SHALL terminate the underlying `URLSession` and stop further `ChatEvent` emission.

#### Scenario: User cancels mid-stream
- **WHEN** the user clicks "Stop" while a response is streaming
- **THEN** no further deltas SHALL be appended to the message
- **AND** the HTTP connection SHALL close

#### Scenario: User navigates away
- **WHEN** the user closes the conversation while it is streaming
- **THEN** the streaming task SHALL be cancelled automatically

### Requirement: Conversations stored in vault
Conversations SHALL be persisted as `.md` files under `<vault>/.llm-notes/conversations/`, one file per conversation, so they sync alongside notes.

#### Scenario: Save a conversation
- **WHEN** a chat turn completes
- **THEN** the conversation SHALL be saved to a markdown file with YAML frontmatter holding `id`, `provider`, `model`, and `createdAt`
- **AND** message blocks SHALL be delimited so they can be parsed back

#### Scenario: Reopen on launch
- **WHEN** the app starts and `.llm-notes/conversations/` contains files
- **THEN** they SHALL appear in the conversation list

### Requirement: Note mentions as context
The user SHALL be able to type `@` to mention a note by title; the referenced note's content SHALL be included as context in the next request, subject to a token budget.

#### Scenario: Mention attaches content
- **WHEN** a message contains `@MyNote`
- **THEN** the resolved note's content SHALL be included as a system or user-context block
- **AND** the displayed message SHALL show the mention as a chip

#### Scenario: Token budget exceeded
- **WHEN** included mention content would exceed the model's context window
- **THEN** the chat SHALL truncate the oldest content first
- **AND** SHALL surface a warning to the user
