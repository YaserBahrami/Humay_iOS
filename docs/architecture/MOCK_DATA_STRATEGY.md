# Mock / Preview Data Strategy

**Status:** reset on 2026-08-12.

The former app-wide mock astrology runtime and large fixture catalog were removed before production implementation.

## Current rule

There is no `ContentMode.mock` wired as the live application and no production runtime service may silently return illustrative astrology content.

Preview/sample data may be added later only when it serves a specific implemented feature.

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
