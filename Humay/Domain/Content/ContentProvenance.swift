import Foundation

/// Where a piece of content came from.
///
/// This is carried, non-optionally, by every content-bearing value in the domain. It
/// exists so that "mock content must never be mistaken for a calculation" is a fact the
/// type system enforces rather than a comment someone has to remember.
///
/// Today only `.mockFixture` has a producer. The other two cases are the shapes real
/// content will take, declared now so that adding them later is not a redesign.
///
/// See `docs/development/DEVIATIONS.md` — DEV-001.
enum ContentProvenance: Sendable, Hashable {
    /// Illustrative sample content. Not calculated, not validated, not an oracle.
    case mockFixture(fixtureID: String)

    /// Humay-owned pre-generated catalog content. Editorial, deliberately coarse.
    case editorialCatalog(catalogVersion: String)

    /// Output of the calculation layer, under a named methodology version.
    case calculated(engine: String, methodologyVersion: String)

    var isMock: Bool {
        if case .mockFixture = self { return true }
        return false
    }

    /// Human-readable attribution, for diagnostics and the debug marker.
    var debugDescription: String {
        switch self {
        case .mockFixture(let id): "mock fixture · \(id)"
        case .editorialCatalog(let version): "catalog · \(version)"
        case .calculated(let engine, let methodology): "\(engine) · \(methodology)"
        }
    }
}
