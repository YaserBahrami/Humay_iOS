# Design Reference

This directory is the repository-owned source of truth for approved Humay product and UI/UX design artifacts. The repository itself still uses `Astara_iOS` as its working project name.

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
    support.js
    _ds/
      classical-.../
        styles.css
        _ds_bundle.js
```

Keep each HTML artifact together with `support.js` and its referenced `_ds` assets so the exported design remains renderable.

## Authority

Read [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md) before implementation or any later design pass. It defines which artifact governs when newer and older passes disagree.

Key precedence rules:

- `Product Strategy.dc.html` remains authoritative for the core product concept.
- Pass 4 is the current broad product-screen reference where later passes do not explicitly override it.
- Pass 4.1 is authoritative for monetization-touching UX and entitlement behavior.
- Pass 5 is historical brand exploration.
- Pass 5.1 is authoritative for the Humay brand system.
- Newer explicit decisions override older conflicting decisions; older artifacts remain preserved as historical reference.

## Rules

- Treat the HTML files as design/reference artifacts, not production application code.
- Preserve generated HTML instead of manually converting reference files into SwiftUI.
- Product implementation documents should link back to the relevant design artifact/section.
- The reference package is authoritative for approved UX, hierarchy, visual direction, interactions, monetization UX, brand and product structure.
- It is **not** authoritative for astronomical or astrological calculations.
- Exact placements, aspects, timing, dashas, pillars and interpretations shown in design artifacts are illustrative prototype content unless independently validated.
- Deterministic calculation engines and validated outputs must provide chart facts such as planetary positions, Ascendant, houses, aspects, sidereal placements, nakshatras, dashas, BaZi pillars and transit timing.
- The interpretation/LLM layer consumes structured calculated facts and must never invent positions, degrees, houses, dashas, pillars or timing.
- Normal and Roast must consume the same underlying calculated and interpreted astrology facts.
- Rewarded ads remain voluntary and bounded; they must not become interruptive advertising.
- One rewarded ad unlocks one identified content item. Once unlocked, that item stays unlocked, survives restart and never asks again. Rewarded Access is not temporary Premium.
- Premium access follows the active subscription entitlement.

## Current design status

The archived reference is approved through **Pass 5.1 — Humay Brand Lock**.

Current product direction includes:

- Eclipse visual direction
- Humay consumer brand and HUMAY wordmark
- Today / Circle / Sky / Chart / Ask
- Calendar under Sky
- Profile / Settings through the header/profile entry
- native Western / Vedic / Chinese experiences
- Compare Systems
- compatibility and Today Together
- Ask the Stars
- Normal / Roast
- sharing, widgets, notifications, privacy/data controls and product states
- Free → Rewarded Access → Premium

External Humay clearance remains pending for trademark, store naming, domains, relevant handles and cultural/linguistic review.

Implementation has not started.

Next planned phase: **Pass 6 — Engineering Handoff & Final Design Audit**.
