# Astara iOS

This repository currently uses **Astara** as its project/repository working name. The selected consumer-facing brand is **Humay**.

The repository is still in the design and engineering-handoff stage; production iOS implementation has not started.

## Design reference

Approved product and UI/UX artifacts live under `docs/design/claude-reference/`.

The current product direction includes:

- Today / Circle / Sky / Chart / Ask
- Calendar nested under Sky
- Profile / Settings through the header/profile entry
- Western, Vedic and Chinese astrology as native independent systems
- Compare Systems
- Compatibility and Today Together
- Ask the Stars
- Normal and Roast modes using the same underlying astrology
- Free → optional Rewarded Access → Premium
- Humay brand identity and the Eclipse visual direction

See [`docs/design/DESIGN_AUTHORITY.md`](docs/design/DESIGN_AUTHORITY.md) for the current authority and supersession rules across design passes.

## Source-of-truth boundary

The design artifacts are authoritative for approved product structure, UX, visual direction, brand, interaction patterns and monetization UX.

They are **not** authoritative for astronomical or astrological calculations. Exact placements, houses, aspects, timing, dashas, pillars and related chart values shown in design artifacts are prototype content unless independently validated. Production calculation engines and validated outputs are the source of truth.

The interpretation layer consumes structured calculated facts; it must not invent positions, degrees, houses, dashas, pillars or timing.

## Brand status

**Humay** is the selected consumer brand. **Eclipse** remains the visual/design direction only.

External clearance is still required for trademark risk, App Store / Google Play naming, domains, relevant handles and cultural/linguistic review.

## Status

Approved design reference: **through Pass 5.1 — Humay Brand Lock**.

Next planned phase: **Pass 6 — Engineering Handoff & Final Design Audit**.
