## 1. Editor view

- [ ] 1.1 Add `EditorView: NSViewRepresentable` wrapping `MarkdownTextView` in `Features/Editor/EditorView.swift`
- [ ] 1.2 Subclass `NSTextView` as `MarkdownTextView` configured for TextKit 2
- [ ] 1.3 Wire `EditorViewModel` to load/save through `VaultService`

## 2. Markdown styling

- [ ] 2.1 Add `swift-markdown` SPM dependency
- [ ] 2.2 Implement `MarkdownParser` wrapping `swift-markdown` AST in `Core/Markdown/MarkdownParser.swift`
- [ ] 2.3 Implement `MarkdownStyler` mapping AST nodes to `NSAttributedString` attribute runs in `Features/Editor/MarkdownStyler.swift`
- [ ] 2.4 Hook styler into `NSTextView` via a custom `NSTextLayoutManager`

## 3. Incremental reparse

- [ ] 3.1 Detect changed paragraph ranges on `textDidChange`
- [ ] 3.2 Reparse only affected paragraphs and reapply styling
- [ ] 3.3 Benchmark with a 10k-line fixture; assert < 16 ms keystroke latency

## 4. Code highlighting

- [ ] 4.1 Add highlighter dependency (`Splash` or `Highlightr`)
- [ ] 4.2 Apply highlight attributes inside fenced code blocks
- [ ] 4.3 Fall back to monospace for unknown languages

## 5. Persistence

- [ ] 5.1 Debounce writes ~500 ms; flush on note switch and on app quit
- [ ] 5.2 Subscribe to `VaultService.watch()` and reload on external `modified`
- [ ] 5.3 Conflict prompt when local dirty + external modified

## 6. Inline content

- [ ] 6.1 Render local image references as inline `NSTextAttachment` thumbnails
- [ ] 6.2 Make HTTP(S) links clickable (⌘-click)
- [ ] 6.3 Render GFM tables

## 7. Tests

- [ ] 7.1 Styler unit tests against fixture AST → attribute-run snapshots
- [ ] 7.2 10k-line latency benchmark
- [ ] 7.3 Debounced save test
- [ ] 7.4 External-reload test
