import SwiftUI
import LLMNotesKit

@main
struct LLMNotesApp: App {
    var body: some Scene {
        WindowGroup("LLM Notes") {
            ContentView()
        }
        .commands { AppCommands() }

        Settings {
            SettingsView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } content: {
            EditorView()
        } detail: {
            ChatPaneView()
        }
        .frame(minWidth: 900, minHeight: 600)
    }
}
