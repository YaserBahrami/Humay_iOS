# Testing Strategy

**Status:** production baseline after the 2026-08-12 reset.

## Frameworks

- Swift Testing for unit/domain tests.
- XCTest / XCUITest for UI launch and interaction tests.

## Baseline test targets

The Xcode unit-test and UI-test targets are retained. Prototype tests whose subjects were removed are deleted rather than kept as misleading coverage.

The clean baseline keeps only smoke/domain invariants until production features are reintroduced.

## Cross-device requirement

Implemented UI families must be tested on representative iPhone and iPad destinations.

At minimum, the feature-level verification matrix should consider:

- iPhone portrait Light;
- iPhone portrait Dark;
- iPad portrait Light;
- iPad portrait Dark;
- iPad landscape for screens whose composition changes;
- a narrower iPad multitasking/compact-width case when the layout supports it;
- Dynamic Type accessibility sizes for text-heavy flows.

Do not assert pixel-identical layouts between iPhone and iPad. Assert behavior, accessibility identifiers, route state and layout invariants appropriate to each device class.

## Visual reconciliation

After an approved screen is implemented, capture actual simulator/device screenshots and compare them against the repository reference package. Visual evidence belongs with the design/implementation phase documentation rather than in opaque local-only snapshots.

## Data/provider tests

Production provider adapters receive contract tests when introduced. Preview/mock output must never be used as proof that production astrology calculations are correct.

## Persistence tests

When durable persistence is reintroduced, test:

- save/load round trips;
- explicit unknown birth time/location preservation;
- schema migrations;
- failure behavior without silent volatile fallback.
