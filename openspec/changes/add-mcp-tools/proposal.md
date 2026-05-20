## Why

The Model Context Protocol (MCP) lets the chat call external tools and read external context (filesystem, databases, web APIs) through a standard JSON-RPC interface. Adding it makes the app extensible by users — they configure third-party MCP servers without us writing code. We also expose built-in tools (read note, write note, search vault) through the same registry so the chat can act on the user's own data.

## What Changes

- Add `MCPClient` actor that spawns an MCP server subprocess and speaks JSON-RPC over stdio.
- Add `MCPServerRegistry` that reads server configs from `MCPServerConfigStore` and manages client lifecycles.
- Add `ToolRegistry` that aggregates tools from all live MCP clients plus built-in vault tools (`vault.read`, `vault.write`, `vault.search`).
- Extend the chat loop: when a provider emits `.toolCall`, dispatch to the registry, stream the `.toolResult` back into the provider, and continue until `.done`.
- v1 ships **without App Sandbox** (notarized direct distribution) to allow subprocess spawning.

## Capabilities

### New Capabilities
- `mcp`: subprocess-based MCP clients, tool aggregation, and chat-loop tool dispatch.

### Modified Capabilities
- `llm-chat`: the chat loop SHALL handle `.toolCall` / `.toolResult` round-trips. Adds the requirement that adapters surface tool-call events; existing streaming behavior is unchanged otherwise.

## Impact

- New `Services/MCP/` module.
- v1 distribution SHALL NOT enable App Sandbox (Mac App Store deferred).
- Built-in tools added: `vault.read`, `vault.write`, `vault.search`.
- No additional SPM dependencies.
