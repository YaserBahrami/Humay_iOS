// ─────────────────────────────────────────────────────────────────────────────
//  MOCK CONTENT BOUNDARY — NOT A CALCULATION
//
//  Everything under Humay/Data/Mock is illustrative sample content. It is not
//  ephemeris output, it has not been validated against any methodology, and it
//  must never be used as an engineering fixture or a test oracle.
//
//  See docs/development/DEVIATIONS.md (DEV-001) and
//  docs/design/DESIGN_AUTHORITY.md section 07.
// ─────────────────────────────────────────────────────────────────────────────

import Foundation

/// Adopted by every mock service.
///
/// The only way to construct a `ContentProvenance` inside this directory is through
/// `Self.provenance(_:)`. No mock writes `.mockFixture(fixtureID:)` literally, so a
/// value cannot escape this layer without being marked.
protocol MockContentProvider {
    /// Prefix for every fixture identifier this provider emits.
    static var fixtureNamespace: String { get }
}

extension MockContentProvider {
    static func provenance(_ id: String) -> ContentProvenance {
        .mockFixture(fixtureID: "\(fixtureNamespace).\(id)")
    }

    /// Shown beside sample content in development builds.
    static var mockNotice: String {
        "Sample content — not calculated."
    }
}

/// Simulated service latency.
///
/// Real, if small, so that loading states are exercised on device rather than being
/// dead code. Previews and tests use `.instant` so neither is slowed by theatre.
struct MockLatency: Sendable {
    let range: ClosedRange<Duration>

    static let instant = MockLatency(range: .zero ... .zero)
    static let realistic = MockLatency(range: .milliseconds(180) ... .milliseconds(520))

    func wait() async {
        guard range.upperBound > .zero else { return }
        let lower = range.lowerBound.milliseconds
        let upper = range.upperBound.milliseconds
        let chosen = lower == upper ? lower : Int64.random(in: lower...upper)
        try? await Task.sleep(for: .milliseconds(chosen))
    }
}

private extension Duration {
    var milliseconds: Int64 {
        components.seconds * 1_000 + components.attoseconds / 1_000_000_000_000_000
    }
}
