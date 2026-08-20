# Humay Premium Celestial Redesign

**Status:** Current redesign authority
**Effective:** 2026-08-20
**Scope:** iPhone and iPad, Light and Dark, all post-onboarding product surfaces
**Implementation phase:** Phase 2 Today + Connections propagation complete

This document supersedes the visual treatment and post-onboarding information architecture in `SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`. Existing product, calculation, access, privacy, persistence, and sample-data boundaries remain authoritative.

## Design thesis

Humay is a premium astrology product shaped by Huma mythology, celestial mechanics, and restrained Persian visual heritage.

- 75% contemporary premium iOS UI
- 15% Persian celestial and astronomical heritage
- 10% Huma mythology

The interface uses editorial hierarchy, quiet surfaces, data-derived celestial geometry, and generous negative space. Huma identity appears only through approved production vector artwork and only where it carries identity value. Until that artwork is commissioned and accepted, the interface deliberately uses typography and whitespace instead of a fake bird mark.

Avoid generic purple horoscope styling, neon glow, crystal-shop imagery, constant gradients, excessive glass, cartoon birds, and a card around every content block.

## Current audit

The findings below record the pre-redesign baseline. The Phase 1, corrective asset,
and Phase 2 implementation records later in this document supersede resolved items.

### What works and stays

- Clean dependency direction: `App → Presentation → Domain ← Data`.
- Provider-independent astrology facts, reliability, provenance, and unknown-time handling.
- Release-safe production states separated from Debug-only development samples.
- Native SwiftUI navigation, safe-area behavior, Dynamic Type foundations, VoiceOver identifiers, and 44 pt interaction targets.
- Newsreader for editorial roles, SF Pro for interface text, and monospaced technical values.
- Existing structured zodiac and planet concepts, supplied through a corrected, coherent vector family.
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
- Motion: 120 ms press, 220 ms selection, and 420 ms reveal. Loading uses native progress treatment.
- Reduce Motion replaces nonessential movement with opacity and state changes.

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
- `HumayEditorialHero` — one dominant thought; any optional art must be an approved bundled asset.
- `HumayHairlineSurface` — minimal grouping; raised variants are explicit.
- `HumayDisclosureStack` — Human meaning / Why / Astrology details.
- `HumayMetricBand` — qualitative relationship dimension with optional technical score.
- `HumayFactRow` — accessible fact/value/reliability presentation.
- `HumayStateView` and native progress treatment — shared empty, offline, error, locked, and loading language.
- `HumayAsset` / `HumayAssetImage` — typed catalog access, rendering mode, aspect preservation, and accessibility defaults.
- `HumaySystemSymbol` / `HumaySystemSymbolImage` — semantic SF Symbol vocabulary with consistent weight and optical frames.
- `HumayMotion` — shared durations and Reduce Motion-aware animation selection.

## Representative-screen direction

### Today

One editorial flow: greeting/context, Cosmic Weather hero, major themes, one important insight, category entry points, then timing/basis. Human meaning leads; basis and technical detail disclose progressively.

### Natal Chart

The wheel becomes the hero with minimal surrounding chrome. Planets are tappable 44 pt targets; selected focus updates a nearby interpretation and exposes degree/house/reliability. iPad uses wheel + detail in two regions. Ordered placement lists remain the accessible alternative.

### Placement Detail

Starts with interpretation, then explanation, then structured technical facts. Reliability and methodology remain visible. No decorative art competes with the reading.

### Compatibility

Pair identity leads through names, avatars, and clear relationship UI. Relationship label and summary replace a giant percentage. Chemistry, Communication, Emotional Safety, and Shared Rhythm become primary dimensions. Overall score remains available only as supporting technical context because current contracts still carry it. Free Sun-sign and unavailable synastry limitations are explicit; decorative orbits never imply calculated synastry.

### Explore

Questions lead, technical systems follow. Love, Career, Money, Health, Personality, Strengths, Challenges, Current Timing, and Major Life Themes route into existing Today, Chart, Sky, Ask, and Compatibility capabilities. Explore does not fabricate content for unavailable topics.

## Asset & Iconography Authority

This section is non-negotiable for all future implementation.

### No programmatic artwork

Icons, illustrations, brand marks, zodiac or planet symbols, moon phases, compatibility art, and decorative celestial motifs must not be drawn with SwiftUI `Shape`, custom `Path`, `Canvas`, Bézier construction, `CGPath`, or arrangements of primitive circles, ellipses, rectangles, and lines. Translating rejected SwiftUI curves into SVG does not make them acceptable artwork.

Programmatic drawing is allowed only when geometry represents real application data: natal-chart house divisions, actual aspect lines, planetary positions, provider-backed transit trajectories, numeric progress, and charts/graphs. Every surviving drawing implementation must be traceable to structured values; decorative geometry is not data visualization.

### SF Symbols

Use SF Symbols for standard actions, navigation utilities, toolbar controls, states, and clear generic interface concepts. Do not recreate settings, search, back, close, add, delete, edit, share, calendar, notification, profile, chevron, overflow, information, or root-navigation actions. Use one coherent symbol weight and optical sizing strategy. Do not use SF Symbols as invented astrology glyphs when established astrology symbols exist.

### Third-party icon libraries

Add no icon dependency while SF Symbols cover the generic need. A future library requires a documented repository, pinned version, permissive commercial license, exact icon categories, reason SF Symbols are insufficient, binary/dependency impact, no runtime network dependency, and preferably no icon font. Generic bird, feather, zodiac, or astrology clip art is never a Humay identity substitute.

### Bundled vector assets

Humay identity and astrology-specific symbols use reviewed production SVG source and vector-preserving asset-catalog imagesets. Assets must preserve aspect ratio and contain intentional optical bounds; they must not rely on embedded raster images, live fonts, external resources, unsupported filters, or noisy generated paths. Monochrome technical glyphs render as templates using semantic colors. Multicolor brand/illustration assets render as original; Light/Dark variants exist only when composition or contrast genuinely changes.

All runtime catalog access goes through the small typed `HumayAsset` vocabulary. Feature code must not scatter `Image("asset-name")` strings or construct asset names. SF Symbols go through native APIs or the centralized semantic symbol vocabulary when repeated optical treatment is useful.

### Astrology correctness

Informational symbols must use established, verified astrology glyphs where they exist. Each asset must have one documented semantic meaning; screens may not reuse a decorative celestial-looking mark for unrelated concepts. Unsupported entities are not added to make a family look complete. The supported zodiac, planet, point, aspect, and phase inventory follows actual domain models and is recorded in [`ASSET_INVENTORY.md`](ASSET_INVENTORY.md).

### Identity, source, and licensing

The Huma requires dedicated production design against [`HUMA_ASSET_REQUIREMENTS.md`](HUMA_ASSET_REQUIREMENTS.md). No temporary bird drawing is presented as completed identity work. Source repository, version, license, attribution obligations, rendering intent, appearance variants, and verification state are recorded in [`ASSET_INVENTORY.md`](ASSET_INVENTORY.md); required license text lives under [`licenses/`](licenses/). The catalog assets plus that inventory are the source of truth. Assets may be removed only after reachability analysis.

### Retain and refine

- Newsreader and Cormorant font files.
- Coherent licensed zodiac, supported-planet, and aspect vectors after optical review.
- Native SF Symbols for standard navigation, system actions, states, and generic UI concepts.

### Deprecate from redesigned surfaces

- Coffee, crystal ball, smiling planet, cute zodiac, and generic celestial scene illustrations.
- Legacy navigation/category art that duplicates native actions or does not express Humay.
- Decorative gradients and star clusters used without semantic purpose.

Assets are deleted only after reachability analysis confirms no shipping call site. Production Huma emblem/app-icon artwork requires a dedicated vector identity deliverable; the app ships no fake production-ready placeholder.

## Phase acceptance criteria

- Today, Daily Horoscope, Chart, Placement Detail, Explore, Connections people flows, and Compatibility share one token/component language.
- Existing data and state contracts remain intact.
- New navigation preserves Sky, Calendar, Ask, Circle/people, Compatibility, and Profile access.
- Light and Dark are deliberately composed.
- iPhone SE/standard/Max and iPad compact/regular layouts remain usable.
- 44 pt targets, Dynamic Type, VoiceOver, color-independent meaning, and Reduce Motion are respected.
- Debug samples remain labeled; Release never displays them as real astrology.
- Build, tests, screenshots, and this document are updated after each implementation phase.

## Phase 1 and corrective asset implementation record

Phase 1 completed on 2026-08-19; the corrective asset pass completed on 2026-08-20. Product-code changes are confined to app composition/navigation, Presentation, DesignSystem, and visual resources; neither pass added a backend, provider, persistence, Data-layer, or astrology-domain change.

### System delivered

- Semantic ivory/midnight, ink, gold, indigo, status, orbit, and chart color roles with deliberate Light/Dark values.
- Global accent and launch-background assets now match the gold/canvas system; the unused nested legacy color family was removed to eliminate asset-catalog ambiguity.
- Editorial and technical typography roles, a shared spacing/radius/motion scale, adaptive page gutters, and a 54 pt primary-control standard.
- `HumayPage`, screen/section headers, hairline surfaces, progressive disclosure, fact rows, relationship metric bands, and shared state presentation.
- Typed vector access for conventional astrology glyphs and centralized SF Symbol treatment for generic UI concepts.
- Primary navigation mapped to **Today / Chart / Explore / Connections / You**. Current Sky, Calendar, and Ask live under Explore; Circle/people and Compatibility live under Connections; profile and settings content live under You.

### Corrective asset system delivered

- Deleted the code-drawn `HumayMotifs.swift` artwork system and the decorative compatibility connector. No rejected Huma, wing, feather, eye, crown, eclipse, fake orbit, or connection drawing remains.
- Replaced all 12 technical zodiac glyphs and all 10 supported planet glyphs with licensed, vector-preserving Noto outlines using standardized optical bounds.
- Added conventional conjunction, opposition, square, trine, and sextile vectors; actual chart lines remain computed data visualization.
- Centralized catalog access and rendering behavior in `HumayAsset` / `HumayAssetImage`; centralized recurring native symbols in `HumaySystemSymbol`.
- Removed unreachable legacy navigation/category icons, decorative motifs, moon phases, unsupported nodes/elements, obsolete illustrations, and the constellation path after reachability analysis.
- Added no icon package. Generic actions and all five root destinations use coherent SF Symbols.
- Deferred Huma identity artwork rather than shipping a fake substitute; the production brief and acceptance gate live in `HUMA_ASSET_REQUIREMENTS.md`.

### Representative experiences delivered

| Experience | Implemented result |
|---|---|
| Today | Editorial Cosmic Weather flow, one primary insight, quiet theme/category entry points, and progressive basis disclosure using existing state contracts. |
| Natal Chart | Chart-first hero, tappable planets/houses/aspects, selected focus interpretation, accessible ordered alternatives, and adaptive iPad wheel/detail composition. |
| Placement Detail | Human meaning first, placement explanation second, structured degrees/house/reliability/methodology last. |
| Compatibility | Clear pair identity, multidimensional relationship reading, needs/friction/strengths, and demoted overall score with honest technical limitations. |
| Explore | Question-first discovery mapped to real Today, Chart, Current Sky, Ask, and Connections destinations without invented content. |

`You` was added as the fifth root destination so the new information architecture is complete; its existing profile, birth, preference, people, privacy, and settings data remains presentation-only.

### Verification

- Debug builds passed for iPhone 17 Pro and iPad Pro 13-inch simulator destinations. The generic Simulator Release build also passed.
- Swift Testing passed: **113 tests across 13 suites**.
- The complete XCUITest target passed: **46 tests, 0 failures, 0 skips** on iPhone 17 Pro.
- Asset-focused screenshot routes passed and were visually inspected on standard iPhone Light/Dark, iPhone Pro Max Light, iPad portrait Light, and iPad landscape Light. Reviewed Today, Explore, Western Chart, Placement Detail, Compatibility selection/result, 16–24 pt technical glyphs, tab symbols, and regular-width two-region compositions.
- Every bundled replacement SVG passed XML/catalog compilation checks and contains no embedded raster, live text, external resource, filter, gradient, or generator metadata.
- Repository survivor search finds SwiftUI `Canvas` / `Path` only in `ChartWheel.swift`, where house divisions and aspect lines are computed from `ChartWheelModel`. No rejected motif type or raw feature-level `Image("asset-name")` access remains.

### Deliberate boundaries and next phase

- Propagate the new primitives through Current Sky/Calendar/Event Detail, Ask, settings, and monetization surfaces.
- Keep approved onboarding behavior intact; visually migrate it only as its own reviewed phase.
- Retain the still-reachable legacy onboarding, Ask, and Current Sky/Calendar illustrations until those screens receive their own reviewed propagation pass; all unreachable shipping copies have been removed.
- Commission final production Huma emblem/app-icon artwork against `HUMA_ASSET_REQUIREMENTS.md`; no code-drawn identity primitive is permitted.
- Add real synastry-aspect detail only when an owning provider supplies structured aspects. Current compatibility dimensions are presentation mappings of the existing four domain metrics, not new calculated claims.

## Phase 2 — Today + Connections propagation

Completed on 2026-08-20. This phase preserved the five-destination root information
architecture and all Domain, Data, persistence, provider, backend, and API contracts.
No dependency or astrology calculation was added.

### Surfaces migrated

- Daily Horoscope is now an editorial reading: typed technical zodiac identity,
  period/status context, headline and opening interpretation, quiet life-area rows,
  composition-led Daily Tip, progressive basis disclosure, and system sharing.
- Loading, Free, precise locked, Debug-only precise preview, precise loaded, cached,
  offline-with-cache, offline-without-cache, and failed Daily states remain distinct.
  Locked precision explicitly states that provider, Rewarded, and Premium generation
  are not connected; it does not simulate a purchase or generation.
- Connections now establishes people first and compatibility second. Saved people use
  restrained initials, typed zodiac glyphs, concise birth context, and adaptive rows.
  Loaded, empty, loading, cached/offline, offline-without-cache, and failure states are
  preserved without fake synastry or Today Together content.
- Add Person now uses a bounded native form with clear known/unknown birth semantics,
  keyboard focus, validation focus, and iPad sheet sizing. Birth time remains optional;
  location remains unavailable in this existing flow.
- Person Detail now presents only stored identity, Sun sign, birth facts, missing data,
  and current limitations. It adds no natal, personality, relationship, or provider-backed
  claim.
- Compatibility Selection and Compatibility were reconciled through the shared person
  identity and typed zodiac treatments. Their approved pair-selection, multidimensional
  result, Free/Precise honesty, and provider boundaries were not redesigned.

### Asset-policy enforcement and removal

- `Scripts/check-asset-policy.sh` mechanically rejects production custom artwork paths
  and uncontrolled asset-catalog strings. `Scripts/verify-foundation.sh` runs it.
- The only drawing allowlist entry is `Humay/Presentation/Chart/ChartWheel.swift`, whose
  paths represent chart houses and aspects derived from `ChartWheelModel` data.
- The only non-system `Image(...)` allowlist entry is the centralized typed renderer in
  `Humay/DesignSystem/Assets/HumayAssets.swift`.
- Deleted the twelve cute zodiac illustration imagesets,
  `IllustrationDailyTipCrystalBall`, and `IllustrationTodayTogether` after reachability
  analysis. Daily and Connections no longer reference legacy illustration types.
- Retained only still-reachable illustration assets for untouched onboarding, Ask, and
  Current Sky/Calendar surfaces. Production Huma primary/compact marks remain pending.

### Cross-device QA

- Inspected normal/free, precise locked, populated, empty, Add Person, Person Detail,
  and compatibility-entry compositions on iPhone 17 Pro and 13-inch iPad Pro simulators.
- Verified Light and Dark on both devices. The iPad review covers portrait and its
  1032-point regular-width composition; reading measure, adaptive people grid, bounded
  sheets, surface hierarchy, muted text, gold, and zodiac contrast remain controlled.
- iPadOS 26.5 XCTest kept the app window in portrait geometry after a requested device
  rotation, so no false landscape screenshot claim is made. The captured regular-width
  layout is the wide-layout acceptance artifact for this phase.
- Phase 3 was not started. Current Sky, Calendar, Event Detail, Ask the Stars, Settings,
  monetization/paywalls, onboarding, unfinished Vedic/BaZi/Compare Systems, sharing,
  widgets, app icon, and final Huma integration remain incomplete or separately scoped.

### Verification

- Debug builds pass on iPhone 17 Pro and 13-inch iPad Pro simulators; the generic
  Simulator Release build passes.
- Swift Testing passes **113 tests in 13 suites**.
- The focused Phase 2 UI suite passes **7 tests**; the complete iPhone XCUITest target
  passes **52 tests with 0 failures**. The Phase 2 evidence test also passes on the
  13-inch iPad Pro destination.
- `Scripts/verify-foundation.sh`, direct asset-policy validation, `git diff --check`,
  asset-catalog compilation, all catalog JSON parsing, and all SVG XML parsing pass.
- Survivor scans find no drawing API, raw catalog string, Unicode zodiac-icon rendering,
  or legacy illustration type in affected Today/Connections code. Repository drawing
  matches remain only the three approved `ChartWheel.swift` data-visualization lines.
