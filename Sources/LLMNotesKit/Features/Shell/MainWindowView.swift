import SwiftUI

public struct MainWindowView: View {
    @State private var appState = AppState()
    @State private var vault = VaultTreeViewModel()
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    public init() {}

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 220, ideal: 240, max: 320)
        } detail: {
            HStack(spacing: 0) {
                EditorView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                if appState.isChatVisible {
                    Divider()
                    ChatPaneView()
                        .frame(minWidth: 320, idealWidth: 340, maxWidth: 480)
                }
            }
        }
        .frame(minWidth: 960, minHeight: 600)
        .environment(appState)
        .environment(vault)
        .toolbar(id: "main") { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some CustomizableToolbarContent {
        ToolbarItem(id: "new-note", placement: .navigation) {
            Button {
                Task { await vault.createNote() }
            } label: { Label("New Note", systemImage: "square.and.pencil") }
            .keyboardShortcut("n", modifiers: .command)
            .disabled(vault.rootURL == nil)
        }
        ToolbarItem(id: "title", placement: .principal) {
            Text(currentTitle).font(.headline).lineLimit(1).truncationMode(.middle)
        }
        ToolbarItem(id: "toggle-chat", placement: .primaryAction) {
            Button {
                appState.isChatVisible.toggle()
            } label: {
                Label("Toggle Chat",
                      systemImage: appState.isChatVisible ? "bubble.right.fill" : "bubble.right")
            }
            .keyboardShortcut("l", modifiers: [.command, .shift])
        }
    }

    private var currentTitle: String {
        if let id = appState.selectedNoteID, let note = vault.notes.first(where: { $0.id == id }) {
            return note.title
        }
        return "LLM Notes"
    }
}
