## Why

The chat panel handles long-form back-and-forth, but the most valuable editor interaction is "select text → ask AI → replace inline." This needs to be fast, keyboard-driven, and reversible. Defining inline AI as data-driven prompts (not hardcoded) lets the user add their own actions without code changes.

## What Changes

- Add a selection action menu and `⌘⇧A` shortcut in `NSTextView`.
- Provide built-in prompts: Rewrite, Summarize, Continue, Translate, Explain. Each is a `PromptTemplate` (Codable) so users can add/edit/delete in Settings.
- Stream the AI output into a ghost overlay over the selection; `↵` accepts (replaces selection), `⎋` rejects.
- Use the same `LLMProvider` plumbing as chat; share the cancellable-Task pattern.

## Capabilities

### New Capabilities
- `inline-ai`: selection-driven AI actions inside the editor with ghost-overlay accept/reject.

### Modified Capabilities
- `llm-chat`: no spec change — reuses the existing provider abstraction.

## Impact

- New `Features/InlineAI/` module.
- New config file segment in `config.json` for user-defined prompt templates.
- New menu / keybinding entries.
