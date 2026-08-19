# Humay Premium Celestial Redesign

**Status:** Current redesign authority
**Effective:** 2026-08-19
**Scope:** iPhone and iPad, Light and Dark, all post-onboarding product surfaces
**Implementation phase:** Representative foundation implemented and verified

This document supersedes the visual treatment and post-onboarding information architecture in `SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`. Existing product, calculation, access, privacy, persistence, and sample-data boundaries remain authoritative.

## Design thesis

Humay is a premium astrology product shaped by Huma mythology, celestial mechanics, and restrained Persian visual heritage.

- 75% contemporary premium iOS UI
- 15% Persian celestial and astronomical heritage
- 10% Huma mythology

The interface uses editorial hierarchy, quiet surfaces, extremely thin orbital geometry, and generous negative space. Huma appears as a recurring visual grammar—wing, feather, eye, crown plume, flight path, and paired orbit—not as a mascot placed on every screen.

Avoid generic purple horoscope styling, neon glow, crystal-shop imagery, constant gradients, excessive glass, cartoon birds, and a card around every content block.

## Current audit

### What works and stays

- Clean dependency direction: `App → Presentation → Domain ← Data`.
- Provider-independent astrology facts, reliability, provenance, and unknown-time handling.
- Release-safe production states separated from Debug-only development samples.
- Native SwiftUI navigation, safe-area behavior, Dynamic Type foundations, VoiceOver identifiers, and 44 pt interaction targets.
- Newsreader for editorial roles, SF Pro for interface text, and monospaced technical values.
- Existing structured zodiac, planet, and moon-phase vectors where their geometry remains visually suitable.
- Adaptive width helpers and explicit iPhone/iPad layouts.

### Current visual problems

- Friendly celestial illustrations, coral/lavender gradients, and character faces make the product feel playful before it feels authoritative.
- Generic planets, coffee, crystal-ball, and zodiac art do not create a distinctive Huma identity.
- Rounded cards are the default grouping tool, producing dashboard density instead of editorial rhythm.
- Today presents a stack of modules rather than one emotionally focused daily narrative.
- Compatibility centers one large percentage, reducing a nuanced relationship reading to a score.
- The chart wheel is visually contained inside card chrome and is not directly interactive.
- Technical facts and human interpretation are separated inconsistently; there is no shared three-level disclosure pattern.
- `D2VisualComponents.swift` mixes headers, states, surfaces, category icons, people, and many unrelated illustrations.
- Presentation code still contains local radii, type sizes, padding, gradients, and image decisions outside semantic tokens.
- Color assets contain duplicate legacy families and a broad coral/lavender/sage palette without clear prestige, information, or status semantics.
- Navigation is feature-first (`Today / Circle / Sky / Chart / Ask`) rather than question-first. Profile is auxiliary despite owning important birth and preference context.

### Current HIG baseline: 8/10

Strengths: native tab/stack navigation, safe areas, adaptive layouts, semantic appearance assets, Dynamic Type, minimum targets, and broad accessibility labeling. To reach 10/10: remove remaining hard-coded type/layout values, add coherent focus and selected states, audit all custom graphics with VoiceOver, apply Reduce Motion consistently, and validate the new five-destination iPad presentation at compact and regular widths.

## Navigation mapping

| New destination | Existing ownership retained | Product role |
|---|---|---|
| Today | Today + Daily Horoscope | Personal daily editorial experience |
| Chart | Chart + placement routes | Natal-chart hero and fact/meaning exploration |
| Explore | Sky, Calendar, Ask, and links into existing readings | Question-first discovery and current timing |
| Connections | Circle, saved people, Compatibility | People and relationship astrology |
| You | Profile/Settings auxiliary content | Birth details, preferences, saved people, access, settings |

Internal domain and feature types may retain names such as `Circle`, `Sky`, and `Ask`. Navigation labels and route ownership change only where needed. Sky, Calendar, Ask, saved people, and settings remain accessible; no feature is deleted.

## Progressive astrology disclosure

Every interpretive experience follows one shared hierarchy:

1. **Human meaning** — immediate plain-language interpretation.
2. **Why this appears** — short explanation connecting meaning to the relevant chart or timing area.
3. **Astrology details** — structured facts, degrees, houses, aspects, reliability, and methodology.

Level 3 is available through disclosure or direct chart interaction without interrupting Level 1. Free catalog content must disclose its coarse basis. Missing facts remain visibly unavailable; UI never invents a transit, aspect, house, time, or score dimension.

## Token system

Swift tokens use three layers: primitive values, semantic roles, then component roles. Feature views consume semantic or component roles only.

### Primitive palette

| Family | Light | Dark | Use |
|---|---:|---:|---|
| Canvas | `#F7F2E9` | `#080B12` | Ivory parchment / midnight |
| Surface | `#FCF9F3` | `#10141D` | Quiet content layer |
| Elevated | `#F0E7D9` | `#171C27` | Selected or raised layer |
| Ink | `#171713` | `#F2EBDD` | Primary text |
| Muted ink | `#69655E` | `#AAA79F` | Secondary text |
| Hairline | `#D8CDBD` | `#2B3240` | Dividers and orbital lines |
| Celestial gold | `#A77F34` | `#D2AE65` | Prestige and selected state |
| Indigo | `#525A8A` | `#8D94C8` | Secondary celestial information |
| Roast ember | `#B8574E` | `#D9796D` | Roast-only tonal break |

Gold is rare and meaningful. Indigo supports information hierarchy. Roast ember never becomes the global accent.

### Semantic roles

- `canvas`, `surface`, `surfaceElevated`, `surfaceSelected`
- `textPrimary`, `textSecondary`, `textTertiary`, `textOnAccent`
- `accentPrestige`, `accentCelestial`, `accentRoast`
- `separator`, `orbit`, `focus`, `statusPositive`, `statusCaution`, `statusCritical`
- `chartHarmonious`, `chartDynamic`, `chartSelected`

### Spacing, shape, depth, motion

- Spacing scale: 4, 8, 12, 16, 20, 24, 32, 40, 56, 72.
- Page margin: 20 compact, 28 medium, 40 regular; reading width stays bounded.
- Radius: 10 compact control, 16 grouped surface, 24 hero only, pill only for status/filters.
- Hairlines use one physical pixel where possible.
- Shadows appear only for floating hierarchy; tonal separation and lines do most work.
- Motion: 120 ms press, 220 ms selection, 420 ms reveal, slow orbit only during loading or an intentional hero moment.
- Reduce Motion replaces orbit/flight movement with opacity and state changes.

## Typography hierarchy

- **Wordmark:** Cormorant Garamond, used only for Humay identity.
- **Hero display:** Newsreader, Dynamic Type relative to Large Title.
- **Editorial title:** Newsreader, Dynamic Type relative to Title.
- **Section title:** Newsreader or SF Pro depending on narrative vs utility content.
- **Body and controls:** SF Pro semantic styles.
- **Metadata and labels:** SF Pro, restrained uppercase only for short eyebrow labels.
- **Technical facts:** SF Mono/system monospaced, tabular digits where useful.

Hierarchy uses space, weight, and measure before large size jumps. Body copy remains readable at accessibility sizes.

## Reusable component plan

- `HumayPage` — adaptive page margins, max widths, canvas, and bottom clearance.
- `HumayScreenHeader` — wordmark/context/profile treatment without decorative clutter.
- `HumaySectionHeader` — editorial or utility variants.
- `HumayEditorialHero` — one dominant thought with optional celestial stage.
- `HumayCelestialStage` — code-drawn Huma/orbit composition with no implied data.
- `HumayHairlineSurface` — minimal grouping; raised variants are explicit.
- `HumayDisclosureStack` — Human meaning / Why / Astrology details.
- `HumayMetricBand` — qualitative relationship dimension with optional technical score.
- `HumayFactRow` — accessible fact/value/reliability presentation.
- `HumayStateView` and `HumayLoadingMark` — shared empty, offline, error, locked, and loading language.
- `HumayOrbitGlyph`, `HumayFeatherGlyph`, `HumayEyeGlyph`, and `HumayConnectionGlyph` — reusable SwiftUI shapes.
- `HumayMotion` — shared durations and Reduce Motion-aware animation selection.

## Representative-screen direction

### Today

One editorial flow: greeting/context, Cosmic Weather hero, major themes, one important insight, category entry points, then timing/basis. Human meaning leads; basis and technical detail disclose progressively.

### Natal Chart

The wheel becomes the hero with minimal surrounding chrome. Planets are tappable 44 pt targets; selected focus updates a nearby interpretation and exposes degree/house/reliability. iPad uses wheel + detail in two regions. Ordered placement lists remain the accessible alternative.

### Placement Detail

Starts with interpretation, then explanation, then structured technical facts. Reliability and methodology remain visible. No decorative art competes with the reading.

### Compatibility

Pair identity and intertwined orbits lead. Relationship label and summary replace a giant percentage. Chemistry, Communication, Emotional Safety, and Shared Rhythm become primary dimensions. Overall score remains available only as supporting technical context because current contracts still carry it. Free Sun-sign and unavailable synastry limitations are explicit.

### Explore

Questions lead, technical systems follow. Love, Career, Money, Health, Personality, Strengths, Challenges, Current Timing, and Major Life Themes route into existing Today, Chart, Sky, Ask, and Compatibility capabilities. Explore does not fabricate content for unavailable topics.

## Asset strategy

### Retain and refine

- Newsreader and Cormorant font files.
- Zodiac, planet, and moon-phase glyph vectors after optical review.
- Native SF Symbols for standard navigation and system actions only.

### Deprecate from redesigned surfaces

- Coffee, crystal ball, smiling planet, cute zodiac, and generic celestial scene illustrations.
- Legacy navigation/category art that duplicates native actions or does not express Humay.
- Decorative gradients and star clusters used without semantic purpose.

Assets are not deleted during the representative phase if unaffected screens still reference them. New Huma identity primitives are drawn in SwiftUI. Production emblem/app-icon artwork needs a later dedicated vector design pass; no fake production-ready placeholder will be generated.

## Phase acceptance criteria

- Today, Chart, Placement Detail, Compatibility, and Explore share one token/component language.
- Existing data and state contracts remain intact.
- New navigation preserves Sky, Calendar, Ask, Circle/people, Compatibility, and Profile access.
- Light and Dark are deliberately composed.
- iPhone SE/standard/Max and iPad compact/regular layouts remain usable.
- 44 pt targets, Dynamic Type, VoiceOver, color-independent meaning, and Reduce Motion are respected.
- Debug samples remain labeled; Release never displays them as real astrology.
- Build, tests, screenshots, and this document are updated after each implementation phase.

## Phase 1 implementation record

Completed on 2026-08-19. Product-code changes are confined to app composition/navigation, Presentation, DesignSystem, and visual resources; the phase added no dependency, backend, provider, persistence, Data-layer, or astrology-domain change.

### System delivered

- Semantic ivory/midnight, ink, gold, indigo, status, orbit, and chart color roles with deliberate Light/Dark values.
- Global accent and launch-background assets now match the gold/canvas system; two identical nested legacy copies were removed to eliminate asset-catalog ambiguity.
- Editorial and technical typography roles, a shared spacing/radius/motion scale, adaptive page gutters, and a 54 pt primary-control standard.
- `HumayPage`, screen/section headers, hairline surfaces, progressive disclosure, fact rows, relationship metric bands, and shared state presentation.
- SwiftUI-drawn feather, eye, wing, crown, orbit, eclipse, connection, Huma-mark, and celestial-stage motifs. Reduce Motion removes intentional orbit movement.
- Primary navigation mapped to **Today / Chart / Explore / Connections / You**. Current Sky, Calendar, and Ask live under Explore; Circle/people and Compatibility live under Connections; profile and settings content live under You.

### Representative experiences delivered

| Experience | Implemented result |
|---|---|
| Today | Editorial Cosmic Weather flow, one primary insight, quiet theme/category entry points, and progressive basis disclosure using existing state contracts. |
| Natal Chart | Chart-first hero, tappable planets/houses/aspects, selected focus interpretation, accessible ordered alternatives, and adaptive iPad wheel/detail composition. |
| Placement Detail | Human meaning first, placement explanation second, structured degrees/house/reliability/methodology last. |
| Compatibility | Intertwined-orbit identity, multidimensional relationship reading, needs/friction/strengths, and demoted overall score with honest technical limitations. |
| Explore | Question-first discovery mapped to real Today, Chart, Current Sky, Ask, and Connections destinations without invented content. |

`You` was added as the fifth root destination so the new information architecture is complete; its existing profile, birth, preference, people, privacy, and settings data remains presentation-only.

### Verification

- Debug app builds passed for iPhone 17 Pro and iPad Pro 13-inch simulator destinations; the Release simulator build also passed, confirming Debug sample routing stays compilation-safe.
- Swift Testing passed: **112 tests across 13 suites**.
- Targeted XCUITests passed for the five-destination shell/Explore hub, Current Sky routing, Ask routing, Compatibility, and interactive Western Chart/Placement Detail.
- Visual inspection passed on iPhone Light/Dark and iPad Light/Dark. Reviewed Today, Chart root, Western Chart, Placement Detail, Explore, and Compatibility; regular-width chart and compatibility use deliberate two-region layouts.
- Typography, architecture layering, nomenclature, and diagnostics foundation checks pass. The aggregate foundation script still returns nonzero at its historical `Latest committed diff whitespace` gate because the repository baseline contains trailing whitespace in legacy SVG/reference files; none is introduced by this redesign diff.

### Deliberate boundaries and next phase

- Propagate the new primitives through Daily Horoscope, Current Sky/Calendar/Event Detail, Ask, remaining Connections people flows, settings, and monetization surfaces.
- Keep approved onboarding behavior intact; visually migrate it only as its own reviewed phase.
- Retire legacy cute raster/vector illustrations only after a complete reachability audit confirms no unaffected screen still needs them.
- Commission final production Huma emblem/app-icon artwork as a dedicated vector identity deliverable. Current code-drawn motifs are interface primitives, not fake final brand artwork.
- Add real synastry-aspect detail only when an owning provider supplies structured aspects. Current compatibility dimensions are presentation mappings of the existing four domain metrics, not new calculated claims.
