# Humay Asset Inventory

**Status:** Corrective redesign audit and migration ledger
**Audit date:** 2026-08-20
**Scope:** Shipping asset catalog, custom SwiftUI artwork, Phase 1 Premium Celestial surfaces, and root navigation

This inventory is the source of truth for asset reachability, semantics, licensing, and replacement status. A visual is not approved merely because it builds or exists in an asset catalog.

## Decision and category legend

- **KEEP** — production-suitable and semantically correct for its current use.
- **REFINE** — sound source/concept, but optical or rendering work remains.
- **REPLACE** — unsuitable quality, inconsistent family, or incorrect/ambiguous semantics.
- **REMOVE** — unreachable, superseded, or unsupported by Humay's current domain.
- **A** — replace with SF Symbol.
- **B** — replace with a licensed generic icon library. No B-category need was found in this pass.
- **C** — replace with a bundled production vector asset.
- **D** — keep programmatic drawing because geometry represents real application data.

Verification values are **verified**, **verified as removed**, or **production artwork required**.

## Programmatic artwork audit

| Semantic name | Current source | Current usages | Category | Decision | Replacement | Semantic finding | Verification |
|---|---|---|---|---|---|---|---|
| Generic orbit glyph | Deleted `HumayMotifs.swift` / `HumayGlyph.orbit` | Formerly Today, Explore, You, and state UI | A | REMOVE | Context-specific SF Symbols such as `clock`, `calendar`, `cross.case`, or `moon.stars` | One fake orbit represented unrelated concepts and could not carry stable meaning. | verified as removed |
| Feather glyph | Deleted `HumayMotifs.swift` / `HumayFeatherShape` | Formerly Today, Chart, Compatibility, Explore, and You | A/C | REMOVE | SF Symbols or typography; future licensed brand feather only after Huma identity approval | Decorative feather was being used as career, life-theme, sign, reading, and user-tone semantics. | verified as removed |
| Eye glyph | Deleted `HumayMotifs.swift` / `HumayEyeShape` | Formerly Today, Explore, Placement Detail, and You | A | REMOVE | `flame`, `questionmark.bubble`, real planet glyph, `hand.raised`, or no icon | One invented eye represented personality, privacy, a planet, Ask, and Roast. | verified as removed |
| Crown glyph | Deleted `HumayMotifs.swift` / three feather shapes | Formerly Today and Explore | A | REMOVE | `dollarsign.circle`, `star`, or `circle.grid.cross` | Crown is not an established astrology symbol and was semantically inconsistent. | verified as removed |
| Eclipse glyph | Deleted `HumayMotifs.swift` / overlapping circles | Formerly error, offline, challenge, and empty states | A | REMOVE | State-specific SF Symbols | Eclipse artwork incorrectly implied a technical celestial event for generic failures. | verified as removed |
| Connection glyph | Deleted `HumayMotifs.swift` / crossed ellipses | Formerly love, compatibility, and chart aspect focus | A/C | REMOVE | `heart` / `person.2` for relationship UI; conventional aspect glyph for chart data | No universal astrology glyph means “compatibility.” Chart aspects require their actual aspect symbols. | verified as removed |
| Wing motif | `HumayWingShape` | Huma mark only | C | REMOVE | Commissioned Huma identity vector | Hand-authored wing anatomy is not production identity work. | production artwork required |
| Huma mark | `HumayHumaMark` | You identity and celestial stage | C | REMOVE | Commissioned primary and compact Huma assets | Symmetric wings around a circle/eye are not a recognizable Huma. | production artwork required |
| Celestial stage | Deleted `HumayCelestialStage` | Formerly Today, Explore, and Chart entry | C | REMOVE | Typography/whitespace now; optional approved Huma composition later | Decorative orbit has no data meaning and embeds rejected Huma drawing. | verified as removed |
| Compatibility motif | Deleted `HumayConnectionMotif` | Formerly Compatibility and Connections | A/C | REMOVE | Pair layout plus SF `heart`; commissioned motif only if later justified | Decorative crossed orbits are not synastry data and imply technical meaning. | verified as removed |
| Pair connector curve | Deleted `CompatibilityOrbitShape` | Formerly Compatibility pair selector | A | REMOVE | SF `heart` with ordinary layout spacing/dividers | Curve is decorative artwork, not application-data geometry. | verified as removed |
| Natal chart wheel | `ChartWheel.swift` `Canvas` and `Path` | Western chart | D | KEEP | None | House cusps, aspect endpoints, and longitudes come from `ChartWheelModel`. This is real visualization. | verified |
| Metric bands and progress geometry | `HumayMetricBand` and native progress/state UI | Compatibility metrics and system states | D/UI | KEEP | None | Geometry directly represents numeric score/progress or ordinary control chrome, not illustration. | verified |

## Brand identity requirements

| Semantic name | Current source | Usages after migration | Decision | Proposed replacement | Source/license | Appearance | Rendering | Verification |
|---|---|---|---|---|---|---|---|---|
| Primary Huma emblem | None of production quality | Reserved for identity moments only | REPLACE | Dedicated commissioned vector; see `HUMA_ASSET_REQUIREMENTS.md` | Humay-owned production artwork required | Shared transparent vector preferred; variants only if contrast requires | original | production artwork required |
| Compact Huma mark | None | Small identity use only after optical proof at 20–32 pt | REPLACE | Simplification derived from approved primary emblem, not an unrelated second bird | Humay-owned production artwork required | Shared preferred | template or original after design review | production artwork required |
| Huma celestial composition | Rejected SwiftUI stage | No Phase 1 use until approved | REMOVE | Optional composition derived from approved emblem | Humay-owned production artwork required | Intentional Light/Dark if added | original | production artwork required |
| Wing / feather submark | Rejected SwiftUI paths | No shipping use | REMOVE | Derive only if approved identity system proves a need | Humay-owned production artwork required | TBD | TBD | production artwork required |
| Compatibility Huma motif | Rejected connection motif | No shipping use | REMOVE | Do not create unless later brand review proves value beyond `person.2`/`heart` | Humay-owned production artwork required | TBD | TBD | production artwork required |

Phase 1 uses no fake bird placeholder. Where brand art was decorative, typography and whitespace replace it. Profile identity uses user initials rather than pretending to be Huma artwork.

## Zodiac glyph family

The former `ZodiacGlyph*` files were DejaVu Sans Unicode outlines exported by Matplotlib. Metadata, generator wrappers, inconsistent ink bounds, and uneven optical weight made that family unsuitable. Their semantics matched Unicode's conventional U+2648–U+2653 zodiac symbols, so the corrective pass retained those meanings and replaced the geometry.

Replacement source: **Noto Sans Symbols 2.003**, weight 400, official Noto project / Google Fonts source, SIL Open Font License 1.1. Vectors are clean, single-path outline exports with standardized optical bounds. They remain template images.

| Semantic name | Catalog name | Current status | Decision | Source/license | Light/Dark | Rendering | Verification |
|---|---|---|---|---|---|---|---|
| Aries | `ZodiacGlyphAries` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Taurus | `ZodiacGlyphTaurus` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Gemini | `ZodiacGlyphGemini` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Cancer | `ZodiacGlyphCancer` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Leo | `ZodiacGlyphLeo` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Virgo | `ZodiacGlyphVirgo` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Libra | `ZodiacGlyphLibra` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Scorpio | `ZodiacGlyphScorpio` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Sagittarius | `ZodiacGlyphSagittarius` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Capricorn | `ZodiacGlyphCapricorn` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Aquarius | `ZodiacGlyphAquarius` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |
| Pisces | `ZodiacGlyphPisces` | Noto production vector | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1 | shared | template | verified |

## Planet and calculated-point glyphs

Humay's production domain currently supports Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, and Pluto. Nodes, Chiron, Lilith, Midheaven, Part of Fortune, and other calculated points are not supported. Presentation sample data additionally uses Ascendant; it remains the established text abbreviation `AC` until the production house/angle methodology is approved.

| Semantic name | Catalog name | Domain support | Decision | Source/license | Rendering | Verification |
|---|---|---:|---|---|---|---|
| Sun | `PlanetGlyphSun` | yes | REPLACE completed | Noto Sans Symbols 2 2.008 / OFL-1.1, U+2609 | template | verified |
| Moon | `PlanetGlyphMoon` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+263D | template | verified |
| Mercury | `PlanetGlyphMercury` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+263F | template | verified |
| Venus | `PlanetGlyphVenus` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+2640 | template | verified |
| Mars | `PlanetGlyphMars` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+2642 | template | verified |
| Jupiter | `PlanetGlyphJupiter` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+2643 | template | verified |
| Saturn | `PlanetGlyphSaturn` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+2644 | template | verified |
| Uranus | `PlanetGlyphUranus` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+2645 | template | verified |
| Neptune | `PlanetGlyphNeptune` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+2646 | template | verified |
| Pluto | `PlanetGlyphPluto` | yes | REPLACE completed | Noto Sans Symbols 2.003 / OFL-1.1, U+2647 | template | verified |
| Ascendant | no catalog asset | sample presentation only | KEEP text | `AC`; no invented glyph | text | verified |
| North Node | deleted `PlanetGlyphNorthNode` | no | REMOVE | unsupported entity | n/a | verified as removed |
| South Node | deleted `PlanetGlyphSouthNode` | no | REMOVE | unsupported entity | n/a | verified as removed |

## Aspect and concept symbols

| Semantic name | Current source/use | Decision | Proposed replacement | Source/license | Rendering | Verification |
|---|---|---|---|---|---|---|
| Conjunction | Typed glyph plus dynamic chart line | ADD/KEEP D | `AspectGlyphConjunction`, U+260C | Noto Sans Symbols 2.003 / OFL-1.1 | template | verified |
| Opposition | Typed glyph plus dynamic chart line | ADD/KEEP D | `AspectGlyphOpposition`, U+260D | Noto Sans Symbols 2.003 / OFL-1.1 | template | verified |
| Square | Typed glyph plus dynamic chart line | ADD/KEEP D | `AspectGlyphSquare`, U+25A1 | Noto Sans Symbols 2 2.008 / OFL-1.1 | template | verified |
| Trine | Typed glyph plus dynamic chart line | ADD/KEEP D | `AspectGlyphTrine`, U+25B3 | Noto Sans Symbols 2 2.008 / OFL-1.1 | template | verified |
| Sextile | Typed glyph plus dynamic chart line | ADD/KEEP D | `AspectGlyphSextile`, U+26B9 | Noto Sans Symbols 2.003 / OFL-1.1 | template | verified |
| Retrograde | Unused `IllustrationRetrograde` | REMOVE | Use conventional retrograde mark only when structured station/retrograde state requires it | TBD before feature use | template | not currently required |
| Eclipse | Unused illustration plus incorrect generic state glyph | REMOVE | No generic astrology glyph; use event copy or real visualization when supported | n/a | n/a | verified as not required |
| Houses | Chart numbers and computed divisions | KEEP D | Number labels and computed house geometry | Humay data visualization | native | verified |
| Transits | No dedicated glyph | KEEP absent | Text plus future real transit visualization | n/a | n/a | verified as not required |
| Synastry | No provider-backed aspects | KEEP absent | Never imply synastry with decorative orbit art | n/a | n/a | verified as unavailable |
| Compatibility | Pair layout and native relationship symbols | REPLACE A completed | SF `person.2` and `heart` where relationship meaning is needed | Apple SF Symbols | system | verified |

## Moon phases

The eight former `MoonPhase*` template vectors were unreachable. Their fill language was also semantically inverted as a family: `MoonPhaseNew` was a filled disk while `MoonPhaseFull` was only an outline, making the tinted area ambiguous. Decision completed: **REMOVE**. If a future screen needs phases, add a coherent, verified family through typed access; iOS 18 SF moon-phase symbols may be evaluated against actual hemisphere/product requirements.

## Root navigation and generic interface icons

| Destination | Current shipping symbol | Decision | Reason | Verification |
|---|---|---|---|---|
| Today | SF `sun.horizon` | KEEP A | Immediate daily/today reading cue | verified |
| Chart | SF `circle.grid.cross` | KEEP A | Clear chart-wheel cue at tab size | verified |
| Explore | SF `safari` | KEEP A | Native discovery/navigation cue | verified |
| Connections | SF `person.2` | KEEP A | People/relationships, not false synastry | verified |
| You | SF `person.crop.circle` | KEEP A | Native profile cue | verified |

The legacy `Nav*` vector family is unreachable and superseded by SF Symbols: **REMOVE**. The legacy `Category*` family is also unreachable; current category controls already have better SF equivalents: **REMOVE**. No third-party icon package is justified, so dependency and binary impact are zero.

## Legacy decorative assets

`Crescent`, `DottedConnector`, `Orbit`, `SparkleFilled`, `SparkleFour`, and `StarCluster` were unreachable generic decorative artwork and have been removed. The five unreachable element glyphs (`Wood`, `Fire`, `Earth`, `Metal`, `Water`) were also removed because no current domain or UI consumes them. Ordinary separators and surface shapes remain native SwiftUI UI chrome; they are not icon artwork.

## Zodiac illustration family

`ZodiacAries` through `ZodiacPisces` are coherent with one another but intentionally cute, object/animal-based, and visually superseded by Premium Celestial. They remain reachable from the existing Daily Horoscope surface, which is outside this corrective Phase 1 propagation pass. Decision: **REPLACE later**, retain temporarily, original rendering, intentional Light/Dark variants. They must never substitute for technical zodiac glyphs.

## Illustration catalog reachability

| Assets | Runtime status | Decision | Notes |
|---|---|---|---|
| `IllustrationCalendarCelestial`, `IllustrationCosmicCoffee`, `IllustrationProfileReveal`, `IllustrationTraditionWestern`, `IllustrationTraditionVedic`, `IllustrationTraditionChinese` | Approved onboarding dependency | KEEP for current onboarding authority | Original rendering; Light/Dark variants. Onboarding migration is out of scope. |
| `IllustrationAskStars` | Ask dependency | KEEP temporarily / REPLACE with later Ask propagation | Existing screen remains out of scope. |
| `IllustrationCurrentSky`, `IllustrationCalendarCelestial` | Current Sky dependency | KEEP temporarily / REPLACE with later Sky propagation | Existing screen remains out of scope. |
| `IllustrationDailyTipCrystalBall`, twelve `Zodiac*` illustrations | Daily Horoscope dependency | KEEP temporarily / REPLACE with later Daily Horoscope propagation | Cute visual language is superseded, but screen migration is not part of this pass. |
| `IllustrationTodayTogether` | Connections people screen dependency | KEEP temporarily / REPLACE with later Connections propagation | Code-drawn connection motif is removed independently. |
| deleted `IllustrationUnknownBirthTime` | Former Phase 1 Chart dependency | REPLACE A completed | Replaced by a neutral SF uncertainty/time symbol and text; the precision warning is no longer decorative. |
| `IllustrationAllCaughtUp`, `IllustrationAskEmpty`, `IllustrationBaZiChart`, `IllustrationCelestialMoon`, `IllustrationCelestialSun`, `IllustrationCompareSystems`, `IllustrationCompatibilityPair`, `IllustrationConjunction`, `IllustrationCosmicWeather`, `IllustrationEclipse`, `IllustrationFullMoon`, `IllustrationMeteorShower`, `IllustrationNewMoon`, `IllustrationNoData`, `IllustrationOffline`, `IllustrationPremiumCelestial`, `IllustrationRetrograde`, `IllustrationRewardUnlock`, `IllustrationRoastMode`, `IllustrationVedicChart`, `IllustrationWesternChart` | No shipping call site after typed-access migration | REMOVE | Reference mockups remain under `docs/design/soulful-reference`; unused shipping copies should not survive. |
| `ProfileRevealConstellationPath` | No shipping call site | REMOVE | Unreachable shipping asset; design references remain in docs. |

## Catalog and rendering rules

- Custom asset names are accessed only through `HumayAsset`; feature views do not construct catalog strings.
- Monochrome zodiac, planet, and aspect glyphs use template rendering and semantic foreground colors.
- Branded/illustrative assets use original rendering.
- Every imageset preserves vector representation.
- SVGs use one clean viewBox, no embedded raster, no text, no filter, no external dependency, and no generator metadata.
- Aspect ratio is always preserved. Optical padding lives in the vector's standardized viewBox, not ad-hoc stretched frames.
- Informational glyphs receive meaning from adjacent text or an explicit accessibility label. Decorative duplicates are hidden.
- Light/Dark variants exist only when composition or contrast genuinely changes.

## License and source record

| Source | Version | Repository | License | Use in Humay | Runtime dependency |
|---|---|---|---|---|---|
| Noto Sans Symbols | 2.003, weight 400 | `https://github.com/notofonts/symbols` | SIL Open Font License 1.1 | Zodiac; Moon, Mercury–Pluto; conjunction, opposition, sextile outlines | None; selected outlines are bundled SVGs |
| Noto Sans Symbols 2 | 2.008 | `https://github.com/notofonts/symbols` | SIL Open Font License 1.1 | Sun, square, and trine outlines | None; selected outlines are bundled SVGs |
| SF Symbols | iOS 18 system library | Apple platform SDK | Apple platform terms | Standard actions, tabs, state, and generic interface concepts only | System-provided |

No third-party Swift package or icon framework is introduced.

## Corrective-pass verification

- All replacement SVGs parse as XML, compile through Xcode's asset catalog, preserve vector representation, and contain no embedded raster, live text, external resource, filter, gradient, or generator metadata.
- Zodiac, planet, and aspect semantics were checked against their conventional Unicode code points; unsupported astrology entities were removed rather than invented.
- Actual-size visual QA passed on standard iPhone Light/Dark, iPhone Pro Max Light, iPad portrait Light, and iPad landscape Light. Review included 16–20 pt inline glyphs, 24 pt symbols, tab icons, chart glyphs, placement detail, compatibility, and empty/state treatments.
- Debug iPhone, Debug iPad, and generic Simulator Release builds passed. Swift Testing passed 113 tests across 13 suites; the complete XCUITest target passed 46 tests with no failures or skips.
- The required survivor search finds `Canvas` and `Path` only in `ChartWheel.swift`; those paths encode houses and aspect geometry from `ChartWheelModel`. No rejected motif type or raw feature-level catalog string remains.
