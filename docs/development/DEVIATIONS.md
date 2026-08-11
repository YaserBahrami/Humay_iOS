# Deviations

This file records deliberate departures from the documented development process. Every entry states what rule was set aside, who directed it, what is *not* satisfied as a result, what compensating controls exist, and the condition under which the deviation closes.

A deviation recorded here is not an amendment. The original rule still stands for every purpose except the scope named below.

---

## DEV-001 — Mock-first iOS implementation ahead of Phase 00 exit

**Status:** OPEN
**Opened:** 2026-08-11
**Directed by:** product owner, explicitly, with the constraints reproduced below.

### What the process says

- [`ROADMAP.md`](ROADMAP.md) — "Phase 00 must freeze the system boundary before production feature code starts."
- [`phases/00-technical-architecture.md`](phases/00-technical-architecture.md) — "No production feature implementation starts against stale monetization/access design." `ARCH-010` allows `STATUS.md` to advance to `IOS-001` only after the Claude Design revision is reconciled.
- [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md) — Pass 6.1 is not implementation-final for access/monetization/personalization states; Chart, Today, Compatibility, Ask and the paywall/rewarded/cached-result states require a new design revision first.

Phase 00 is still `IN PROGRESS`. `ARCH-001` through `ARCH-010` are open.

### What was directed instead

Build a first working iOS application now, using **mock/local data only**, to establish architecture, navigation, a reusable design system, all major screens, realistic mock content and complete primary user flows — a foundation that real services plug into later.

Explicitly excluded from this track: astrology calculation APIs, LLM/AI providers, backend services, authentication, StoreKit/subscriptions, advertisements, analytics.

### What this track does NOT satisfy

- **Phase 00 is not complete.** No `ARCH-###` task is advanced by this work. The provider adapter contract, cache identity, interpretation contract, catalog pipeline, entitlement model and privacy boundary remain undefined.
- **Phase 01 exit criteria are not met.** `IOS-001`–`IOS-007` acceptance depends on `IOS_ARCHITECTURE.md` and `DATA_MODEL.md`, and on access-state primitives that require the reconciled design revision. The mock track writes the first two of those documents but does not deliver the access-state primitives, because monetization is out of scope here.
- **No feature task is DONE.** `TODAY-001`, `CHART-002`, `CIRCLE-004`, `ASK-003` and every other feature task in [`phases/`](phases/) remain at their recorded status. Marking a feature complete against mock data is precisely what [`TASK_CONVENTIONS.md`](TASK_CONVENTIONS.md) forbids ("never mark methodology-dependent behavior complete using placeholder calculations"). Mock-track work carries its own IDs in [`phases/01M-mock-first-app.md`](phases/01M-mock-first-app.md).
- **No astrological value in the app is calculated.** Every placement, degree, aspect, pillar, dasha, moon phase and transit shown is illustrative fixture content transcribed from the design prototype.
- **Methodology blockers are unaffected.** Vedic ayanamsa and BaZi day-boundary conventions remain unvalidated. Where the design already says "methodology pending" — the BaZi Luck Cycle direction — the app renders `FactValue.unavailable(.methodologyPending(...))` rather than a value.

### Compensating controls

1. **`ContentProvenance` is non-optional on every content-bearing domain type.** A reading, chart, event or answer cannot be constructed without declaring where it came from. Mock services emit `.mockFixture(fixtureID:)`; the `.calculated(engine:methodologyVersion:)` case exists but has no producer in this track.
2. **`MockProvenanceTests`** calls every method of every mock service and asserts `provenance.isMock` on every returned value. A new mock that forgets provenance fails the suite.
3. **Runtime marking.** In DEBUG builds a `SAMPLE` kicker renders beside any basis line whose provenance is mock.
4. **File-level containment.** All fixture content lives under `Humay/Resources/MockContent/` with its own README stating the rule. `Scripts/check-layering.sh` fails if anything outside `Humay/Data/Mock/` reads that directory.
5. **Zero provider surface in the tree.** No networking code, no HTTP client, no StoreKit import, no ad SDK, no analytics SDK, no API key handling. There is nothing to accidentally call.
6. **No stub entitlement system.** Precise readings are directly reachable. There is deliberately no `hasEntitlement` flag, no simulated ad, and no fake paywall — a stub access model would accrete an architecture that `ARCH-007` would then have to delete.
7. **`FactValue<T>`** makes unknown birth time and pending methodology explicit at the type level rather than substituting defaults.

### Exit condition

This deviation closes when Phase 00 completes and the reconciled design revision lands. At that point:

- `Humay/Data/Mock/` is **replaced**, not extended. New feature work goes behind the real service implementations.
- Access-state primitives are built against `ARCH-007`, not retrofitted onto this track.
- Screens affected by the design revision (Today, Chart, Compatibility, Ask) are re-reviewed against it before their feature tasks can be marked DONE.

### Notes

The mock track also carries three deliberate visual divergences from the frozen design archive, recorded separately in [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md): the All-Paper surface model, the Cormorant + system-font typography lock, and iPhone-only V1 scope.
