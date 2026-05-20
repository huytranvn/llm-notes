import SwiftUI

public struct ChatPaneView: View {
    @State private var draft: String = ""
    @State private var isStreaming: Bool = false
    @State private var model: String = "gpt-4o"

    private let models = ["gpt-4o", "claude-opus-4-7", "gemini-2.0-pro", "llama3.1:70b (ollama)"]

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            messageList
            Divider()
            composer
        }
        .background(.background)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Picker("Model", selection: $model) {
                ForEach(models, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: 220)
            Spacer()
            Button { } label: { Image(systemName: "square.and.pencil") }
                .help("New Conversation")
            Button { } label: { Image(systemName: "trash") }
                .help("Clear")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var messageList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                placeholderRow(
                    role: "You",
                    icon: "person.crop.circle",
                    text: "What's the architecture of this codebase?"
                )
                placeholderRow(
                    role: "Assistant",
                    icon: "sparkles",
                    text: "I'll wire up here once `add-llm-chat` lands. Right now this is just shell scaffolding to validate the layout."
                )
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func placeholderRow(role: String, icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(role).font(.caption).foregroundStyle(.secondary)
                Text(text).font(.body).textSelection(.enabled)
            }
        }
    }

    private var composer: some View {
        VStack(spacing: 6) {
            TextEditor(text: $draft)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8).fill(Color(NSColor.textBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(Color(NSColor.separatorColor))
                )
                .frame(minHeight: 60, maxHeight: 160)

            HStack {
                Button {} label: { Image(systemName: "at") }
                    .help("Mention a note")
                Spacer()
                if isStreaming {
                    Button {
                        isStreaming = false
                    } label: { Label("Stop", systemImage: "stop.fill") }
                        .keyboardShortcut(".", modifiers: .command)
                } else {
                    Button {
                        guard !draft.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        draft = ""
                        isStreaming = true
                    } label: { Label("Send", systemImage: "paperplane.fill") }
                        .keyboardShortcut(.return, modifiers: .command)
                        .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .padding(12)
    }
}
