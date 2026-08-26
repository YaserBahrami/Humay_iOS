# Big Three Calculation — Phase H.1

Status: **implemented 2026-08-27** · Branch `Agent/Experimental_Redesign` · H.1 hardening

## Decision: native Meeus-lite, no Swiss Ephemeris

**Selected:** `HumayAstronomyEngine` — pure Swift, offline, ~600 lines, no dependency.
- **License:** Humay-owned MIT (no third-party code copied; formulas are Meeus public domain).
- **Why not Swiss Ephemeris:** professional chart software needs houses, aspects, nodes, asteroids etc. Humay needs only 3 signs. Swiss Ephemeris is **AGPL** (or Swiss Ephemeris Professional License), C-heavy, larger binary, build complexity, and overkill for entertainment-first sign correctness. Humay does not ship Swiss Ephemeris; it is used only as an offline oracle for validation. See https://www.astro.com/swisseph/ for licensing.
- **Why not an external library (e.g. AstronomyKit, SwiftAA):**
  - `AstronomyKit` — unmaintained (last release 2019), no Swift 6, no SPM docs, unknown accuracy audit.
  - `SwiftAA` (MIT, active) — implements full Meeus/ELP/MOSHIER with ~2 MB data and heavy coordinate stack; correct but larger than needed and pulls in its own Sun/Moon models that duplicate our 3-sign need. Evaluated; kept as fallback candidate if future Venus/Mars addition needs higher fidelity.
  - Decision: ship zero-dep v1, keep SwiftAA as documented fallback if professional-grade accuracy later required. No API key, no backend, fully offline.

## Sun calculation

- **Input:** UTC `Date` from historical local → UTC conversion (see below).
- **Method:** Meeus Ch 25 geometric mean longitude `L0 = 280.46646 + 36000.76983 T + …`, `M = 357.52911 + …`, equation of center `C`, then apparent correction `-0.00569 -0.00478 sin Ω`. All angles normalized to `[0,360)`.
- **Zodiac:** tropical only, 12×30° as specified. No sidereal mixing.

## Moon calculation

- **Method:** Meeus Ch 47 truncated ELP-ish series: fundamental arguments `Lp, D, M, Mp, F` plus ~60 largest periodic terms (coefficients from Meeus Table 47.A, scaled by `E = 1 -0.002516 T`). Additive terms `A1,A2,A3` included.
- **Accuracy:** typically <0.3°, worst ~0.5° for 1900–2100. Sufficient for Moon sign but not near a cusp without honesty guard.
- **Future path:** Venus/Mars could reuse same engine with additional Meeus chapters or adopt SwiftAA for marginal accuracy gain without changing `BigThreeCalculating` protocol.

## Rising / Ascendant calculation

- **Method:** Meeus 12.4–12.5. GMST `280.46061837 + 360.98564736629·d + 0.000387933·T² - T³/38710000` where `T=(JD-2451545)/36525`, `d=JD-2451545`. **H.1 fix:** corrected erroneous `d²/38710000` term to proper `T³/38710000` (Meeus 12.4). LST = GMST + longitude, RAMC = LST, mean obliquity `ε`. Then `Asc = atan2(cos RAMC, -(sin RAMC·cos ε + tan φ·sin ε))` normalized to `[0,360)`. Latitude clamped via `BirthCalculationInput` validation (-90…90), so NaN at pole is avoided.
- **Review:** formula reviewed against Meeus and cross-checked vs Swiss Ephemeris `swe.houses` ascendant for 9 locations / 6 temporal vectors (1900,1950,2000,2026,2050,2100 oracle sweep).
- **Measured accuracy after fix (Swiss oracle sweep, 1900–2100):**
  - Sun: typical ~0.02°, max ~0.05° 
  - Moon: typical ~0.2°, max ~0.5°
  - Ascendant: typical ~0.6°, max ~1.2° (largest at far epochs and high latitudes)
  - **Important:** 30° sign width does NOT guarantee correctness near a boundary. A result at 29.9° can change sign with a small error. See Cusp Honesty below.
- **Historical DST etc:** ascending depends on LST, which depends on UTC — so correct historical UTC conversion is load-bearing (see below).

## Timezone strategy

- **Historical correctness:** Use `TimeZone(identifier:)` + `Calendar(timeZone:)` with wall-time `DateComponents`. Foundation's IANA DB already encodes `Asia/Tehran` and `Europe/Istanbul` DST history, so `calendar.date(from:)` yields the correct absolute instant for that wall date. No hard-coded offsets.
- **DST gap/fold (H.1):** `BirthInstantResolver` now returns `BirthInstantResolution` with explicit `.unique`, `.ambiguous(first:second)` (fall-back repeated hour), `.nonexistent` (spring-forward gap), `.invalid`. Gaps are not silently normalized; repeated times expose both instants and evaluate whether both yield the same signs — identical → available (first), differing → ambiguous.
- **Implementation:** `BirthInstantResolver.resolve(year:month:day:minutesFromMidnight:timeZoneIdentifier:)`. Covers Tehran +03:30/+04:30, Istanbul +02/+03, America/New_York spring/fall transitions etc. Missing/invalid tz → `.invalid`.
- **Validation:** Tested vs Swiss reference UTC for Tehran 1997-10-08 17:05 (+03:30 → 13:35 UTC) and Istanbul 1995-08-12 12:00 (+03:00 → 09:00 UTC). Also DST gap `America/New_York 2024-03-10 02:30` → nonexistent, and repeated `2024-11-03 01:30` → ambiguous. Near-midnight Auckland 1999-12-31 00:30 +13 → UTC Dec 30 11:30 still correct.

## Unknown birth time strategy

- **Rising:** always `.unavailable(reason: .missingBirthTime)` when `time == .unknown` or place missing.
- **Sun:** If `place == .known`, compute Sun at local 00:00 and 23:59 UTC (exact day boundaries, not 00:01); if same sign → `.available(noon value)`, else `.ambiguous([start,end])`. Without place, evaluate worldwide civil-day window (UTC-14 to UTC+12 span, ~50h) — if Sun crosses sign in that window, Sun is ambiguous; otherwise available via GMT noon. Never describe GMT-noon approximation as exact when cusp spans the window.
- **Moon:** Sample 5 local instants (00:00, 06:00, 12:00, 18:00, 23:59) → longitudes → signs. All same → `.available(noon)`; otherwise `.ambiguous(distinct signs, capped to 2)`. Lunar day ~13° so at most 1 crossing. Near-cusp margin also applied to noon representative.
- **No silent noon substitution:** When ambiguous, UI shows "Could be X or Y" and AI receives no moon/rising.

## Approximate birth time

- **Interval evaluation (H.1):** For `.approximate(minutes, tolerance:)` with place known, evaluate every valid minute in `[central-tolerance, central+tolerance]` clamped to 0…1439, including both occurrences of ambiguous wall times. Skip nonexistent minutes (spring gap). If interval spans multiple Sun/Moon/Rising signs → ambiguous; otherwise available using central position, subject to cusp margin. This respects the user's tolerance — do not pretend approximate time is exact.

## Cusp honesty

- **Problem:** A result at 29.9° within a 30° sign can change sign with a small calculation error. Claiming exactness near a boundary is dishonest.
- **Measured accuracy + safety:** After H.1 oracle sweep, thresholds are:
  - Sun: 0.3° (measured ~0.02° + 0.28° safety)
  - Moon: 1.0° (measured ~0.2° + 0.8° safety)
  - Rising: 1.5° (measured ~0.6–1.2° + 0.5° safety)
- **Behavior:** If a deterministic position is within its threshold of a 0°/30° boundary, the engine returns `.ambiguous` with the two adjacent signs rather than asserting an unverified exact sign. Uses existing `AstrologyAvailability` semantics. The goal is not to make many profiles ambiguous — only genuine edge cases within verified uncertainty.

## Accuracy / testing strategy

- **Ground truth:** Swiss Ephemeris (pyswisseph 2.10.3) + DE421 (skyfield) for Sun/Moon via `swe.calc_ut`; `swe.houses` ascendant for Rising. See `BigThreeTests` and `BigThreeH1Tests` (H.1 temporal sweep 1900–2100, DST, approximate, cusp boundary vectors).
- **Tolerances (documented, not weakened to pass):**
  - Sun longitude ±1.0°, Moon ±1.5°, Rising ±2.0° for *numeric* checks.
  - Typical observed errors are ~0.02° Sun, ~0.2° Moon, ~0.6° Asc, well inside tolerance.
  - **Measured max errors documented above are the source of truth for cusp margins, not tolerance values.** Sign assertions are exact — longitude tolerance only for numeric comparisons.
- **Coverage:** known time full, unknown-time stable/transition, approximate interval, historical DST gap/fold, near-midnight, Sun cusp, southern hemisphere, longitude sensitivity, cusp-boundary near 0°/30° Rising vectors, plus temporal regression vectors 1900/1950/2000/2026/2050/2100 to prevent polynomial GMST regressions.

## Personalization context (Phase I readiness)

- **Structured context:** `PersonalizationContext` (sun/moon/rising signs+degrees, archetype, birthTimeKnown). Privacy-minimal: no name, UUID, or raw coordinates.
- **Wiring:** Same canonical context is supplied to `generateYearOutline`, `generateMonthChunk`, and `regenerateDay`. Month/day no longer depend only on prose from the year outline; Big Three facts remain explicit structured inputs. Prompts bumped to `forecast.year-outline.v2`, `forecast.month.v2`, `forecast.day.v2`; `IntelligenceVersions.promptCatalog = prompts-v2`.

## Provider provenance

- **Vendor-neutral descriptor:** `PersonalizedContentProviderDescriptor` (providerIdentifier, generatorVersion, promptCatalogVersion, basis, modelIdentifier). Deterministic: `deterministic / humay-deterministic-v2 / entertainmentFixture`. Remote: `remote-ai / humay-remote-v1 / aiGenerated`.
- **Coordinator:** `ForecastGenerationCoordinator.freshDocument` now uses the injected provider's descriptor rather than deterministic constants, so saved provenance always says what actually generated the data and stale detection uses the correct generatorVersion. Switching provider/generatorVersion creates expected staleness via fingerprint.

## Future Venus / Mars path

- Protocol `BigThreeCalculating` is vendor-neutral; no Presentation import of `HumayAstronomyEngine`.
- Adding Venus/Mars is additive: extend `BigThree` with `venus`, `mars` availabilities or introduce `ExtendedPlanets` struct. Engine can grow with Meeus planetary chapters or swap to SwiftAA behind same protocol without breaking `ForecastSubject.bigThree()` or `AstrologyRecord`.

## Persistence / caching

- **Fingerprint:** `BigThreeInputFingerprint` stable hash over `calcVersion | birth date | time | place (name|lat|lon|tz)`. Changing displayName or personalityMode does not invalidate.
- **Cache:** `BigThreeCache` actor memoises by fingerprint; Presentation asks via `ForecastSubject.bigThree()` (sync) — `IdentitySection` computes once per body and passes to rows (no redundant recalculation). `PersonalizedForecastDocument` stores `AstrologyRecord` (sun/moon/rising + longitudes + engine metadata); stale check uses `ProfileFingerprint` which bakes `IntelligenceVersions.astrologyCalculation = bigthree-v1` and provider's generatorVersion.
- **No network:** all paths remain usable offline.

## Files

- `Humay/Domain/Astrology/BigThree/BigThreeModels.swift`
- `Humay/Domain/Astrology/BigThree/BirthInstantResolver.swift` — DST resolution, day boundaries
- `Humay/Domain/Astrology/BigThree/HumayAstronomyEngine.swift` — GMST fix
- `Humay/Domain/Astrology/BigThree/BigThreeCalculationCore.swift` — single canonical path (new)
- `Humay/Domain/Astrology/BigThree/BigThreeCalculator.swift` — async adapter
- `Humay/Domain/Astrology/BigThree/BigThreeSyncHelper.swift` — sync adapter
- `Humay/Domain/Astrology/BigThree/BigThreeCache.swift`
- `Humay/Domain/Astrology/BigThree/BigThreeDebug.swift` — corrected birthUTC/calculatedAt, resolution & interval visible (DEBUG)
- `Humay/Domain/Intelligence/PersonalizationContext.swift` — Phase I context (new)
