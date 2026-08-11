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

## Active blockers

None for architecture planning.

The next Claude Design pass is intentionally **after** these docs and should revise affected product/access states before feature implementation.

## Methodology blockers

See [`METHODOLOGY_TRACK.md`](METHODOLOGY_TRACK.md). Vedic/Chinese coarse Free catalogs must not be invented solely for cost symmetry; their bucket models require methodology validity.
