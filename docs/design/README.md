# Design Reference

This directory is the repository-owned source of truth for Astara product and UI/UX design artifacts.

## Current structure

```text
docs/design/
  README.md
  claude-reference/
    README.md
    Product Strategy.dc.html
    Onboarding.dc.html
    Product Design - Pass 2.dc.html
    Product Design - Pass 3.dc.html
    Product Design - Pass 4.dc.html
    Product Design - Pass 4.1 - Rewarded Access.dc.html
    support.js
    _ds/
      classical-.../
        styles.css
        _ds_bundle.js
```

Keep each HTML artifact together with `support.js` and its referenced `_ds` assets so the exported design remains renderable.

## Rules

- Treat these files as design/reference artifacts, not production application code.
- Preserve the generated HTML instead of manually converting the reference files into SwiftUI.
- Product implementation documents should link back to the relevant design artifact/section.
- The reference package is the source of truth for approved UX, hierarchy, visual direction, interactions, monetization UX and product structure.
- It is **not** the source of truth for astronomical or astrological calculations. Deterministic calculation engines must provide chart facts such as planetary positions, Ascendant, houses, aspects, sidereal placements, nakshatras, dashas, BaZi pillars, and transit timing.
- Normal and Roast modes must consume the same underlying calculated/interpreted astrology facts.
- Rewarded ads remain voluntary, bounded unlocks and must not become interruptive advertising.
- When a newer approved design pass supersedes an older one, preserve useful historical artifacts unless they are explicitly marked invalid.

## Current design status

The archived reference currently covers the approved direction through **Pass 4.1**: Eclipse, Today / Circle / Sky / Chart / Ask, native Western/Vedic/Chinese experiences, Compare Systems, compatibility/Today Together, Calendar, Profile/Settings, privacy/data controls, notifications, Premium, sharing, widgets, product states and the Free → Rewarded Access → Premium model.

Pass 4.1 is intentionally additive; it does not replace Pass 4.

Implementation has not started. Any prototype chart values inside the HTML must be independently reproduced by the production calculation layer before being used as engineering fixtures or tests.

Next planned design phase: **Pass 5 — Brand & Identity**.
