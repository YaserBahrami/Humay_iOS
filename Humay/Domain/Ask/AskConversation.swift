import Foundation

enum AskRole: String, Sendable, Codable {
    case person
    case humay
}

/// One turn in a conversation.
struct AskMessage: Sendable, Hashable, Identifiable {
    let id: UUID
    let role: AskRole
    let text: String
    /// "From your calculated chart & today's transits". Answers state their basis;
    /// questions do not have one.
    let basisLine: String?
    let basisFactors: [BasisFactor]
    let provenance: ContentProvenance
    let createdAt: Date

    init(
        id: UUID = UUID(),
        role: AskRole,
        text: String,
        basisLine: String? = nil,
        basisFactors: [BasisFactor] = [],
        provenance: ContentProvenance,
        createdAt: Date = .now
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.basisLine = basisLine
        self.basisFactors = basisFactors
        self.provenance = provenance
        self.createdAt = createdAt
    }
}

/// A conversation.
///
/// Held whole rather than as a list of independent questions, because a follow-up only
/// makes sense against what came before — and because that is the shape a real
/// interpretation service will need.
struct AskConversation: Sendable, Hashable, Identifiable {
    let id: UUID
    let startedAt: Date
    var messages: [AskMessage]

    init(id: UUID = UUID(), startedAt: Date = .now, messages: [AskMessage] = []) {
        self.id = id
        self.startedAt = startedAt
        self.messages = messages
    }

    var isEmpty: Bool { messages.isEmpty }

    var lastQuestion: String? {
        messages.last { $0.role == .person }?.text
    }
}

/// A question worth asking, offered before the person has to think of one.
struct AskSuggestion: Sendable, Hashable, Identifiable {
    let id: String
    let question: String
    /// Why this is being suggested today, when there is a reason.
    let prompt: String?
}
