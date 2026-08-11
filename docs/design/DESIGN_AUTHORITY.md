# Design Authority & Supersession Map

This map defines which artifacts govern Humay implementation. Historical Claude/minimal artifacts remain preserved for product history and useful interaction/accessibility detail, but the approved 2026-08-12 redesign is the current visual authority.

## 01 — Current authority order

For implementation, use this order:

1. Current explicit product/access decisions in [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md).
2. This authority map for supersession rules.
3. **[`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)** for visual language, Light/Dark behavior, illustration, color, surface and hierarchy decisions.
4. **[`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md)** for screen-family coverage and visual-freeze sequencing.
5. Approved paired references in [`soulful-reference/`](soulful-reference/README.md) for concrete screen composition.
6. Pass 7 / Pass 6.1 / the historical final archive for feature structure, interaction and copy only where newer authority does not supersede them.
7. Older Claude passes and `MINIMAL_DESIGN_DIRECTION.md` for historical reference only.

Where a newer approved soulful reference conflicts visually with an older artifact, the soulful reference wins. Product/access rules and validated methodology still override illustrative mockup content.

## 02 — Canonical information architecture

Current primary IA remains:

**Today / Circle / Sky / Chart / Ask**

- Calendar is nested under Sky.
- Profile / Settings is reached through the header/profile entry.
- Profile / Settings is not a sixth primary tab.
- Compatibility is reached from Circle/people flows.

Some 2026-08-12 visual explorations show temporary tabs such as `Compatibility` or `Library`. Those are **style explorations only** and do not change the canonical IA.

## 03 — Current visual direction

The previous minimal direction is superseded for appearance and layout styling by [`SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](SOULFUL_CELESTIAL_DESIGN_DIRECTION.md).

The current direction is **soulful celestial**:

- warm, alive and emotionally inviting;
- colorful with disciplined accent use;
- painterly gouache/watercolor celestial illustrations;
- premium editorial typography;
- rounded/tinted feature cards and controlled elevation;
- cute in selected moments without becoming childish or mascot-driven;
- explicit visual-intensity levels so utility screens remain calm;
- first-class Light and Dark designs.

Humay should feel like storybook-quality celestial art inside a polished modern iOS product, not like a sterile utility and not like a cartoon astrology game.

## 03A — Light + Dark lock

**Both appearances are required.** A screen family is not visually frozen until its Light and Dark references are approved.

Dark mode is a separate composition/color translation, not a global inversion of Light mode. It uses a midnight-navy ground, warm-ivory text and intentionally rebalanced accent surfaces while preserving the color identity of celestial illustrations.

Initial D0 Dark anchor translations may be used to establish direction. They must be refined deliberately before becoming per-pixel implementation authority.

## 03B — Typography

Typography remains:

- **Cormorant Garamond** — Humay wordmark, major titles, expressive editorial headlines and selected large scores.
- **SF Pro (system)** — body copy, navigation, buttons, forms, settings and general UI.
- **SF Mono (system)** — degrees, coordinates, technical dates/times and chart data where mono improves scanning.

The new direction permits more expressive scale/italic use than the minimal baseline, but Dynamic Type and semantic hierarchy remain mandatory.

## 03C — Illustration authority

Approved visual language:

- painterly gouache/watercolor celestial landscapes;
- warm sun/moon expression used selectively;
- tasteful botanical/cosmic mini-illustrations;
- semi-real editorial portraits where relationship/person context benefits;
- restrained orbit lines, stars and constellations.

Avoid unrelated illustration styles, sticker density, chibi/3D emoji treatment, thick cartoon outlines and generic purple-neon galaxy treatment.

Reference art under `soulful-reference/assets/` is design reference until explicitly promoted into `Humay/Resources/Assets.xcassets/` as optimized production artwork.

## 03D — Useful rules retained from the minimal implementation

The minimal visual appearance is superseded, but these implementation/accessibility lessons remain binding unless a newer screen contract changes them:

- one reusable page/scaffold approach should prevent gutter/inset drift;
- Dynamic Type role ceilings must preserve hierarchy;
- rows reflow rather than shrink text to fit;
- fixed-geometry drawings step aside when accessibility sizes require it;
- withheld/unknown values must remain semantically clear rather than replaced with fake precision;
- no hard-coded device dimensions; use semantic layout tokens and responsive visualizations.

## 04 — Product access model

The hierarchy remains:

**Free → optional Rewarded Access → Premium**

The exact runtime/cost behavior is defined in [`../development/PRODUCT_ACCESS_MODEL.md`](../development/PRODUCT_ACCESS_MODEL.md). Visual redesign may improve presentation but may not redefine entitlement semantics.

### Free

- Ordinary Free runtime usage must not call a paid astrology or LLM provider.
- Free daily horoscope is a coarse, pre-generated catalog experience based on supported finite buckets.
- Western baseline uses 12 Sun-sign daily entries.
- Free Western compatibility uses 12 × 12 = 144 pre-generated sign-pair keys.
- Free has no natal-chart calculation.

### Rewarded Access

- One completed rewarded ad authorizes one needed provider-backed generation for the selected feature/result key.
- Cache is checked before ad/provider generation.
- Successfully generated results are cached/reopenable according to the access/cache contract.
- Rewarded Access is not a token/coin wallet and not temporary Premium.
- Provider failure after ad completion requires fair idempotent recovery.

### Premium

- Premium provides included provider-backed personalized/precision features while entitlement is valid.
- Premium remains cache-first.
- Premium avoids the per-generation rewarded-ad requirement for included features.

## 05 — Compatibility score presentation

The new compatibility direction approves **numeric score presentation** as a UI pattern:

- an overall compatibility percentage/score may be shown;
- dimensions may also show percentages/scores;
- qualitative explanation must accompany the numbers so the feature does not reduce the relationship to a game score.

This supersedes the older visual rule that prohibited percentages.

However, the mockup values (for example `82%`) are illustrative. Production scoring algorithm, weights, confidence and cross-system semantics remain methodology/product decisions. Design approval does not validate an astrology formula.

## 06 — Roast and notifications

- Roast is an in-app expression only.
- Push notifications are always Normal-register copy.
- Normal and Roast consume the same astrology facts; tone must not alter calculated meaning.
- Do not implement the historical Normal/Roast notification toggle.

The redesign may make Roast visually playful, but it must remain readable and must not change underlying facts.

## 07 — Astrology data authority

### Free catalog

- Free catalog text is intentionally coarse and pre-generated.
- It must disclose its limited basis and never present itself as natal-level precision.
- Catalog content is product/editorial content, not a source of astronomical facts.

### Precision features

- Exact placements, aspects, houses, timing, dashas, pillars and relationship facts come from the structured calculation layer/provider and validated methodology.
- Design mockup values are prototype content unless independently validated.
- Interpretation/LLM consumes structured facts; it must not invent positions, degrees, houses, Ascendant, aspects, nakshatras, dashas, pillars or timing.
- Exact clock times appear only when deterministically/calculationally supported.

## 08 — Unknown birth time

For precision features, unknown birth time degrades only the facts that truly depend on time/uncertainty; it is never replaced with a hidden fake time.

- Western: Rising/houses require sufficient time; Moon/aspects may become uncertain near boundaries.
- Vedic: Lagna/Bhavas and some Moon/timing outputs depend on time/uncertainty.
- Chinese/BaZi: Hour Pillar is unavailable without time; other pillar reliability depends on signed-off calendar/day-boundary methodology.

Free coarse catalog paths do not use birth time merely to imitate precision.

## 09 — Methodology status

Any choice that changes calculated output requires domain/methodology validation.

Research/sign-off remains required for items tracked in [`../development/METHODOLOGY_TRACK.md`](../development/METHODOLOGY_TRACK.md), including Western house/composite choices, Vedic conventions/non-romantic compatibility, Chinese/BaZi calendar/Four-Pillars/Luck-Cycle rules and cross-system timing mapping.

A provider response or a visual mockup does not constitute methodology sign-off.

## 10 — Design vs technical architecture

Product/design locks user-visible behavior, hierarchy and access meaning. Architecture decides:

- exact backend/storage technology;
- provider adapters and vendor configuration;
- StoreKit/ad SDK details;
- reward verification/recovery;
- cache identity/TTL/retention;
- notification delivery mechanics;
- privacy/security implementation.

Architecture may optimize cost but may not silently turn Free requests into paid provider calls.

## 11 — Brand/name authority

**Humay** is the product name, repository name and current internal project name.

| Name | Status |
|---|---|
| Astara | Historical former working/repository name only |
| Ortus | Historical placeholder |
| Ecliptic | Rejected historical recommendation |
| Eclipse | Historical visual exploration only |
| Humay | Current product/project/repository name |

Pass 5.1 remains useful history for the Humay wordmark/mark. The 2026-08-12 soulful direction controls how the brand appears in current Light/Dark product surfaces.

External trademark, store naming, domain/handle and cultural/linguistic clearance remain launch tasks.

## 12 — Device scope

V1 targets **iPhone portrait**. iPad remains a dedicated later design/implementation phase rather than a stretched phone layout.

The iPhone design system must remain adaptable: semantic spacing, reusable components, responsive chart geometry and content separated from presentation.

## 13 — Current design status

- Soulful Celestial is the current visual authority.
- D0 establishes three anchor families: Today/Home, Daily Horoscope and Compatibility, each with a Light/Dark pair.
- Light anchors define the selected direction.
- Initial Dark anchors define translation strategy and require a dedicated refinement pass.
- The full redesign proceeds D1–D9 according to [`SCREEN_DESIGN_PLAN.md`](SCREEN_DESIGN_PLAN.md).
- Historical Claude/final-archive screenshots remain useful for feature/state inventory, not visual styling.
- The Phase 01M implementation remains a stable structural/accessibility/mock baseline but is no longer the target visual appearance.

## 14 — Implementation gate

A screen family should not receive final production visual polish until its paired Light/Dark references are approved. Architectural/service work that is independent of appearance may continue in parallel.

After D9, update this map once more with the final screen index and production-asset catalog.