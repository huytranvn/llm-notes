import SwiftUI

public struct SettingsView: View {
    public init() {}
    public var body: some View {
        TabView {
            Text("Providers").tabItem { Label("Providers", systemImage: "key") }
            Text("MCP Servers").tabItem { Label("MCP", systemImage: "server.rack") }
            Text("Appearance").tabItem { Label("Appearance", systemImage: "paintbrush") }
        }
        .frame(width: 520, height: 380)
    }
}
