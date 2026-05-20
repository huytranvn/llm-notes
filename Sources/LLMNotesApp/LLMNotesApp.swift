import SwiftUI
import LLMNotesKit

@main
struct LLMNotesApp: App {
    var body: some Scene {
        WindowGroup("LLM Notes") {
            MainWindowView()
        }
        .commands { AppCommands() }

        Settings {
            SettingsView()
        }
    }
}
