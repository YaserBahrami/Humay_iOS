# Mock / Preview Data Strategy

**Status:** reset on 2026-08-12.

The former app-wide mock astrology runtime and large fixture catalog were removed before production implementation.

## Current rule

There is no `ContentMode.mock` wired as the live application and no production runtime service may silently return illustrative astrology content.

Feature-scoped sample data now exists for D2 and for the non-visual D3 engineering foundation:

- `DevelopmentD2Sample` supports the approved Today/Circle implementation;
- `DevelopmentD3Sample` supports typed Sky/Calendar state and contract testing before D3 visual approval.

Both are compiled only under `#if DEBUG`. D3 sample events are explicitly unverified and are not calculation or methodology evidence. Release uses production-unavailable/empty feature composition and never treats sample astrology as real output.

Additional preview/sample data may be added only when it serves a specific implemented feature or approved non-visual contract foundation.

When added, preview content must:

- live behind an unmistakable preview/test boundary;
- never seed user data in a normal launch;
- never be used to derive production astrology facts;
- be small enough to delete with the feature;
- carry obvious provenance where confusion is possible;
- not shape provider interfaces more than the real use case requires.

## UI previews

SwiftUI previews may use local sample values with no network/persistence side effects. Preview wiring must not be the same composition path as production live services.

## Tests

Tests may construct deterministic domain values directly. Large narrative astrology fixture libraries should not be recreated until a concrete test requirement justifies them.
