# Design Authority & Supersession Map

Reference map — not a product or technical-architecture specification.

This document states which artifact governs by topic for engineering handoff. Older artifacts remain preserved as historical references. Newer explicit decisions override older conflicting decisions only within the scope they address.

## 01 — Product Strategy

**`Product Strategy.dc.html`** remains authoritative for the core product concept and product principles.

Later passes execute against that strategy; they do not replace its strategic intent unless this map explicitly says otherwise.

## 02 — Information Architecture

Current primary IA is locked:

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is reached through the header/profile entry.
- Profile / Settings is not a sixth primary tab.

Pass 6 confirmed that no implementation-blocking contradiction exists against this structure.

## 03 — Core Product Screens

Use the latest applicable artifact for each surface:

- **Onboarding** — `Onboarding.dc.html`, with Pass 6.1 rules overriding it where birth-time uncertainty or later handoff contracts conflict.
- **Pass 2 / Pass 3** — foundational Today, Circle, compatibility, Chart, Sky, native-system, Compare Systems and Ask exploration; historical where later passes cover the same surface.
- **Pass 4** — current broad product-screen reference for completion work where no later artifact overrides the topic.
- **Pass 4.1** — monetization-touching UX and access-state reference, subject to the Pass 6 / Pass 6.1 corrections below.
- **Pass 6** — engineering handoff and contradiction-audit record.
- **Pass 6.1** — final implementation-facing correction/freeze layer. Where Pass 6.1 explicitly supersedes Pass 6 or an earlier artifact, Pass 6.1 wins.

## 04 — Monetization

The product hierarchy remains:

**Free → Rewarded Access → Premium**

### Persistent rewarded content unlock

For bounded reading/content depth:

- one completed rewarded ad unlocks one identified reading or section;
- that content stays unlocked;
- the unlock survives app restart;
- the same content item never asks again;
- different content may require another rewarded unlock;
- Rewarded Access is not temporary Premium.

### Ask rewarded extension

Ask uses a separate approved entitlement shape:

- one completed rewarded ad permits one additional Ask question;
- the entitlement is single-use and consumed by that question;
- it is not a visible or bankable balance, coin, credit, token or currency system.

### Saved People

Pass 4.1 left rewarded Saved People capacity under review. Pass 6 temporarily approved `+1 slot per ad`; Pass 6.1 explicitly reverses that Pass 6 decision:

- Free has a base Saved People limit;
- Rewarded Access is **not** used to increase Saved People capacity;
- Premium has a larger Saved People limit;
- exact numeric limits remain product configuration.

### Premium

- Premium access follows a valid subscription entitlement.
- Premium is not described as permanent.
- Concrete subscription/store implementation is a technical-architecture decision, not a design decision.

## 05 — Brand

**Pass 5** is historical exploration only.

**Pass 5.1 — Humay Brand Lock** is authoritative for:

- Humay consumer name;
- HUMAY wordmark;
- occultation mark;
- app icon;
- palette;
- typography;
- brand voice;
- Roast expression;
- Humay Premium naming;
- launch / store / press lines;
- motion principles;
- brand misuse rules.

Where Pass 5 and Pass 5.1 disagree, Pass 5.1 wins.

## 06 — Roast and Notifications

Pass 6 resolves the Pass 4 / Pass 5.1 conflict:

- Roast is an in-app expression only.
- Push notifications are always written in the Normal register.
- The old Pass 4 Normal/Roast notification toggle is superseded and must not be implemented.
- Normal and Roast consume the same calculated astrology facts and the same underlying interpretation; only expression changes.

## 07 — Old Names

| Name | Status |
| --- | --- |
| Astara | Repository / project working name only — never surfaced to users |
| Ortus | Historical placeholder |
| Ecliptic | Rejected Pass 5 recommendation |
| Eclipse | Visual/design direction only — not the product name |
| Humay | Selected consumer brand — current |

## 08 — Astrology Data Authority

- All exact chart values, placements, aspects, timing, dashas, pillars and interpretations shown in design artifacts are prototype content unless independently validated.
- Design-artifact values must not become engineering fixtures merely because they appear in a mockup.
- Deterministic calculation engines and validated outputs are authoritative for astronomical and astrological facts.
- Interpretation consumes structured calculated facts; it does not produce them.
- The interpretation/LLM layer must never invent positions, degrees, houses, Ascendant, aspects, nakshatras, dashas, pillars or timing.
- Presentation controls how facts and interpretations are shown, not what the calculated facts are.
- Exact clock times appear only when deterministically calculated.

## 09 — Unknown Birth Time

Pass 6.1 supersedes Pass 6 §06.

General rule: unknown birth time degrades individual calculated facts according to the actual uncertainty window; it does not automatically invalidate the entire chart and it does not make uncertain facts reliable by assumption.

- **Western:** Rising sign and houses are unavailable/unreliable without sufficient time. Moon sign/degree and Moon-dependent aspects can also be uncertain when the possible birth-time window crosses a relevant boundary.
- **Vedic:** Lagna/Bhavas depend on time. Nakshatra and Moon-dependent timing use the actual Moon uncertainty window. Vimshottari timing remains classified as Reliable / Approximate / Unavailable as appropriate.
- **Chinese/BaZi:** Hour Pillar is unavailable without birth time. Year/Month/Day Pillar availability depends on the validated calendar/day-boundary convention and the user's uncertainty window; Day Pillar is not assumed universally reliable while methodology remains unresolved.

## 10 — Methodology Status

Any choice that changes calculated astrological output is a methodology/domain decision requiring validation/sign-off, not ordinary UI/engineering discretion.

### Research required before the affected production feature ships

- supported Western house-system strategy;
- Western composite-chart technique;
- Vedic non-romantic relationship dimension set;
- Chinese calendar conventions;
- BaZi Four Pillars conventions;
- BaZi Luck Cycle / Da Yun methodology and input requirements;
- event-type mapping between Western / Vedic / Chinese timing concepts.

### Provisional methodology defaults requiring sign-off

- Lahiri ayanamsa for Vedic;
- local/solar-time handling for BaZi.

These defaults may be used for prototyping/development but must not be treated as canonical production methodology without sign-off.

### Feature-specific blockers

The design/UX handoff is implementation-ready, but the following features remain methodology-blocked:

- Chinese/BaZi native production astrology;
- advanced BaZi Luck Cycles;
- Western composite-chart readings;
- Vedic non-romantic compatibility;
- full Compare Systems parity where cross-system timing-event mapping is required.

These do not block the iOS foundation/design system or unaffected feature work.

## 11 — Design vs Technical Architecture

Pass 6.1 explicitly separates behavioral design contracts from implementation mechanics.

Design locks behavior such as:

- Premium reflects valid subscription entitlement;
- successful rewarded completion grants the approved reward shape;
- persistent content unlocks survive restart and remain unlocked for that item;
- notification content follows Humay rules;
- no login/account infrastructure is assumed by design.

Technical architecture will decide:

- exact StoreKit/API implementation and product configuration;
- rewarded-ad provider/SDK;
- reward verification strategy;
- persistence and sync mechanics;
- local vs remote notification architecture;
- backend/storage details.

## 12 — External Brand Clearance

Humay is internally design-locked. The following remain external and unresolved:

- trademark;
- App Store name;
- Google Play title;
- domains;
- handles, if relevant;
- cultural/linguistic review.

These do not block design or foundation engineering, but they must be resolved before public launch/brand commitment where applicable.

## 13 — Current Status

**Design/UX is frozen and implementation-ready as of Pass 6.1 — Final Engineering Freeze.**

Pass 6 remains the audit record. Pass 6.1 is the final correction layer and supersedes only the portions it explicitly identifies.

No Pass 6.2 is planned.

## 14 — Derived GitHub Archive

[`final-archive/`](final-archive/README.md) contains the frozen design's GitHub-friendly screenshots and Markdown summaries.

- 51 PNG files and 9 Markdown reference files were added from the final export.
- The archive is **derived documentation only** and never supersedes this authority map or the applicable `.dc.html` source artifact.
- `final-archive/previews/settings/settings-03-notifications.png` is a known pre-freeze visual exception: it still shows the old notification Roast control. The final implementation rule remains **Normal-only notifications with no Roast toggle**.
- Methodology-blocked screenshots remain visual/product references only; their sample astrology does not validate methodology or calculation output.

## 15 — Next Step

**Technical Architecture & Implementation Planning**, followed by iOS foundation implementation.
