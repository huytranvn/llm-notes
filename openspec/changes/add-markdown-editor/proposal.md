## Why

The editor is the app's primary surface. We need WYSIWYG-style markdown — the user sees styled headings, lists, code, links — but the underlying buffer remains plain `.md` for portability. SwiftUI's `TextEditor` can't do this; we need TextKit 2 on an `NSTextView` with AST-driven styling. Building this once, well, removes the temptation to fall back to plain text later.

## What Changes

- Wrap `NSTextView` (TextKit 2) inside a SwiftUI `NSViewRepresentable` (`EditorView`).
- Parse the buffer with `swift-markdown` and apply styling via a custom `MarkdownStyler` over `NSAttributedString` attribute runs.
- Reparse incrementally on edit — paragraph-range diffing, not full reparse — so 10k-line files stay responsive.
- Wire the editor to `VaultService`: open a note by ID, debounce writes (~500 ms), reload on external `modified` events.
- Render code fences with syntax highlighting via `Splash` (Swift) or `Highlightr` (multi-language).

## Capabilities

### New Capabilities
- `editor`: WYSIWYG markdown editor backed by TextKit 2 with incremental AST styling.

### Modified Capabilities
- `vault`: editor consumes the existing async API; no spec change.

## Impact

- New `Features/Editor/` module.
- New SPM dependencies: `apple/swift-markdown`, code-highlighter (`Splash` or `Highlightr`).
- No changes to vault storage on disk.
