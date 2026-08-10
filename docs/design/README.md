# Design Reference

This directory is the repository-owned source of truth for approved Humay product and UI/UX design artifacts. The repository itself still uses `Astara_iOS` as its working project name.

The broad design phase is **frozen and implementation-ready through Pass 6.1 — Final Engineering Freeze**. Some astrology methodologies remain feature-specific blockers; see [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md).

## Current structure

```text
docs/design/
  README.md
  DESIGN_AUTHORITY.md

  claude-reference/
    README.md
    Product Strategy.dc.html
    Onboarding.dc.html
    Product Design - Pass 2.dc.html
    Product Design - Pass 3.dc.html
    Product Design - Pass 4.dc.html
    Product Design - Pass 4.1 - Rewarded Access.dc.html
    Product Design - Pass 5 - Brand and Identity.dc.html
    Product Design - Pass 5.1 - Humay Brand Lock.dc.html
    Product Design - Pass 6 - Engineering Handoff and Final Audit.dc.html
    Product Design - Pass 6.1 - Final Engineering Freeze.dc.html
    Product Design - Authority Map.dc.html
    support.js
    _ds/...

  final-archive/
    README.md
    reference/*.md
    previews/...
```

Keep each original HTML artifact together with `support.js` and its referenced `_ds` assets so the exported designs remain renderable.

## Where to start

For implementation/architecture work:

1. Read [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md).
2. Use the original files in [`claude-reference/`](claude-reference/) when exact design detail or authority matters.
3. Use the [final visual archive](final-archive/README.md) for fast GitHub browsing, screenshots and concise Markdown summaries.

The final archive is **derived documentation**. It does not become a new authority layer.

## Authority summary

- `Product Strategy.dc.html` — core product concept and principles.
- `Onboarding.dc.html` — dedicated onboarding visual reference, subject to later birth-time corrections.
- Pass 4 — broad product-screen reference where later artifacts do not override it.
- Pass 4.1 — monetization-surface reference, subject to explicit Pass 6 / 6.1 corrections.
- Pass 5 — historical brand exploration.
- Pass 5.1 — Humay brand authority.
- Pass 6 — engineering-handoff and contradiction-audit record.
- Pass 6.1 — final correction/freeze layer; it wins only for scopes it explicitly supersedes.

## Source-of-truth rules

- Design artifacts are authoritative for approved UX, hierarchy, visual direction, interactions, monetization behavior, brand and product structure.
- They are **not** authoritative for astronomical or astrological calculation outputs.
- Exact placements, aspects, timing, dashas, pillars and interpretations shown in design artifacts are illustrative prototype content unless independently validated.
- Deterministic calculation engines and validated outputs provide chart facts such as planetary positions, Ascendant, houses, aspects, sidereal placements, nakshatras, dashas, BaZi pillars and timing.
- Interpretation consumes structured calculated facts and must never invent positions, degrees, houses, dashas, pillars or timing.
- Normal and Roast consume the same calculated facts and the same underlying interpretation; only expression differs.

## Final product direction

- Humay consumer brand and HUMAY wordmark
- Eclipse visual direction
- Today / Circle / Sky / Chart / Ask
- Calendar under Sky
- Profile / Settings through the header/profile entry
- native Western / Vedic / Chinese experiences without flattening their system grammar
- Compare Systems
- compatibility and Today Together
- Ask the Stars
- Normal / Roast in-app expression
- notifications always in the Normal register; the earlier notification Roast toggle is superseded
- sharing, widgets, privacy/data controls and complete product states
- Free → optional Rewarded Access → Premium

## Rewarded Access

Two rewarded entitlement shapes are approved:

1. **Persistent content unlock** — one completed rewarded ad unlocks one identified reading/section; that item stays unlocked, survives restart and never asks again.
2. **Immediate Ask extension** — one completed rewarded ad permits one additional Ask question; it is single-use and is not stored or shown as currency/balance.

Saved People capacity is **not** increased through Rewarded Access. Free has a base limit and Premium a larger limit; exact limits remain product configuration.

Rewarded ads remain voluntary and bounded. No banner, native-feed, autoplay, interstitial or launch ads are part of the approved product direction.

## Methodology status

Design/UX readiness does not mean every astrology methodology is complete.

Research/sign-off remains necessary for output-affecting methodology including:

- Western house-system strategy
- Western composite-chart technique
- Vedic non-romantic relationship dimensions
- Chinese calendar conventions
- BaZi Four Pillars conventions
- BaZi Luck Cycle / Da Yun methodology and inputs
- cross-system timing/event mapping
- Lahiri ayanamsa as a provisional Vedic default pending sign-off
- BaZi local/solar-time handling as a provisional default pending sign-off

These are feature-specific dependencies. They do not block the iOS foundation/design system or unaffected feature work.

## Brand status

Humay is internally design-locked. External clearance remains pending for trademark, App Store/Google Play naming, domains, relevant handles and cultural/linguistic review.

## Current status

**Design/UX frozen: Pass 6.1 — Final Engineering Freeze.**

The [GitHub-friendly final screenshot/Markdown archive](final-archive/README.md) is present and verified as derived documentation: 51 PNGs and 9 Markdown reference files.

One known visual exception is documented in the archive: the notification-settings screenshot predates the Pass 6 ruling and still shows the superseded Roast toggle. The final behavior remains Normal-only notifications.

Production iOS implementation has not started.

Next substantive phase: **Technical Architecture & Implementation Planning**.
