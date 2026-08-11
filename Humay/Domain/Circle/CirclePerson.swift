import Foundation

/// How someone relates to the person using the application.
enum RelationshipRole: String, Sendable, CaseIterable, Identifiable, Codable {
    case partner, family, friend, colleague, dating, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .partner: "Partner"
        case .family: "Family"
        case .friend: "Friend"
        case .colleague: "Colleague"
        case .dating: "Dating"
        case .other: "Someone else"
        }
    }

    /// The one relationship that earns the heavier rule in the interface. The design
    /// reserves a single emphasis case, and this is it.
    var isCore: Bool { self == .partner }
}

/// Someone the person using the application cares about.
///
/// Their birth data was entered by the person using the app, for relationship
/// calculations only. These people have no profile of their own and cannot see this.
struct CirclePerson: Sendable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var role: RelationshipRole
    var birth: BirthDetails

    init(id: UUID = UUID(), name: String, role: RelationshipRole, birth: BirthDetails) {
        self.id = id
        self.name = name
        self.role = role
        self.birth = birth
    }

    /// One or two letters for the avatar. No photographs — these people did not
    /// consent to being in an address book.
    var initials: String {
        let words = name.split(separator: " ").prefix(2)
        let letters = words.compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased()
    }
}
