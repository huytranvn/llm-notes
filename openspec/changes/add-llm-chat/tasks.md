## 1. Core types

- [ ] 1.1 Define `LLMProvider` protocol in `Services/LLM/LLMProvider.swift`
- [ ] 1.2 Define `ChatRequest`, `ChatMessage`, `ChatEvent`, `LLMModel`, `Usage` in `Services/LLM/`
- [ ] 1.3 Define `Conversation` and `Message` models in `Core/Models/`

## 2. Adapters

- [ ] 2.1 `OpenAIProvider` — `chat/completions` SSE streaming
- [ ] 2.2 `AnthropicProvider` — Messages API streaming
- [ ] 2.3 `GeminiProvider` — `generateContent` streaming
- [ ] 2.4 `OllamaProvider` — local server, no key
- [ ] 2.5 `CopilotProvider` — GitHub Copilot chat endpoint
- [ ] 2.6 Common SSE/line-delimited parser util

## 3. Conversation persistence

- [ ] 3.1 Serialize/deserialize conversation `.md` format with YAML frontmatter + message delimiters
- [ ] 3.2 `ConversationStore` actor reads from `<vault>/.llm-notes/conversations/`
- [ ] 3.3 Auto-save after each turn

## 4. Chat UI

- [ ] 4.1 `ChatPaneView` toggleable from the toolbar
- [ ] 4.2 `ConversationListView` (sidebar inside the chat pane)
- [ ] 4.3 `ConversationView` renders messages with streaming markdown
- [ ] 4.4 Composer with provider/model picker
- [ ] 4.5 Stop button cancels the in-flight `Task`

## 5. Note mentions

- [ ] 5.1 Trigger `@` autocomplete from the composer
- [ ] 5.2 Resolve mentions via `VaultService` and attach content
- [ ] 5.3 Token budget enforcement with oldest-first truncation
- [ ] 5.4 Display mentions as chips in the rendered message

## 6. Tests

- [ ] 6.1 Adapter tests with `URLProtocol` stubs (one per provider)
- [ ] 6.2 Cancellation test: cancelling the `Task` closes the URLSession
- [ ] 6.3 Conversation round-trip: write → read produces identical message list
- [ ] 6.4 Mention resolution + truncation test
