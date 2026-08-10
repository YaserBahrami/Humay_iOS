# Astara iOS — Design Reference

## Purpose

These files are the approved product and UI/UX reference for the product branded **Humay**. `Astara_iOS` remains the repository/project working name. These are reference artifacts, not production application code.

Before implementation, architecture work or any future design correction, read [`../DESIGN_AUTHORITY.md`](../DESIGN_AUTHORITY.md) for precedence and supersession rules.

## Current approved direction

- Humay consumer brand
- Eclipse visual direction
- Editorial/Classical-derived typography and hierarchy
- Today / Circle / Sky / Chart / Ask primary IA
- Calendar nested under Sky
- Profile / Settings through the header/profile entry
- Normal and Roast modes in-app
- notifications always in the Normal register
- Western / Vedic / Chinese as native independent astrology-system experiences
- Compare Systems
- Compatibility / Today Together
- Chart and Sky
- Ask the Stars
- Notifications, privacy/data controls, sharing, widgets and complete product states
- Free → optional Rewarded Access → Premium monetization hierarchy
- Rewarded ads only; no banner, native-feed, autoplay, interstitial or launch ads

## Artifact roles

**Product Strategy** → core product concept, product principles and foundational design reasoning.

**Onboarding** → onboarding and initial chart-reveal reference. Exact astrology shown inside it is prototype content, not an engineering fixture. Pass 6.1 supersedes any older assumptions about unknown-birth-time reliability.

**Pass 2** → Today, Circle and compatibility foundation; historical where later passes cover the same surface.

**Pass 3** → Chart, Sky, native astrology systems, Compare Systems and Ask the Stars; historical where later passes cover the same surface.

**Pass 4** → broad reference for product-completion screens: Calendar, Profile/Settings, notifications, privacy/data controls, saved-people management, relationship-system depth, Premium, sharing, widgets, product states and coherence review. Its Normal/Roast notification toggle is superseded by Pass 6.

**Pass 4.1 — Rewarded Access** → additive monetization reference for voluntary rewarded access, Premium coexistence, access states, ad failure/confirmation states, advertising privacy entry and the Free/Rewarded/Premium access matrix. Pass 6.1 supersedes its unresolved/older Saved People reward behavior and clarifies entitlement shapes.

**Pass 5 — Brand and Identity** → historical brand exploration. Its naming recommendation is superseded.

**Pass 5.1 — Humay Brand Lock** → authoritative brand reference for Humay, HUMAY wordmark, occultation mark, app icon, palette, typography, brand voice, Roast expression, Humay Premium naming, launch/store/press lines, motion and misuse rules. Where Pass 5 and Pass 5.1 disagree, Pass 5.1 wins.

**Pass 6 — Engineering Handoff and Final Audit** → audit record and engineering-facing handoff covering contradictions, design tokens, components, screen/navigation/state contracts, accessibility, data boundaries and implementation readiness. It resolves Roast notifications to Normal-only and replaces accidental `account` wording with `local profile`.

**Pass 6.1 — Final Engineering Freeze** → final implementation-facing correction layer. It corrects readiness wording, unknown-birth-time behavior, methodology classification, Saved People monetization, rewarded entitlement semantics and design-vs-technical-architecture boundaries; it fills the remaining handoff tables. Where Pass 6.1 explicitly supersedes an earlier rule, Pass 6.1 wins.

**Product Design — Authority Map** → historical rendered version of the authority map. The repository-owned Markdown authority map at [`../DESIGN_AUTHORITY.md`](../DESIGN_AUTHORITY.md) should be read for the current maintained precedence rules.

## Naming and brand status

- **Astara** → repository/project working name only; never a consumer-facing product name.
- **Ortus** → historical placeholder.
- **Ecliptic** → rejected Pass 5 recommendation.
- **Eclipse** → visual/design direction only, not the product name.
- **Humay** → selected consumer brand.

Humay is internally design-locked, but external clearance remains unresolved: trademark, App Store name, Google Play title, domains, relevant handles and cultural/linguistic review.

## Source-of-truth rule

Exact chart values, placements, aspects, timing, dashas, pillars and interpretations shown in design artifacts are prototype content unless independently validated. They must not become engineering fixtures merely because they appear in a design.

Deterministic calculation engines and validated outputs are authoritative for astronomical and astrological facts such as planetary positions, Ascendant, houses, aspects, sidereal placements, nakshatras, dashas, BaZi pillars and timing.

Interpretation consumes structured calculated facts; it does not produce them. The interpretation/LLM layer must never invent positions, degrees, houses, Ascendant, aspects, nakshatras, dashas, pillars or timing.

Unknown birth time degrades individual facts according to their actual uncertainty window. Pass 6.1 is authoritative for system-specific unknown-time behavior.

## Monetization rule

The approved hierarchy is **Free → optional Rewarded Access → Premium**.

### Persistent content unlock

- one completed rewarded ad unlocks one identified reading/section;
- that content stays unlocked and survives app restart;
- the same item never asks again;
- different content may require another rewarded unlock;
- Rewarded Access is not temporary Premium.

### Ask extension

- one completed rewarded ad permits one additional Ask question;
- the entitlement is single-use and consumed by that question;
- it is never represented as a bankable currency, token, credit or balance.

### Saved People

- Free has a base Saved People limit;
- Rewarded Access does not increase Saved People capacity;
- Premium has a larger limit;
- exact limits remain product configuration.

Premium follows a valid subscription entitlement and removes supported rewarded-unlock prompts. Concrete store, ad-SDK, verification, persistence and notification-delivery mechanisms belong to technical architecture, not the design contract.

## Methodology status

Output-affecting choices are methodology decisions, not ordinary engineering discretion.

Research remains required for:

- Western house-system strategy
- Western composite-chart technique
- Vedic non-romantic relationship dimension set
- Chinese calendar conventions
- BaZi Four Pillars conventions
- BaZi Luck Cycle / Da Yun methodology and input requirements
- event-type mapping between Western / Vedic / Chinese timing concepts

Provisional methodology defaults requiring sign-off before canonical production use:

- Lahiri ayanamsa for Vedic
- BaZi local/solar-time handling

Feature-specific blockers remain for Chinese/BaZi native production astrology, advanced Luck Cycles, Western composite readings, Vedic non-romantic compatibility and full Compare Systems parity where the unresolved methodology is required.

These do not block iOS foundation/design-system work or unaffected features.

## Status

**Design/UX frozen and implementation-ready through Pass 6.1 — Final Engineering Freeze.**

Production iOS implementation has not started.

Next substantive phase: **Technical Architecture & Implementation Planning**.

Updated: August 10, 2026
