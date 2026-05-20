import SwiftUI

public struct SidebarView: View {
    @State private var vm = VaultTreeViewModel()

    public init() {}

    public var body: some View {
        Group {
            if vm.rootURL == nil {
                emptyState
            } else {
                noteList
            }
        }
        .frame(minWidth: 220)
        .toolbar {
            ToolbarItem {
                Button {
                    Task { await vm.createNote() }
                } label: { Image(systemName: "square.and.pencil") }
                .disabled(vm.rootURL == nil)
            }
            ToolbarItem {
                Button {
                    Task { await vm.chooseVault() }
                } label: { Image(systemName: "folder") }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("No vault open").font(.headline)
            Text("Pick a folder of `.md` notes to get started.")
                .font(.callout).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Open Vault…") { Task { await vm.chooseVault() } }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var noteList: some View {
        List(vm.notes) { note in
            VStack(alignment: .leading) {
                Text(note.title).font(.body)
                Text(note.modifiedAt, style: .date)
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
