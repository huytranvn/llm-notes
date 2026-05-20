import SwiftUI

public struct EditorView: View {
    @Environment(AppState.self) private var appState
    @Environment(VaultTreeViewModel.self) private var vault

    @State private var content: String = ""
    @State private var loadedID: UUID?
    @State private var savedAt: Date?
    @State private var saveTask: Task<Void, Never>?

    public init() {}

    public var body: some View {
        Group {
            if let id = appState.selectedNoteID, let note = vault.notes.first(where: { $0.id == id }) {
                editor(for: note)
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text").font(.system(size: 48)).foregroundStyle(.tertiary)
            Text("Pick a note or press ⌘N").font(.title3).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func editor(for note: Note) -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 0)
                TextEditor(text: $content)
                    .font(.system(.body, design: .default))
                    .scrollContentBackground(.hidden)
                    .frame(maxWidth: 760)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .onChange(of: content) { _, newValue in scheduleSave(for: note, content: newValue) }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()
            footer(for: note)
        }
        .task(id: note.id) { await load(note) }
    }

    private func footer(for note: Note) -> some View {
        HStack {
            Text("\(wordCount(content)) words")
            Text("·").foregroundStyle(.tertiary)
            if let savedAt {
                Text("saved \(savedAt, format: .relative(presentation: .named))")
            } else {
                Text("saved \(note.modifiedAt, format: .relative(presentation: .named))")
            }
            Spacer()
            Text(note.path.lastPathComponent).foregroundStyle(.tertiary)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }

    private func load(_ note: Note) async {
        let text = await vault.loadContent(for: note.id) ?? ""
        loadedID = note.id
        content = text
        savedAt = nil
    }

    private func scheduleSave(for note: Note, content: String) {
        guard loadedID == note.id else { return } // ignore edits before load completes
        saveTask?.cancel()
        let textToSave = content
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            if Task.isCancelled { return }
            await vault.save(noteID: note.id, content: textToSave)
            savedAt = .now
        }
    }

    private func wordCount(_ text: String) -> Int {
        text.split { $0.isWhitespace || $0.isNewline }.count
    }
}
