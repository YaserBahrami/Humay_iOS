# Humay Design Authority

**Status:** Current and exclusive design authority
**Effective:** 2026-08-19
**Repository authority:** `main`

`main` contains one current design program only. Temporary feature/design branches must merge back here and must not become separate authorities.

## 1. Authority order

For implementation, use this order:

1. [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md) — access/cost behavior.
2. This document — design authority and non-negotiable product/device constraints.
3. [`PREMIUM_CELESTIAL_REDESIGN.md`](PREMIUM_CELESTIAL_REDESIGN.md) — current post-onboarding visual language, information architecture, tokens, components, and implementation record.
4. [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md) — screen inventory and propagation sequencing.
5. Approved references under [`soulful-reference/`](soulful-reference/README.md) only where the premium redesign has not superseded their visual treatment.
6. [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md) — legacy reference plus retained D1 onboarding authority.
7. [`../development/METHODOLOGY_TRACK.md`](../development/METHODOLOGY_TRACK.md) — methodology gates for real astrology output.

If a mockup conflicts with product access, methodology, device behavior or accessibility, the mockup is corrected.

## 2. Canonical information architecture

Primary navigation is:

**Today / Chart / Explore / Connections / You**

- Current Sky, Calendar, and Ask are reached through Explore.
- Circle/people and Compatibility are reached through Connections.
- Profile, birth details, preferences, access, and settings are reached through You.
- Existing internal feature/domain names such as `Circle`, `Sky`, and `Ask` remain valid implementation names.
- Reference screenshots with the former tab labels are historical and do not redefine IA.

## 3. Current visual direction

The selected post-onboarding Humay style is **Premium Celestial**:

- warm ivory/parchment Light mode and midnight/obsidian Dark mode;
- large editorial typography with clean system UI and monospaced technical roles;
- restrained celestial gold plus quiet indigo support accents;
- extremely thin orbital geometry, generous space, and minimal card chrome;
- Huma identity expressed only through approved production vector assets; no approximate bird, wing, feather, or orbital stand-in;
- modern Apple-platform hierarchy first, Persian celestial heritage second, Huma mythology third;
- intentional Light and Dark composition rather than color inversion.

[`PREMIUM_CELESTIAL_REDESIGN.md`](PREMIUM_CELESTIAL_REDESIGN.md) defines the post-onboarding visual source of truth. The approved D1 onboarding package remains authoritative for onboarding until that family receives its own migration phase. Older post-onboarding references retain behavioral and state value but no longer override Premium Celestial styling.

The old Paper/minimal direction and painterly/watercolor explorations are superseded and must not be used for implementation.

## 4. Appearance requirement

Every shipping screen requires deliberate Light and Dark treatment. Dark mode is not inversion: it uses midnight grounds, tonal card elevation, warm light text and slightly brighter accents.

The application follows the system appearance by default. Do not hard-force Light or Dark globally.

## 5. Device requirement — iPhone + iPad

**iPhone and iPad are first-class shipping platforms from this baseline forward.**

Every approved screen family must account for:

- iPhone portrait;
- iPad portrait;
- iPad landscape;
- compact and regular horizontal size classes where they materially change composition;
- split-view / reduced iPad window widths where the layout can encounter them.

A phone layout must not simply be stretched across an iPad canvas. iPad should use width deliberately: bounded reading columns, side-by-side regions where useful, larger art only when it improves hierarchy, and stable navigation behavior.

### Design-reference minimum

Before a screen is considered ready for final visual implementation, the repository must contain:

1. iPhone Light reference;
2. iPhone Dark reference;
3. iPad Light reference;
4. iPad Dark reference;
5. notes for iPad landscape/adaptive behavior if the static portrait reference is insufficient.

Existing D0 references remain historical behavior/state evidence where Premium Celestial has superseded their styling. The complete D1 cross-device package was approved on 2026-08-12 and remains the production onboarding implementation authority.

## 6. Typography

- **Cormorant Garamond** — Humay wordmark only.
- **Newsreader** — semantic editorial/display roles, including hero and editorial titles, onboarding card titles, card titles and expressive scores.
- **SF Pro / system** — body copy, event titles, controls, navigation, forms, settings, dates and times; use monospaced digits where alignment helps.
- **SF Mono / system** — reserved for genuinely technical future Chart values such as coordinates or degree-heavy data.

Humay-owned production text must use semantic `HumayTypography` roles; direct custom-font selection in feature views is prohibited.

Dynamic Type is mandatory. iPad does not justify fixed text sizes or oversized empty layouts.

## 7. Illustration and visual intensity

- **Level A:** at most one approved bundled production vector composition on a selected emotional hero.
- **Level B:** one semantically correct bundled vector glyph or SF Symbol for a meaningful feature group.
- **Level C:** quiet native utility surfaces for forms, settings, and dense technical data.

SwiftUI `Shape`, custom `Path`, `Canvas`, Bézier construction, and primitive geometry must never create icons, illustrations, brand art, astrology symbols, or decorative celestial motifs. They remain valid only for geometry derived from real application data. Follow the complete Asset & Iconography Authority in [`PREMIUM_CELESTIAL_REDESIGN.md`](PREMIUM_CELESTIAL_REDESIGN.md) and the ledger in [`ASSET_INVENTORY.md`](ASSET_INVENTORY.md). Avoid cute celestial characters, chibi, 3D emoji, sticker density, painterly landscapes, thick cartoon outlines, stock zodiac art, and generic purple-neon galaxy styling.

## 8. Product and astrology boundaries

User-facing access remains **Free → optional Rewarded Access → Premium**. Design cannot redefine entitlement behavior.

Mock dates, signs, scores and readings in visual references are illustrative. Production placements, houses, aspects, timing, dashas, pillars and relationship facts require validated structured calculation/provider data. Unknown birth time is never replaced with a hidden fake time.

## 9. Roast and notifications

- Roast changes expression, not calculated facts.
- Roast is an in-app register.
- Notifications remain Normal-register copy unless product policy is explicitly changed.

## 10. Accessibility and input

- minimum 44 pt hit targets;
- Dynamic Type through accessibility sizes;
- VoiceOver labels for meaningful non-text UI;
- Light/Dark contrast checked separately;
- color is never the only carrier of meaning;
- Reduce Motion respected;
- iPad pointer/keyboard behavior must remain functional where native controls provide it.

## 11. Current implementation status

The old mock-first Presentation, DesignSystem and mock provider implementation were removed on 2026-08-12 before production UI implementation. The Xcode/project foundation was retained and now targets iPhone + iPad.

Production implementation proceeds only from approved repository references, family by family.

D2 Compatibility received a later approved refinement on 2026-08-13. The package under [`soulful-reference/today-circle/compatibility-refresh/`](soulful-reference/today-circle/compatibility-refresh/README.md) supersedes only the Compatibility person-selection and result-hero portions of the older D2 reference. Production authority is implemented in `Humay/Presentation/Circle/CompatibilitySelectionView.swift` and `Humay/Presentation/Circle/CompatibilityView.swift`; reconciliation evidence is under [`implementation-evidence/d2-today-circle/compatibility-refresh/`](implementation-evidence/d2-today-circle/compatibility-refresh/README.md).

## 12. Current design status

- **D0:** approved iPhone Light/Dark style anchors; iPad companions remain a later D0 task.
- **D1:** approved cross-device on 2026-08-12 for Welcome, Birth Date, Tradition and Profile Reveal; production UI is implemented under `Humay/Presentation/Onboarding/`.
- **D2 Compatibility refinement:** approved, implemented and reconciled on 2026-08-13 for Compatibility person selection, Pair Composer, compact one-column rows, iPad two-region selection, Relationship Field, pair identity/connector, score/label/summary composition, Free/Precise disclosure placement, and represented adaptive/accessibility behavior. Unrelated D2 surfaces retain their existing authority status.
- **D3.1 Current Sky:** Lunar Meridian under `soulful-reference/sky/current-sky/` remains historical authority for unaffected behavior and semantics. The approved [`refinement-r1/`](soulful-reference/sky/refinement-r1/README.md) package supersedes its hero composition, event density, authored illustration, typography treatment, and floating-tab clearance. `SKY-003` is implemented over the Debug-only sample; production data work remains tracked by `SKY-002`.
- **D3.2 Calendar Month + Week:** Meridian Almanac under `soulful-reference/sky/calendar/` remains historical authority for unaffected behavior and semantics. The approved [`refinement-r1/`](soulful-reference/sky/refinement-r1/README.md) package supersedes its Month density/date states, Week rail treatment, typography treatment, and floating-tab clearance. `SKY-004` is implemented over the Debug-only sample.
- **D3.3 Event Detail:** Celestial editorial sheet is the approved cross-device visual reference package under `soulful-reference/sky/event-detail/`, approved on 2026-08-13. Approval covers iPhone/iPad Light/Dark, state and stress boards, adaptive/accessibility guidance, origin-aware native navigation, Sky root shell behavior, factual versus interpretive hierarchy, timing/methodology treatment, and observation context. `SKY-005` is implemented and reconciled over the Debug-only sample; approval does not complete production `SKY-002` or methodology `SKY-006`.
- **D4.1 Chart foundation:** approved on 2026-08-14. The package under [`soulful-reference/chart/foundation/`](soulful-reference/chart/foundation/README.md) is implemented and reconciled for Chart root/Free entry, typed state surfaces, Western known-time development fixture, data-driven wheel/list, Moon Placement Detail, unknown birth-time handling and iPhone/iPad adaptive composition. Evidence is under [`implementation-evidence/d4-chart/`](implementation-evidence/d4-chart/README.md). This approval does not complete production `CHART-002`, `ASTRO-003`, access/cache/entitlement work or methodology gates.
- **D5.1 Ask foundation:** approved on 2026-08-14 for the UI-first Ask presentation slice and implemented as the core UI-first baseline. Entry is reconciled with the approved two-region regular-width iPad composition; regular-width iPad Answer currently preserves bounded reading width without the approved contextual question/basis rail, tracked as an explicit R2 visual-refinement item. This does not block the D5 contract freeze. The package under [`soulful-reference/ask/foundation/`](soulful-reference/ask/foundation/README.md) governs the iPhone/iPad Light/Dark entry, access, generating, answer and offline-cached compositions, typed Humay-owned presentation states, relevant-context disclosure, safety/unsupported/error surfaces and Debug-only sample boundary. Evidence is under [`implementation-evidence/d5-ask/`](implementation-evidence/d5-ask/README.md). This approval does not complete provider/backend/API, rewarded access, Premium/StoreKit, production cache/history/memory or astrology methodology work.

Current D1 implementation evidence lives under `implementation-evidence/d1-onboarding/`. The reconciled Current Sky and Calendar R1 evidence lives under [`implementation-evidence/d3-sky-calendar/refinement-r1/`](implementation-evidence/d3-sky-calendar/refinement-r1/README.md). D4 evidence lives under [`implementation-evidence/d4-chart/`](implementation-evidence/d4-chart/README.md). Completion is in-memory only until PROFILE-005; no provider-backed astrology is used by Profile Reveal or D4 sample UI.
- Remaining families follow [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md).

No alternate design authority should be added alongside this one.
