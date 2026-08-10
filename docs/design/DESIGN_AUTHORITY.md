# Design Authority & Supersession Map

Reference map — not a product or engineering specification.

This document states which artifact governs by topic for engineering handoff. Older artifacts remain preserved and are not rewritten simply because a newer artifact supersedes part of them.

## 01 — Product Strategy

**`Product Strategy.dc.html`** remains authoritative for the core product concept. Later passes execute against it visually and structurally; none supersede its strategic intent.

## 02 — Information Architecture

Current IA:

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is reached through the header/profile entry, not as a primary navigation item.

## 03 — Core Product Screens

The visual reference for each major area is whichever pass last touched it. Earlier passes on the same area remain historical only.

- Pass 2 / Pass 3 — early screen exploration; superseded wherever Pass 4 covers the same area.
- Pass 4 — current reference for core screens (Today / Circle / Sky / Chart / Ask) except where later artifacts explicitly override a topic.
- Pass 4.1 — governs monetization-touching screens and entitlement behavior, overriding Pass 4 there only.

## 04 — Monetization

**Pass 4.1** is authoritative for the tier model:

**Free → Rewarded Access → Premium**

Rewarded entitlement rules:

- One ad unlocks one identified content item — not a session or category.
- Unlocked content stays unlocked and survives app restart.
- The same item never asks again.
- Different content may require another rewarded unlock.
- Rewarded Access is not temporary Premium and never grants Premium entitlement.
- Premium access follows the active subscription entitlement.

## 05 — Brand

**Pass 5** is historical exploration only.

**Pass 5.1 — Humay Brand Lock** is authoritative for:

- Humay
- HUMAY wordmark
- occultation mark
- app icon
- palette
- typography
- brand voice
- Roast expression
- Humay Premium naming
- launch / store / press lines
- motion
- brand misuse rules

Where Pass 5 and Pass 5.1 disagree, Pass 5.1 wins.

## 06 — Old Names

| Name | Status |
| --- | --- |
| Astara | Repository / project working name only — never surfaced to users |
| Ortus | Historical placeholder |
| Ecliptic | Rejected Pass 5 recommendation |
| Eclipse | Visual/design direction only — not the product name |
| Humay | Selected consumer brand — current |

## 07 — Astrology Data Authority

- All exact chart values, placements, aspects, timing, dashas, pillars and interpretations shown in design artifacts are prototype content unless independently validated.
- They must not become engineering fixtures.
- Deterministic calculation engines and validated outputs are the authoritative source of truth during implementation.
- Interpretation consumes structured calculated facts; it does not produce them.
- The interpretation/LLM layer must never invent positions, degrees, houses, dashas, pillars or timing.

## 08 — Known Methodology Decisions Still Open

Preserve these as unresolved; do not invent answers during handoff:

- Western composite-chart technique
- Vedic non-romantic relationship dimension set
- supported house systems
- supported ayanamsas
- Chinese calendar / BaZi convention choices
- BaZi Luck Cycle methodology and input requirements
- event-type mapping between Western / Vedic / Chinese timing concepts

## 09 — External Brand Clearance

Humay design is locked internally. The following remain external and unresolved:

- trademark
- App Store name
- Google Play title
- domains
- handles, if relevant
- cultural/linguistic review

## 10 — Next Step

**Pass 6 — Engineering Handoff & Final Design Audit.**

Not begun.
