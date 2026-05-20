import SwiftUI

struct ChatsSidebar: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.largeTitle).foregroundStyle(.tertiary)
            Text("No conversations yet").font(.headline)
            Text("Start a chat from the right pane.\nConversations will appear here.")
                .font(.callout).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
