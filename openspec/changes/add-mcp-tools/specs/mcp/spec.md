## ADDED Requirements

### Requirement: MCP client over stdio
The system SHALL spawn each configured MCP server as a subprocess and communicate with it using JSON-RPC over stdio per the Model Context Protocol specification.

#### Scenario: Start a configured server
- **WHEN** the app launches with an enabled MCP server in `config.json`
- **THEN** `MCPServerRegistry` SHALL spawn the configured command with its args and env
- **AND** SHALL perform the MCP `initialize` handshake

#### Scenario: Server crashes
- **WHEN** a spawned MCP server exits unexpectedly
- **THEN** the registry SHALL mark the client unavailable
- **AND** SHALL surface the error in Settings
- **AND** SHALL NOT crash the app

#### Scenario: Server restart
- **WHEN** the user toggles a server off and back on in Settings
- **THEN** the registry SHALL terminate the existing subprocess
- **AND** SHALL spawn a fresh one

### Requirement: Tool aggregation
A single `ToolRegistry` SHALL aggregate tools from all live MCP clients and from the built-in set (`vault.read`, `vault.write`, `vault.search`). The chat layer SHALL see one flat list.

#### Scenario: List tools
- **WHEN** a chat turn starts
- **THEN** the registry SHALL return the union of MCP tools and built-in tools
- **AND** each tool SHALL carry a stable namespaced identifier (e.g. `fs.readFile`, `vault.read`)

#### Scenario: Name collision
- **WHEN** two servers expose tools with the same short name
- **THEN** the registry SHALL keep them distinguishable via the server-prefixed identifier
- **AND** SHALL NOT silently drop either

### Requirement: Built-in vault tools
The system SHALL expose `vault.read(noteID|path)`, `vault.write(noteID|path, content)`, and `vault.search(query)` as built-in tools available to every chat turn.

#### Scenario: Read a note via tool
- **WHEN** the model issues a `vault.read` tool call with a note ID
- **THEN** the registry SHALL invoke `VaultService.read(noteID:)`
- **AND** SHALL return the markdown content as the tool result

#### Scenario: Write requires user-visible action
- **WHEN** the model issues `vault.write`
- **THEN** the result SHALL update the file via `VaultService.write`
- **AND** the change SHALL appear in the editor like any other vault modification

### Requirement: Chat-loop tool dispatch
When a provider emits a `.toolCall` event, the chat layer SHALL route the call to the `ToolRegistry`, await the result, send the result back to the provider as a tool message, and continue the stream until the provider emits `.done`.

#### Scenario: Single tool round-trip
- **WHEN** a provider emits `.toolCall(id, name, args)`
- **THEN** the chat layer SHALL invoke the registered handler
- **AND** SHALL send `.toolResult(id, result)` back into the same conversation
- **AND** SHALL continue streaming further deltas

#### Scenario: Tool failure
- **WHEN** a tool invocation throws
- **THEN** the chat layer SHALL send the error as the tool result
- **AND** SHALL NOT terminate the conversation

#### Scenario: Cancellation mid-tool
- **WHEN** the user cancels the chat turn while a tool is running
- **THEN** the tool task SHALL be cancelled
- **AND** no further `.toolResult` or `.delta` events SHALL be sent

## MODIFIED Requirements

### Requirement: Provider abstraction
The system SHALL expose a single `LLMProvider` protocol that all provider adapters implement, with a streaming `stream(_:)` method returning `AsyncThrowingStream<ChatEvent, Error>` and a `models()` method listing available models. Adapters SHALL surface tool-call events from the underlying API as `.toolCall` `ChatEvent`s, and SHALL accept tool results delivered back via the next `ChatRequest`'s message list.

#### Scenario: Add a new provider
- **WHEN** a developer adds a new provider adapter conforming to `LLMProvider`
- **THEN** registering it SHALL make it selectable in Settings
- **AND** SHALL not require changes to chat UI or conversation persistence

#### Scenario: ChatEvent variants
- **WHEN** a stream is active
- **THEN** the adapter SHALL emit events of types `delta`, `toolCall`, `toolResult`, and `done(usage)`

#### Scenario: Provider supports tool calls
- **WHEN** a provider that supports tool use receives a `ChatRequest` with available tools
- **THEN** the adapter SHALL forward the tool definitions to the underlying API
- **AND** SHALL surface model-issued tool invocations as `.toolCall` events

#### Scenario: Provider without tool support
- **WHEN** a provider that does not support tool use receives a `ChatRequest` with tools
- **THEN** the adapter SHALL omit tools from the underlying request
- **AND** the chat layer SHALL not expect `.toolCall` events from that turn
