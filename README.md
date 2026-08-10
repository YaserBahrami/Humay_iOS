# Astara iOS

This repository currently uses **Astara** as its project/repository working name. The selected consumer-facing brand is **Humay**.

The broad product-design phase is complete. The design/UX handoff is frozen and implementation-ready through **Pass 6.1 — Final Engineering Freeze**. Production iOS implementation has not started.

## Design reference

Original approved product/UI artifacts live under [`docs/design/claude-reference/`](docs/design/claude-reference/).

For GitHub-friendly browsing, screenshots and concise summaries, use the [Humay Final Design Archive](docs/design/final-archive/README.md).

The current product direction includes:

- Today / Circle / Sky / Chart / Ask
- Calendar nested under Sky
- Profile / Settings through the header/profile entry
- Western, Vedic and Chinese astrology as native independent systems
- Compare Systems
- Compatibility and Today Together
- Ask the Stars
- Normal and Roast in-app modes using the same underlying astrology
- notifications always written in the Normal register
- Free → optional Rewarded Access → Premium
- Humay brand identity and the Eclipse visual direction

See [`docs/design/DESIGN_AUTHORITY.md`](docs/design/DESIGN_AUTHORITY.md) for the authority and supersession rules across design passes. The screenshot/Markdown archive is derived documentation and does not replace those rules.

## Source-of-truth boundary

The design artifacts are authoritative for approved product structure, UX, visual direction, brand, interaction patterns and monetization behavior.

They are **not** authoritative for astronomical or astrological calculation outputs. Exact placements, houses, aspects, timing, dashas, pillars and related chart values shown in design artifacts are prototype content unless independently validated. Deterministic calculation engines and validated outputs are the source of truth.

The interpretation layer consumes structured calculated facts; it must not invent positions, degrees, houses, Ascendant, aspects, nakshatras, dashas, pillars or timing.

Any convention that changes calculated astrological output is a methodology/domain decision requiring validation/sign-off, not ordinary UI/engineering discretion.

## Design freeze and methodology dependencies

The design/UX handoff is implementation-ready, but several features remain blocked on methodology research/sign-off before their production astrology can ship:

- Chinese/BaZi native production astrology
- advanced BaZi Luck Cycles
- Western composite-chart readings
- Vedic non-romantic compatibility
- full Compare Systems parity where cross-system timing/event mapping is required

Lahiri ayanamsa and BaZi local/solar-time handling are provisional methodology defaults for prototyping/development only until methodology sign-off.

These items do **not** block iOS foundation/design-system work or unaffected feature development.

## Monetization

Approved hierarchy: **Free → optional Rewarded Access → Premium**.

Rewarded Access has two supported behaviors:

- a persistent per-item reading/section unlock that survives restart and never asks again for the same item;
- a single-use additional Ask question after one completed rewarded ad.

Saved People capacity is not increased through Rewarded Access. Free has a base limit and Premium a larger limit; exact values remain product configuration.

Concrete StoreKit, rewarded-ad provider, verification, storage/sync and notification-delivery mechanisms are deferred to technical architecture.

## Brand status

**Humay** is the selected consumer brand. **Eclipse** remains the visual/design direction only.

External clearance is still required for trademark risk, App Store / Google Play naming, domains, relevant handles and cultural/linguistic review.

## Status

Approved/frozen design reference: **through Pass 6.1 — Final Engineering Freeze**.

Final GitHub visual/reference archive: **present** under [`docs/design/final-archive/`](docs/design/final-archive/README.md).

Next substantive phase: **Technical Architecture & Implementation Planning**.
