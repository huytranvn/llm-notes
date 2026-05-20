## Why

The current app window is a three-column `NavigationSplitView` with placeholder text in the editor and chat panes. It lacks the actual shell elements that make NotePlus feel like a real Mac app: a proper toolbar, a sidebar with Notes/Chats segmentation, search, recent items, a chat pane header and composer, an editor empty state, and Settings forms. Building the shell now — independent of feature behavior — lets the editor, chat, and inline-AI capabilities drop into a ready-made UI rather than each reinventing window structure.

## What Changes

- Replace `ContentView` with `MainWindowView` that owns sidebar/chat visibility state and renders the three-column layout.
- Add a window toolbar with sidebar toggle, new-note, chat toggle, and settings buttons (`⌘⇧L`, `⌘,`).
- Split `SidebarView` into `NotesSidebar` and `ChatsSidebar`, switched by a segmented control; add a search field and a Recent section.
- Add an editor empty state and a status footer scaffold.
- Add a chat pane header (provider/model picker scaffold), placeholder message list, and a composer scaffold.
- Replace empty Settings tabs with `Form` scaffolds for Providers, MCP Servers, and Appearance.

All work uses stock SwiftUI components and SF Symbols — no custom theming, no non-native widgets. Behavioral wiring (real editor, streaming chat, real settings persistence) remains the responsibility of the existing feature changes.

## Capabilities

### New Capabilities
- `ui-shell`: app window layout, toolbar, sidebar segmentation, chat-pane chrome, settings window structure, and theming conventions.

### Modified Capabilities
<!-- none — feature specs (editor, llm-chat, settings, inline-ai) keep their behavioral requirements; this change only adds structural UI scaffolding. -->

## Impact

- New `Features/Shell/MainWindowView.swift`.
- `Features/VaultBrowser/SidebarView.swift` becomes a router; new `NotesSidebar.swift` and `ChatsSidebar.swift`.
- `Features/Chat/ChatPaneView.swift` gains a header and composer scaffold.
- `Features/Editor/EditorView.swift` gains an empty state and footer.
- `Features/Settings/*` gain `Form`-based tab scaffolds.
- No new SPM dependencies.
- No on-disk format changes.
