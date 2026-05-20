import SwiftUI

struct NotesSidebar: View {
    @Environment(AppState.self) private var appState
    @Environment(VaultTreeViewModel.self) private var vault

    var body: some View {
        Group {
            if vault.rootURL == nil {
                emptyState
            } else {
                noteList
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray").font(.largeTitle).foregroundStyle(.tertiary)
            Text("No vault open").font(.headline)
            Text("Pick a folder of `.md` notes to get started.")
                .font(.callout).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Open Vault…") {
                Task { await vault.chooseVault() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var noteList: some View {
        @Bindable var bindable = appState
        let filtered = filteredNotes()
        let recent = Array(filtered.prefix(5))
        let rest = Array(filtered.dropFirst(5))

        List(selection: $bindable.selectedNoteID) {
            if !recent.isEmpty {
                Section("Recent") {
                    ForEach(recent) { note in row(for: note).tag(note.id) }
                }
            }
            if !rest.isEmpty {
                Section("All Notes") {
                    ForEach(rest) { note in row(for: note).tag(note.id) }
                }
            }
            if filtered.isEmpty {
                Text("No matches")
                    .font(.callout).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.sidebar)
    }

    private func row(for note: Note) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(note.title).font(.body).lineLimit(1)
            Text(note.modifiedAt, format: .relative(presentation: .named))
                .font(.caption).foregroundStyle(.secondary)
        }
    }

    private func filteredNotes() -> [Note] {
        let q = appState.sidebarQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return vault.notes }
        return vault.notes.filter { $0.title.lowercased().contains(q) }
    }
}
