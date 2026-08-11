# Development Status

Last updated: **2026-08-11**

## Current phase

**Phase 00 — Technical Architecture & Implementation Planning**

## Current task

`ARCH-001` — finalize top-level system/deployment boundaries using the 2026-08-11 product/access decision.

## Decisions completed in this planning step

- Product/repository/internal project name is **Humay**; `Astara` is historical only.
- Free ordinary usage must not trigger paid astrology or LLM calls.
- Free daily horoscope uses finite pre-generated catalog content; Western baseline has 12 Sun-sign entries per day/variant.
- Free Western compatibility uses 12 × 12 = 144 coarse sign-pair catalog keys.
- No Free natal chart calculation.
- Personalized/precision features are Rewarded Access or Premium.
- Precision path is cache-first and server-side; initial provider direction is Astrologer API for structured facts + DeepSeek V4 Flash for interpretation.
- One rewarded completion authorizes one provider-backed generation for the selected result key; the successful result is cached/reopenable.
- Pass 6.1 remains the visual/IA baseline, but affected access/monetization surfaces require a new Claude Design revision.

## Next architecture tasks

1. `ARCH-001` — document exact on-device/backend/provider data flow and failure boundaries.
2. `ARCH-003` — freeze calculation-provider adapter/output contract and validation strategy.
3. `ARCH-004` — define local + backend cache identity, TTL/retention and offline behavior.
4. `ARCH-005` — define DeepSeek interpretation contract, prompt/version provenance and Normal/Roast separation.
5. `ARCH-006` — define Free catalog generation, review, publication and edge-cache/versioning pipeline.
6. `ARCH-007` — define rewarded one-generation entitlement, Premium access and provider-failure recovery.
7. `ARCH-008` — privacy/security boundary for birth/saved-person data sent to providers.

## Parallel track — Phase 01M

**Complete.** A mock-first iOS application exists: it builds, launches, and every major flow is navigable over fixture content. Recorded as `DEV-001` in [`DEVIATIONS.md`](DEVIATIONS.md), with tasks and outcome in [`phases/01M-mock-first-app.md`](phases/01M-mock-first-app.md). Architecture is documented under [`../architecture/`](../architecture/).

Every task is `DONE`, including `IOS-010` (accessibility), closed on 2026-08-11 by `IOS-012` — a visual reconciliation of the implementation against the minimal design direction plus the remaining Dynamic Type sweep. That pass added no product feature and changed no architectural boundary. Screenshots of the result are in [`../design/review/`](../design/review/README.md), and the direction they were checked against is now written down in [`../design/MINIMAL_DESIGN_DIRECTION.md`](../design/MINIMAL_DESIGN_DIRECTION.md).

**This is the first stable UI baseline.** The next substantive step on this track is replacing mocks with real services — and it has not started.

Phase 00 remains **IN PROGRESS**. Phase 01M does not complete it, does not satisfy Phase 01 exit criteria, and advances no `ARCH-###` or feature task. Every astrological value in that application is mock fixture content, marked as such at the type level and asserted by test.

Decisions taken for that track and now binding on implementation:

- Bundle identifier `online.humay.ios` — permanent; product domain humay.online.
- Minimum deployment target iOS 18.0; V1 targets iPhone in portrait. iPad is a planned dedicated phase.
- Persistence is SwiftData with a `VersionedSchema` from V1 and a `SchemaMigrationPlan` established from the outset.
- Visual authority is the minimal Humay direction — [`../design/MINIMAL_DESIGN_DIRECTION.md`](../design/MINIMAL_DESIGN_DIRECTION.md), summarised in [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md) §03A for the All-Paper, typography and device-scope locks.
- Dynamic Type ceilings are staggered per type role rather than flat, so the reading hierarchy survives the accessibility sizes. Row titles are uncapped; a row reflows into a stack rather than shrinking its text.
- Normal/Roast tone is set in Settings and the header chip, not during onboarding.
- Compatibility uses four qualitative axes — Love & Chemistry, Communication, Emotional Connection, Conflict & Pace — with verdicts Strong / Balanced / Mixed / Friction. No score or percentage.
- Swift 6 with `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated`; isolation is declared where it is needed rather than defaulted.
- `UIDesignRequiresCompatibility` is set, opting out of the iOS 26 system appearance. Transitional — see [`../architecture/IOS_ARCHITECTURE.md`](../architecture/IOS_ARCHITECTURE.md).

## Active blockers

None for architecture planning.

The next Claude Design pass is intentionally **after** these docs and should revise affected product/access states before feature implementation.

## Methodology blockers

See [`METHODOLOGY_TRACK.md`](METHODOLOGY_TRACK.md). Vedic/Chinese coarse Free catalogs must not be invented solely for cost symmetry; their bucket models require methodology validity.
