## ADDED Requirements

### Requirement: Three-column main window
The app SHALL present a single window with a three-column `NavigationSplitView`: sidebar (leading), editor (center), chat (trailing). The sidebar and chat columns SHALL be collapsible; the editor SHALL never be collapsed.

#### Scenario: Default layout on first launch
- **WHEN** the app starts
- **THEN** all three columns SHALL be visible
- **AND** the sidebar SHALL be ~240 pt wide and the chat column ~340 pt wide

#### Scenario: Collapse chat
- **WHEN** the user clicks the chat toolbar button or presses `⌘⇧L`
- **THEN** the chat column SHALL collapse
- **AND** the editor SHALL expand to fill the freed space

#### Scenario: Collapse sidebar
- **WHEN** the user clicks the sidebar toolbar button
- **THEN** the sidebar SHALL collapse
- **AND** the editor + chat SHALL re-flow

### Requirement: Window toolbar
The app SHALL provide a window-level toolbar with: sidebar toggle, new-note button, current-note title (centered, truncating), chat toggle, and Settings button.

#### Scenario: New-note shortcut
- **WHEN** the user presses `⌘N`
- **THEN** a new note SHALL be created in the current vault folder
- **AND** the editor SHALL focus the new note's title

#### Scenario: Settings shortcut
- **WHEN** the user presses `⌘,`
- **THEN** the Settings window SHALL open

### Requirement: Sidebar segmentation
The sidebar SHALL provide a segmented control at the top with two segments — Notes and Chats — and SHALL render the corresponding sub-view below it.

#### Scenario: Switch to Chats
- **WHEN** the user selects the Chats segment
- **THEN** the sidebar SHALL render the conversation list

#### Scenario: Switch to Notes
- **WHEN** the user selects the Notes segment
- **THEN** the sidebar SHALL render the Recent section and vault tree

### Requirement: Sidebar search field
The sidebar SHALL include a search field below the segmented control that filters the visible list by title with debouncing of at least 100 ms.

#### Scenario: Filter notes by title
- **WHEN** the user types in the search field while Notes is active
- **THEN** the note list SHALL filter to titles containing the query (case-insensitive)

#### Scenario: Clear search
- **WHEN** the user clears the search field
- **THEN** the full list SHALL be restored

### Requirement: Editor empty state
The editor SHALL render an empty state when no note is selected.

#### Scenario: No selection
- **WHEN** no note is selected
- **THEN** the editor SHALL render a centered hint with the text "Pick a note or press ⌘N"

#### Scenario: Selection clears empty state
- **WHEN** the user selects a note
- **THEN** the empty state SHALL be replaced with the editor surface

### Requirement: Editor status footer
The editor SHALL render a small, muted status footer when a note is open, showing word count and last-saved time.

#### Scenario: Open note shows footer
- **WHEN** a note is open in the editor
- **THEN** the footer SHALL display "<n> words · saved <relative time>"

### Requirement: Chat pane header and composer
The chat pane SHALL render a header containing a model picker, a "New Conversation" button, and a "Clear" button; and SHALL render a composer pinned to the bottom with multi-line input, a send button (`⌘↩`), and a stop button while streaming.

#### Scenario: Send shortcut
- **WHEN** the user has typed text in the composer and presses `⌘↩`
- **THEN** the message SHALL be sent
- **AND** the composer SHALL clear

#### Scenario: Stop button while streaming
- **WHEN** a chat turn is streaming
- **THEN** the send button SHALL be replaced by a stop button
- **AND** clicking it SHALL cancel the in-flight task

### Requirement: Settings window structure
The Settings window SHALL contain three tabs — Providers, MCP Servers, Appearance — and each SHALL be implemented as a SwiftUI `Form` with appropriate field types (SecureField for API keys, Picker for default model, List for server entries).

#### Scenario: Provider key field is secure
- **WHEN** the user types into a provider API key field
- **THEN** the field SHALL mask input as a `SecureField`

### Requirement: Native macOS look and feel
The UI SHALL use stock SwiftUI components, SF Symbols, the system font, and the system accent color, and SHALL adapt to light/dark mode automatically without a manual toggle.

#### Scenario: System dark mode switch
- **WHEN** the user switches the system appearance from light to dark
- **THEN** the app SHALL switch instantly without restart
- **AND** SHALL use system-default colors throughout

#### Scenario: No custom widgets
- **WHEN** any view is reviewed
- **THEN** it SHALL only use standard SwiftUI components (no custom-drawn chrome, no Electron-style widgets)
