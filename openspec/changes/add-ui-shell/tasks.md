## 1. Shell

- [ ] 1.1 Add `Features/Shell/MainWindowView.swift` owning `@State` for `isSidebarVisible` and `isChatVisible`
- [ ] 1.2 Replace `ContentView` in `LLMNotesApp.swift` with `MainWindowView`
- [ ] 1.3 Window-level `.toolbar { … }`: sidebar toggle, new-note, title, chat toggle, settings
- [ ] 1.4 Keyboard shortcuts: `⌘N`, `⌘,`, `⌘⇧L`

## 2. Sidebar

- [ ] 2.1 Add segmented control `Picker` at top of sidebar (Notes / Chats)
- [ ] 2.2 Split sidebar into `NotesSidebar.swift` and `ChatsSidebar.swift`
- [ ] 2.3 Search field below segmented control with 100 ms debounce
- [ ] 2.4 Recent section (last 5 modified) in `NotesSidebar`
- [ ] 2.5 Vault tree using `DisclosureGroup` for folders

## 3. Editor pane

- [ ] 3.1 Empty state view ("Pick a note or press ⌘N")
- [ ] 3.2 Status footer with word count + relative saved time
- [ ] 3.3 Centered content max-width (≈ 760 pt) when window is wide

## 4. Chat pane

- [ ] 4.1 Header bar: model picker stub, "New", "Clear" buttons
- [ ] 4.2 Placeholder message list (`ScrollView` of role-styled rows)
- [ ] 4.3 Composer with multi-line `TextEditor`, send (`⌘↩`), stop button
- [ ] 4.4 Auto-grow composer up to ~6 lines

## 5. Settings

- [ ] 5.1 Providers tab: `Form` with provider list + `SecureField` per key + default-model `Picker`
- [ ] 5.2 MCP Servers tab: `Form` with `List` of server entries (name/command/args)
- [ ] 5.3 Appearance tab: `Form` with editor font picker and density toggle

## 6. Verification

- [ ] 6.1 Manual run: layout matches mockup, toolbar shortcuts work
- [ ] 6.2 Light → Dark mode flip works without code changes
- [ ] 6.3 Sidebar/chat collapse animations smooth
- [ ] 6.4 `openspec validate add-ui-shell --strict` passes
