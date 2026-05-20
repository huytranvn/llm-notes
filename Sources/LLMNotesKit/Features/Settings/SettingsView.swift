import SwiftUI

public struct SettingsView: View {
    public init() {}

    public var body: some View {
        TabView {
            ProvidersTab()
                .tabItem { Label("Providers", systemImage: "key") }
            MCPServersTab()
                .tabItem { Label("MCP", systemImage: "server.rack") }
            AppearanceTab()
                .tabItem { Label("Appearance", systemImage: "paintbrush") }
        }
        .frame(width: 560, height: 420)
    }
}

private struct ProvidersTab: View {
    @State private var openAIKey: String = ""
    @State private var anthropicKey: String = ""
    @State private var geminiKey: String = ""
    @State private var ollamaURL: String = "http://localhost:11434"
    @State private var defaultModel: String = "gpt-4o"

    private let models = ["gpt-4o", "claude-opus-4-7", "gemini-2.0-pro"]

    var body: some View {
        Form {
            Section("OpenAI") {
                SecureField("API Key", text: $openAIKey)
            }
            Section("Anthropic") {
                SecureField("API Key", text: $anthropicKey)
            }
            Section("Gemini") {
                SecureField("API Key", text: $geminiKey)
            }
            Section("Ollama") {
                TextField("Base URL", text: $ollamaURL)
            }
            Section("Default") {
                Picker("Default model", selection: $defaultModel) {
                    ForEach(models, id: \.self) { Text($0).tag($0) }
                }
            }
        }
        .formStyle(.grouped)
    }
}

private struct MCPServer: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var command: String
    var args: String
}

private struct MCPServersTab: View {
    @State private var servers: [MCPServer] = []
    @State private var selection: MCPServer.ID?

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selection) {
                ForEach(servers) { server in
                    VStack(alignment: .leading) {
                        Text(server.name).font(.body)
                        Text("\(server.command) \(server.args)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .tag(server.id)
                }
            }
            Divider()
            HStack {
                Button { servers.append(MCPServer(name: "New Server", command: "", args: "")) } label: {
                    Image(systemName: "plus")
                }
                Button {
                    if let id = selection { servers.removeAll { $0.id == id } }
                } label: { Image(systemName: "minus") }
                .disabled(selection == nil)
                Spacer()
            }
            .padding(8)
        }
    }
}

private struct AppearanceTab: View {
    @State private var editorFont: String = "System"
    @State private var density: String = "Regular"

    var body: some View {
        Form {
            Picker("Editor font", selection: $editorFont) {
                Text("System").tag("System")
                Text("SF Mono").tag("SF Mono")
                Text("New York").tag("New York")
            }
            Picker("Density", selection: $density) {
                Text("Regular").tag("Regular")
                Text("Compact").tag("Compact")
            }
        }
        .formStyle(.grouped)
    }
}
