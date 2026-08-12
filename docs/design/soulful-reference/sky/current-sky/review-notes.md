# Current Sky reference-specific design notes

**Status:** REVIEW CANDIDATE — NOT APPROVED

## Chosen direction — Lunar Meridian

The design treats Current Sky as a **celestial editorial dashboard**:

- one lunar-orbit identity moment rather than a sky map;
- editorial headline paired with one quiet factual observation disclosure;
- quiet, factual event rows instead of one illustrated card per event;
- a warm, visually distinct Calendar route inside Sky;
- a short timeline that signals there is more depth without becoming an endless feed.

The hero is deliberately shorter on iPhone than a landing-page illustration. Happening now begins near the first fold, and all major regions remain discoverable in the loaded reference.

## Information hierarchy

### iPhone

Sky header → Debug disclosure → lunar hero → Happening now → Calendar → Coming up → native tab shell.

Happening now uses one shared surface with three rows. Coming up drops the outer card on iPhone and uses date blocks plus a quiet timeline, preventing a stack of nested cards.

### iPad

The header spans both regions. Hero, a one-line observation footer, and Calendar form the primary column. Happening now and Coming up form the secondary column. The large Observation Context card was removed; timezone and freshness now appear once between the hero and Calendar. The sample has no location, so the footer does not invent one. The columns use comparable visual weight without mirroring each other mechanically.

## Light and Dark composition

### Light

- warm cream ground;
- deep ink hero as the screen’s one contrast moment;
- off-white event surface with faint warm hairlines and soft shadow;
- peach-to-lavender Calendar surface;
- cream lunar disc with restrained gold, blue, coral, and lavender orbit markers.

### Dark

- midnight navy ground rather than black;
- raised navy/plum hero, not an inverted Light hero;
- tonal event surfaces and borders with no shadow dependency;
- warmer aubergine Calendar surface;
- gold lunar crescent and brighter coral/lavender/blue accents;
- warm ivory primary text and deliberately lighter secondary text.

## Timing and methodology fixtures

| Form | Reference example | Presentation rule |
|---|---|---|
| Exact instant | `Exact · Today 18:00 TRT` | Clock time plus timezone context. |
| Interval | `Fri 21:00 – Sat 03:00` | Start and end remain visible without a technical interval label. |
| Date-only | `Date only · 14 August` | No clock time is fabricated. |
| Unavailable | `Unavailable · timing not supplied` | Explicit explanation replaces blank space. |

Astronomical, Western, and Vedic remain visible as quiet text badges on every event row for this candidate. Current Sky can mix systems, so methodology clarity outweighs conditional hiding until real content behavior exists. Color helps scan, but the text label carries the meaning. The badge may move below the title at large Dynamic Type sizes.

## Hero copy contract

The hero headline is approved only as a layout role within this review candidate; that limited decision does not approve the package or freeze production copy. Its future production source remains open. Implementation must not derive astrology claims arbitrarily. Later content may come from a Humay-owned presentation projection or an approved interpretation/catalog source.

## Resolved for the current candidate

- Lunar Meridian visual direction retained.
- Methodology labels remain visible on event rows.
- “Window” interval label removed.
- Observation context reduced to quiet secondary metadata.
- Calendar illustration retained as a candidate pending Calendar-family review.
- Internal engineering and design language removed from product surfaces.

## Content stress test represented

- Long title: “Mars enters Gemini after an extended retrograde cycle.”
- Optional summary present: the lunar row.
- Missing summary: the ingress, aspect, and sparse-day examples retain rhythm without an empty gap.
- Multiple current events: three rows in Happening now.
- Sparse event day: explicit final timeline item on iPad.
- Mixed methodology: Astronomical, Western, Vedic.
- Mixed timing: exact, interval, date-only, unavailable.
- Long localized content: rows are designed to expand vertically; fixed one-line truncation is not part of the candidate.

## Asset audit

| Candidate | Decision for this reference | Reason |
|---|---|---|
| `IllustrationCurrentSky` | Rejected for hero | Pleasant but reads as generic placeholder art; lacks the editorial focal structure needed for D3.1. |
| `IllustrationCalendarCelestial` | Retained as candidate in Calendar entry | Clear semantics, compact silhouette, and strong Light/Dark variants. Ownership remains open until the wider Calendar family is reviewed. |
| `IllustrationCelestialMoon` / `IllustrationCelestialSun` | Not used | Friendly Level-B art, but a face in the main hero would make the loaded dashboard too cute. |
| `IllustrationFullMoon` / `IllustrationNewMoon` | Reserved | Suitable only when supplied event data supports the specific phase. |
| `IllustrationRetrograde` / `IllustrationEclipse` / `IllustrationMeteorShower` | Reserved | Too prominent for default rows; useful only for an owning event or later detail surface. |
| Moon-phase glyphs | Recommended candidate for implementation | Semantically useful for compact factual identity after optical-size and contrast review. The reference uses simplified vector equivalents. |
| Planet glyphs | Recommended candidate for implementation | Useful for ingress/aspect identity after checking symbol accuracy and template rendering. |
| `NavSky` | Not reused in the shell reference | The implemented shell currently uses the native `sparkles` symbol; this task does not change navigation assets. |
| Celestial decoration vectors | Selective visual precedent only | Orbit and sparkle language informs the new art; direct decoration density remains intentionally low. |

## Reference-only art

- `elements/current-sky-orbit-light.svg`
- `elements/current-sky-orbit-dark.svg`

The “lunar meridian” art is a restrained symbolic orbit composition. It is not a scientific sky map, does not encode factual positions, and must not move into `Assets.xcassets` without product-owner approval and a later production-export decision.

## State treatments

- Loading: stable skeleton hierarchy and progress treatment; no fake celestial payload.
- Empty: legitimate quiet result with Calendar as the existing useful route.
- Unavailable: explicit methodology/source limitation, no blank card.
- Offline with cache: loaded content remains visible with persistent saved-time disclosure.
- Offline without cache: “No saved sky available” and “Reconnect to view current events.” It remains visually distinct from a sparse/empty sky.
- Failed: “Sky couldn’t load” and “The current sky couldn’t be loaded.” No retry button is promised until the future pipeline owns recovery.
- Any rationale for the absent action sits in the state board’s external annotation area, outside the simulated product surface.

See [states.svg](states.svg) for the board.

## Accessibility and Apple-quality findings

- [x] All visible interactive rows are designed as full-row targets of at least 44 pt.
- [x] Header and profile placement respect current safe-area and shell language.
- [x] Timing and methodology remain understandable without color.
- [x] Light and Dark use separate surface hierarchies rather than inversion.
- [x] Static contrast audit: Light primary/ground 16.14:1, Light secondary/ground 5.90:1, Dark primary/ground 15.82:1, and Dark secondary/ground 9.68:1.
- [x] Small Light accent metadata uses contrast-safe tonal variants (5.40:1–6.48:1) while preserving the approved accent hue; Dark accent text ranges from 5.55:1–8.01:1 on event surfaces.
- [x] VoiceOver reading order and combined row labels are defined in `adaptive-notes.md`.
- [x] The interval fixture reads as “From Friday at 21:00 until Saturday at 03:00” in VoiceOver rather than exposing “Window.”
- [x] Decorative hero art has no factual responsibility and should be hidden from VoiceOver.
- [x] Dynamic Type reflow rules preserve timing, methodology, and long titles.
- [x] Reduce Motion leaves a complete static composition.
- [x] iPad pointer and keyboard focus apply to full native rows.
- [ ] Final Increase Contrast and device Accessibility Inspector checks remain implementation-time work; a static SVG cannot validate runtime semantic colors or focus behavior.

No numerical HIG score is assigned.

## Unresolved or deferred

1. Production source of the hero editorial copy.
2. Exact recovery actions once `SKY-002` exists.
3. Final Calendar-family behavior and artwork ownership.

Only the product owner can resolve visual approval. No production implementation should begin from this candidate before that review.
