import SwiftUI

public struct SidebarView: View {
    @Environment(AppState.self) private var appState
    @Environment(VaultTreeViewModel.self) private var vault

    public init() {}

    public var body: some View {
        @Bindable var bindableState = appState
        @Bindable var bindableVault = vault

        VStack(spacing: 0) {
            Picker("", selection: $bindableState.section) {
                ForEach(AppState.SidebarSection.allCases) { section in
                    Label(section.label, systemImage: section.icon).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 8)
            .padding(.top, 8)

            if vault.rootURL != nil {
                TextField("Search", text: $bindableState.sidebarQuery, prompt: Text("Search"))
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
            }

            Divider()

            Group {
                switch appState.section {
                case .notes: NotesSidebar()
                case .chats: ChatsSidebar()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await vault.chooseVault() }
                } label: { Label("Open Vault", systemImage: "folder") }
            }
        }
    }
}
