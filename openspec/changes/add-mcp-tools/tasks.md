## 1. MCP client

- [ ] 1.1 Implement `MCPClient` actor in `Services/MCP/MCPClient.swift` using `Process` + Pipes
- [ ] 1.2 JSON-RPC framing (Content-Length headers per MCP spec)
- [ ] 1.3 `initialize` handshake, capability negotiation
- [ ] 1.4 `tools/list`, `tools/call` request helpers
- [ ] 1.5 Graceful shutdown on app termination

## 2. Server registry

- [ ] 2.1 `MCPServerRegistry` actor reads `MCPServerConfigStore`
- [ ] 2.2 Lifecycle: spawn, monitor, restart, terminate
- [ ] 2.3 Surface client status (`running`, `failed`, `stopped`) to Settings UI

## 3. Tool registry + built-ins

- [ ] 3.1 `ToolRegistry` aggregates MCP tools + built-ins
- [ ] 3.2 Built-in `vault.read`, `vault.write`, `vault.search` bound to `VaultService` + `SearchIndex`
- [ ] 3.3 Namespaced identifiers to avoid name collisions

## 4. Chat loop integration

- [ ] 4.1 Extend `ChatRequest` to carry available tools
- [ ] 4.2 Update each provider adapter to forward tool definitions and surface `.toolCall`
- [ ] 4.3 Chat view model dispatches `.toolCall` to registry; loops until `.done`
- [ ] 4.4 Tool-call cancellation propagates through `Task` cancellation

## 5. Sandbox / distribution

- [ ] 5.1 Confirm app target has App Sandbox disabled
- [ ] 5.2 Document distribution signing + notarization without sandbox

## 6. Tests

- [ ] 6.1 `MCPClient` end-to-end against `@modelcontextprotocol/server-filesystem`
- [ ] 6.2 Tool name collision handling
- [ ] 6.3 Tool failure returned as result, conversation continues
- [ ] 6.4 Cancellation mid-tool aborts cleanly
