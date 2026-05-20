import Foundation

struct LLMModel: Sendable, Hashable {
    let id: String
    let displayName: String
}

struct ChatMessage: Sendable, Hashable {
    enum Role: String, Sendable { case system, user, assistant, tool }
    let role: Role
    let content: String
}

struct ToolCall: Sendable, Hashable {
    let id: String
    let name: String
    let arguments: String
}

struct Usage: Sendable, Hashable {
    let inputTokens: Int
    let outputTokens: Int
}

enum ChatEvent: Sendable {
    case delta(String)
    case toolCall(ToolCall)
    case toolResult(id: String, result: String)
    case done(Usage)
}

struct ChatRequest: Sendable {
    let model: String
    let messages: [ChatMessage]
}

protocol LLMProvider: Sendable {
    var id: String { get }
    func models() async throws -> [LLMModel]
    func stream(_ request: ChatRequest) -> AsyncThrowingStream<ChatEvent, Error>
}
