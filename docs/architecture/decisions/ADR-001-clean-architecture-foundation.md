# ADR-001 — SwiftUI + Clean Architecture Foundation

**Status:** Accepted  
**Date:** 2026-08-12

## Context

Humay is restarting production implementation from a cleaned Xcode project after removing a broad mock-first prototype. The app must support iPhone and iPad, Light and Dark appearance, provider-backed precision features later, and a strict separation between product/domain rules and vendor/persistence details.

The foundation should be easy for multiple implementation agents to follow without recreating speculative layers or coupling SwiftUI screens to services directly.

## Decision

Humay uses:

- Swift 6 with strict concurrency;
- SwiftUI for application UI;
- Clean Architecture dependency direction `App → Presentation → Domain ← Data`;
- explicit dependency injection/composition at the App boundary;
- framework-neutral Domain types where practical;
- provider/persistence implementations confined to Data;
- feature-local presentation state unless state genuinely spans routes;
- no third-party DI/navigation framework until a concrete requirement justifies one;
- no multi-package/module split merely for ceremony; package extraction is allowed later when engine/shared boundaries earn it.

The architecture is a dependency rule, not a demand for one protocol/use case per trivial operation. Abstractions are introduced when they protect a real boundary, behavior or test seam.

## Consequences

- SwiftUI views do not construct provider/persistence implementations.
- Domain models do not adopt vendor response shapes.
- Persistence entities do not leak into Presentation.
- App/composition code may know concrete implementations; feature UI should not.
- The project can remain a single app target initially while scripts/tests enforce layering.
- Future astrology engines or shared libraries can be extracted into packages without changing product-layer contracts.
- Foundation work may proceed before provider-specific architecture is complete, but it cannot invent unresolved provider/cache/entitlement semantics.
