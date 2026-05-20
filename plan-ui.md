# UI Plan — modeled on NotePlus

## Context

NotePlus advertises itself as a "true native Swift" macOS app that combines a WYSIWYG markdown editor with a multi-provider LLM chat panel. We want the same look-and-feel: a single window, three-column layout, macOS-native chrome (translucent sidebar, NSToolbar, SF Symbols, system font, automatic dark mode), and zero non-native widgets.

Because the NotePlus marketing screenshots aren't directly fetchable, this plan is grounded in (a) the product description, (b) standard macOS sidebar-app conventions used by Bear / Craft / Things / Obsidian, and (c) what SwiftUI's `NavigationSplitView` renders by default. Everything below is built with stock SwiftUI components — no custom theming or non-native look.

## Layout

```
┌─────────────────────────────────────────────────────────────┐
│  Toolbar:  [⌃]  [✎ New]   < spacer >   Title    [💬]  [⚙]  │
├──────────────┬─────────────────────────────────┬────────────┤
│              │                                 │            │
│  Sidebar     │           Editor                │   Chat     │
│              │                                 │  (toggle)  │
│  [Notes]     │   # WYSIWYG markdown            │            │
│  [Chats]     │                                 │  ┌──────┐  │
│              │   Live-styled, plain-md         │  │ msg  │  │
│  📁 Vault    │   underneath.                   │  └──────┘  │
│   • Note A   │                                 │            │
│   • Note B   │                                 │  composer  │
│              │                                 │  [Send →]  │
│  Search…     │                                 │            │
└──────────────┴─────────────────────────────────┴────────────┘
```

- **Single window**, `NavigationSplitView` with three columns. Sidebar (~240 pt), editor (flexible), chat (~340 pt) — chat collapsible.
- Toolbar lives at the window level using `.toolbar { … }`. Items: sidebar toggle, new-note, breadcrumb/title (middle), chat toggle, settings.
- Sidebar uses `.listStyle(.sidebar)` and renders against `NSVisualEffectView` (SwiftUI does this automatically when placed in the leading column of `NavigationSplitView`).

## Sidebar

- Top section: segmented control **[Notes | Chats]**. Notes shows the vault tree; Chats shows conversation list.
- Search field below the segmented control (debounced; uses `SearchIndex` later — for now plain title filter).
- **Notes** view:
  - Recent section at top (last 5 modified)
  - Vault tree below (folders + notes), `DisclosureGroup`
- **Chats** view:
  - One row per conversation, with provider badge and last-message preview
  - "New Chat" affordance at the top

## Editor pane

- Centered content with comfortable max width (≈ 760 pt) and side padding when the window is wide (focus-mode-lite). The buffer can scroll past — width capping is just for line length.
- WYSIWYG markdown: headings, lists, links, inline code, fenced code (syntax-highlighted), checklists, tables, inline images, blockquotes. (Built in `add-markdown-editor`.)
- Empty state when no note is selected: a centered "Pick a note or press ⌘N" hint.
- Status footer (small, muted): word count · last saved time · vault path. Shown only when a note is open.

## Chat pane

- Toggleable from the toolbar (`⌘⇧L`).
- Header: model picker + provider badge + "New" + "Clear".
- Message list: plain rows (no bubbles) with role icons — user is right-aligned subtle background, assistant is full-width with markdown rendering. Code blocks rendered with the same highlighter as the editor.
- Composer pinned to the bottom: multi-line `TextEditor` with auto-grow up to ~6 lines, send button (`⌘↩`), stop button while streaming, attach-note (@) button.

## Inline AI overlay

- When the user invokes Inline AI on a selection, the picker appears as a popover anchored to the selection rect.
- During streaming, a ghost overlay (semi-transparent text view) renders the proposed replacement directly over the selection.
- `↵` accepts, `⎋` rejects. (Built in `add-inline-ai`.)

## Settings

- Standard macOS Settings window via the `Settings { … }` scene.
- Tabs: **Providers**, **MCP Servers**, **Appearance** (already stubbed). Each tab is a form using `Form { … }` with `SecureField` for API keys.

## Visual style

- **Font**: system body (`.body`) for UI chrome; system body for prose; `SF Mono` for code.
- **Color**: accent color uses the system tint. No custom palette.
- **Dark mode**: automatic via system. No manual toggle.
- **Density**: macOS regular (not compact). No custom row heights.
- **Icons**: SF Symbols everywhere. Sidebar segments: `doc.text` (Notes), `bubble.left.and.bubble.right` (Chats). Toolbar: `sidebar.left`, `square.and.pencil`, `bubble.right`, `gear`.

## Implementation order

These pieces extend or replace what already exists. None of this requires touching the spec for feature behavior — it adds the visual + layout layer on top.

1. **Shell refactor** (this change): split `ContentView` into `MainWindowView` that owns sidebar/editor/chat visibility state. Toolbar, sidebar segmented control, chat-toggle, settings button.
2. **Sidebar segmentation**: split `SidebarView` into `NotesSidebar` + `ChatsSidebar`, switched by the segmented picker. Add the Recent section and search field.
3. **Editor empty state + status footer**: small composition wrappers in `EditorView` — content stays a stub until `add-markdown-editor` lands.
4. **Chat header + composer scaffold**: shape the chat pane with header bar, message list (`ScrollView` of placeholder rows), and composer. The streaming wiring comes from `add-llm-chat`.
5. **Settings forms**: replace the empty tab labels with `Form` placeholders carrying the eventual fields (provider key, default model, MCP server list).

## Verification

- Open the app on a fresh machine: a single window with the three-column layout, NotePlus-like proportions, native sidebar translucency.
- `⌘⇧L` collapses/expands the chat pane.
- `⌘⌥S` (or sidebar button) collapses/expands the sidebar.
- The sidebar segmented picker swaps between Notes and Chats with no flicker.
- Settings opens via `⌘,` with three tabs.
- Light → Dark mode in System Settings flips the window with no manual code.
