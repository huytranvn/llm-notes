## 1. Prompt templates

- [ ] 1.1 Define `PromptTemplate` (id, name, systemPrompt, userTemplate) Codable in `Core/Models/PromptTemplate.swift`
- [ ] 1.2 Ship 5 built-in templates as a static bundle resource
- [ ] 1.3 Persist user templates in `config.json` under `inlineAI.templates`
- [ ] 1.4 Settings UI: list/add/edit/remove

## 2. Trigger UI

- [ ] 2.1 Add `⌘⇧A` keybinding to `MarkdownTextView`
- [ ] 2.2 Context menu "AI Actions" submenu
- [ ] 2.3 Edit menu entries
- [ ] 2.4 Picker popover anchored to the selection rect

## 3. Ghost overlay

- [ ] 3.1 Implement overlay as an `NSView` positioned over the selection range
- [ ] 3.2 Stream deltas into the overlay's `NSAttributedString`
- [ ] 3.3 `↵` to accept → single-undo replacement; `⎋` to reject

## 4. Runner

- [ ] 4.1 `InlineActionRunner` builds a `ChatRequest` from selection + template
- [ ] 4.2 Owns the streaming `Task`; cancels on reject / navigation
- [ ] 4.3 Resolves default provider/model from `ProviderConfigStore`
- [ ] 4.4 One-shot model override option in the picker

## 5. Tests

- [ ] 5.1 Template parse/render with a fixture selection
- [ ] 5.2 Accept performs single-undo replacement
- [ ] 5.3 Reject leaves buffer untouched
- [ ] 5.4 Cancellation closes the URLSession
