# Astara iOS — Design Reference

## Purpose

These files are the approved product and UI/UX reference for the product now branded **Humay**. `Astara_iOS` remains the repository/project working name. These are reference artifacts, not production application code.

Before implementation or further design work, read [`../DESIGN_AUTHORITY.md`](../DESIGN_AUTHORITY.md) for precedence and supersession rules.

## Current approved direction

- Humay consumer brand
- Eclipse visual direction
- Editorial/Classical-derived typography and hierarchy
- Today / Circle / Sky / Chart / Ask primary IA
- Calendar nested under Sky
- Profile / Settings through the header/profile entry
- Normal and Roast modes
- Western / Vedic / Chinese as native independent astrology-system experiences
- Compare Systems
- Compatibility / Today Together
- Chart and Sky
- Ask the Stars
- Notifications, privacy/data controls, sharing, widgets and complete product states
- Free → optional Rewarded Access → Premium monetization hierarchy
- Rewarded ads only; no banner, native-feed, interstitial or launch ads in the approved product direction

## Artifact roles

**Product Strategy** → core product concept, product principles and foundational design reasoning.

**Onboarding** → onboarding and initial chart-reveal reference. Exact astrology shown inside it is prototype content, not an engineering fixture.

**Pass 2** → Today, Circle and compatibility foundation; historical where later passes cover the same surface.

**Pass 3** → Chart, Sky, native astrology systems, Compare Systems and Ask the Stars; historical where later passes cover the same surface.

**Pass 4** → current broad reference for core product screens and completion work: Calendar, Profile/Settings, notifications, privacy/data controls, saved-people management, relationship-system depth, Premium, sharing, widgets, product states and coherence review.

**Pass 4.1 — Rewarded Access** → authoritative additive monetization reference. It governs optional rewarded-ad access, Premium coexistence, entitlement states, ad failure/confirmation states, advertising privacy entry and the Free/Rewarded/Premium access matrix.

**Pass 5 — Brand and Identity** → historical brand exploration. Its naming recommendation is superseded.

**Pass 5.1 — Humay Brand Lock** → authoritative brand reference for Humay, HUMAY wordmark, occultation mark, app icon, palette, typography, brand voice, Roast expression, Humay Premium naming, launch/store/press lines, motion and misuse rules. Where Pass 5 and Pass 5.1 disagree, Pass 5.1 wins.

## Naming and brand status

- **Astara** → repository/project working name only; never a consumer-facing product name.
- **Ortus** → historical placeholder.
- **Ecliptic** → rejected Pass 5 recommendation.
- **Eclipse** → visual/design direction only, not the product name.
- **Humay** → selected consumer brand.

Humay is internally design-locked, but external clearance remains unresolved: trademark, App Store name, Google Play title, domains, relevant handles and cultural/linguistic review.

## Source-of-truth rule

Exact chart values, placements, aspects, timing, dashas, pillars and interpretations shown in design artifacts are prototype content unless independently validated. They must not become engineering fixtures.

Deterministic calculation engines and validated outputs are authoritative for astronomical and astrological facts such as planetary positions, Ascendant, houses, aspects, sidereal placements, nakshatras, dashas, BaZi pillars and transit timing.

Interpretation consumes structured calculated facts; it does not produce them. The interpretation/LLM layer must never invent positions, degrees, houses, dashas, pillars or timing.

## Monetization rule

The approved hierarchy is **Free → optional Rewarded Access → Premium**.

Rewarded Access:

- one ad unlocks one identified content item;
- unlocked content stays unlocked and survives app restart;
- the same item never asks again;
- different content may require another rewarded unlock;
- Rewarded Access is not temporary Premium.

Premium access follows the active subscription entitlement and removes rewarded-unlock prompts for supported Premium depth.

Free must remain useful. Rewarded ads are voluntary and must never autoplay or interrupt normal reading flows.

## Known unresolved methodology decisions

Do not invent answers for these during design or implementation handoff:

- Western composite-chart technique
- Vedic non-romantic relationship dimension set
- supported house systems
- supported ayanamsas
- Chinese calendar / BaZi convention choices
- BaZi Luck Cycle methodology and input requirements
- event-type mapping between Western / Vedic / Chinese timing concepts

## Status

**Approved design reference through Pass 5.1 — Humay Brand Lock. Implementation has not started.**

Next planned phase: **Pass 6 — Engineering Handoff & Final Design Audit**.

Updated: August 10, 2026
