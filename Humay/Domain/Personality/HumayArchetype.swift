import Foundation

/// A Humay-original personality archetype.
///
/// This is Category-C entertainment identity: explicitly invented by Humay, never
/// presented as an astrological fact. Archetypes layer on top of the traditional
/// Big Three and give the product a memorable personal hook.
struct HumayArchetype: Sendable, Hashable, Identifiable {
    let id: String
    let name: String
    let summary: String
    let superpower: String
    let growingEdge: String
}

extension HumayArchetype {
    /// The launch catalog. Stable ids — never reorder, only append.
    static let catalog: [HumayArchetype] = [
        HumayArchetype(
            id: "unmovable-romantic",
            name: "The Unmovable Romantic",
            summary: "You have already decided how the story ends. Reality is catching up.",
            superpower: "Absolute commitment to the bit.",
            growingEdge: "The bit is sometimes a person who does not text back."
        ),
        HumayArchetype(
            id: "chaotic-diplomat",
            name: "The Chaotic Diplomat",
            summary: "You resolve conflicts you personally started. Beautifully.",
            superpower: "Peace treaty in one voice note.",
            growingEdge: "Starting three fires to practice firefighting."
        ),
        HumayArchetype(
            id: "quiet-storm",
            name: "The Quiet Storm",
            summary: "Silent in the group chat. Loud in everyone's thoughts later.",
            superpower: "One perfectly timed sentence per week.",
            growingEdge: "Nobody knows what you're planning. Including you."
        ),
        HumayArchetype(
            id: "main-character-off-duty",
            name: "The Main Character (Off Duty)",
            summary: "Cinematic potential, currently horizontal. The plot waits for no one, but you do.",
            superpower: "Narrating your own life like a documentary.",
            growingEdge: "Season 2 has been in development for a while."
        ),
        HumayArchetype(
            id: "overthinking-oracle",
            name: "The Overthinking Oracle",
            summary: "You predicted this. Unfortunately, predicting it did not help.",
            superpower: "Seventeen outcomes mapped before breakfast.",
            growingEdge: "Outcome eighteen: just asking them."
        ),
        HumayArchetype(
            id: "sunshine-menace",
            name: "The Sunshine Menace",
            summary: "Radiates warmth. Causes problems. In that order, always.",
            superpower: "Being forgiven instantly, repeatedly.",
            growingEdge: "\"It was just a joke\" has a half-life."
        ),
        HumayArchetype(
            id: "elegant-chaos",
            name: "The Elegant Chaos",
            summary: "Everything is on fire, but the fire is coordinated and wearing perfume.",
            superpower: "Thriving exactly when things collapse.",
            growingEdge: "Stability feels suspicious. It isn't."
        ),
        HumayArchetype(
            id: "reluctant-leader",
            name: "The Reluctant Leader",
            summary: "Never volunteered. Somehow always in charge by Tuesday.",
            superpower: "Competence that cannot be hidden.",
            growingEdge: "Saying no once, as a treat."
        ),
        HumayArchetype(
            id: "soft-realist",
            name: "The Soft Realist",
            summary: "Knows exactly how things are. Chooses kindness anyway. Devastating combination.",
            superpower: "Honesty that feels like a hug.",
            growingEdge: "Protecting people from truths they can handle."
        ),
        HumayArchetype(
            id: "midnight-strategist",
            name: "The Midnight Strategist",
            summary: "Your best ideas arrive at 1 AM. Your execution arrives around noon. Eventually.",
            superpower: "Five-dimensional plans nobody asked for.",
            growingEdge: "The 9 AM version of you has questions."
        ),
        HumayArchetype(
            id: "charming-skeptic",
            name: "The Charming Skeptic",
            summary: "Doesn't believe in astrology. Opened the app anyway. Twice today.",
            superpower: "Enjoying things ironically until it becomes sincere.",
            growingEdge: "That's just enjoying things."
        ),
        HumayArchetype(
            id: "dramatic-stabilizer",
            name: "The Dramatic Stabilizer",
            summary: "Announces everything is falling apart while quietly holding it together.",
            superpower: "Peak performance under self-invented pressure.",
            growingEdge: "Letting one thing be fine out loud."
        )
    ]

    static func resolve(id: String) -> HumayArchetype? {
        catalog.first { $0.id == id }
    }
}
