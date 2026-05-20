import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Note") {}.keyboardShortcut("n", modifiers: .command)
        }
        CommandMenu("AI") {
            Button("Run Inline Action…") {}.keyboardShortcut("a", modifiers: [.command, .shift])
        }
    }
}
