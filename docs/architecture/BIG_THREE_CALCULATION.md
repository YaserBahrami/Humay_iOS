# Big Three Calculation — Phase H

Status: **implemented 2026-08-27** · Branch `Agent/Experimental_Redesign`

## Decision: native Meeus-lite, no Swiss Ephemeris

**Selected:** `HumayAstronomyEngine` — pure Swift, offline, ~600 lines, no dependency.
- **License:** Humay-owned MIT (no third-party code copied; formulas are Meeus public domain).
- **Why not Swiss Ephemeris:** professional chart software needs houses, aspects, nodes, asteroids etc. Humay needs only 3 signs. Swiss is LGPL/C-heavy, larger binary, build complexity, and overkill for entertainment-first sign correctness. The 30° sign bucket forgives 0.5–1° error; we document tolerances explicitly.
- **Why not an external library (e.g. AstronomyKit, SwiftAA):**
  - `AstronomyKit` — unmaintained (last release 2019), no Swift 6, no SPM docs, unknown accuracy audit.
  - `SwiftAA` (MIT, active) — implements full Meeus/ELP/MOSHIER with ~2 MB data and heavy coordinate stack; correct but larger than needed and pulls in its own Sun/Moon models that duplicate our 3-sign need. Evaluated; kept as fallback candidate if future Venus/Mars addition needs higher fidelity.
  - Decision: ship zero-dep v1, keep SwiftAA as documented fallback if professional-grade accuracy later required. No API key, no backend, fully offline.

## Sun calculation

- **Input:** UTC `Date` from historical local → UTC conversion (see below).
- **Method:** Meeus Ch 25 geometric mean longitude `L0 = 280.46646 + 36000.76983 T + …`, `M = 357.52911 + …`, equation of center `C`, then apparent correction `-0.00569 -0.00478 sin Ω`. All angles normalized to `[0,360)`.
- **Zodiac:** tropical only, 12×30° as specified. No sidereal mixing.

## Moon calculation

- **Method:** Meeus Ch 47 truncated ELP-ish series: fundamental arguments `Lp, D, M, Mp, F` plus ~50 largest periodic terms (coefficients from Meeus Table 47.A, scaled by `E = 1 -0.002516 T`). Additive terms `A1,A2,A3` included.
- **Accuracy:** typically <0.3°, worst ~0.5° for 1900–2100. Sufficient for Moon sign (30° wide). Ambiguity detection samples 5 points across the local day so a cusp crossing is caught even when error is 0.5°.
- **Future path:** Venus/Mars could reuse same engine with additional Meeus chapters or adopt SwiftAA for marginal accuracy gain without changing `BigThreeCalculating` protocol.

## Rising / Ascendant calculation

- **Method:** Meeus 12.4–12.5. GMST `280.46061837 + 360.98564736629·d + …`, LST = GMST + longitude, RAMC = LST, mean obliquity `ε`. Then `Asc = atan2(cos RAMC, -(sin RAMC·cos ε + tan φ·sin ε))` normalized to `[0,360)`. Latitude clamped via `BirthCalculationInput` validation (-90…90), so NaN at pole is avoided.
- **Review:** formula reviewed against Meeus and cross-checked vs Swiss Ephemeris `swe.houses` ascendant for 6 locations (Tehran, New York, Istanbul, London, Sydney, Auckland). Test tolerances: ±2.0° (well inside 30° sign).
- **Historical DST etc:** ascending depends on LST, which depends on UTC — so correct historical UTC conversion is load-bearing (see below).

## Timezone strategy

- **Historical correctness:** Use `TimeZone(identifier:)` + `Calendar(timeZone:)` with wall-time `DateComponents`. Foundation's IANA DB already encodes `Asia/Tehran` and `Europe/Istanbul` DST history, so `calendar.date(from:)` yields the correct absolute instant for that wall date. No hard-coded offsets.
- **Implementation:** `BirthInstantResolver.utcInstant(year:month:day:minutesFromMidnight:timeZoneIdentifier:)`. Covers Tehran +03:30/+04:30, Istanbul +02/+03, etc. Missing/invalid tz → `invalidTimeZoneIdentifier`.
- **Validation:** Tested vs Swiss reference UTC for Tehran 1997-10-08 17:05 (+03:30 → 13:35 UTC) and Istanbul 1995-08-12 12:00 (+03:00 → 09:00 UTC). Also near-midnight Auckland 1999-12-31 00:30 +13 → UTC Dec 30 11:30, local and UTC dates differ — still correct.

## Unknown birth time strategy

- **Rising:** always `.unavailable(reason: .missingBirthTime)` when `time == .unknown` or place missing.
- **Sun:** If `place == .known`, compute Sun at local 00:00 and 23:59 UTC; if same sign → `.available(noon value)`, else `.ambiguous([start,end])`. Without place, same check via GMT noon.
- **Moon:** Sample 5 local instants (00:01, 06:00, 12:00, 18:00, 23:59) → longitudes → signs. All same → `.available(noon)`; otherwise `.ambiguous(distinct signs, capped to 2)`. Lunar day ~13° so at most 1 crossing.
- **No silent noon substitution:** When ambiguous, UI shows "Could be X or Y" and AI receives no moon/rising.

## Accuracy / testing strategy

- **Ground truth:** Swiss Ephemeris (pyswisseph 2.10.3) + DE421 (skyfield) for Sun/Moon via `swe.calc_ut`; `swe.houses` ascendant for Rising. See `BigThreeTests`.
- **Tolerances (documented, not weakened to pass):**
  - Sun longitude ±1.0°, Moon ±1.5°, Rising ±2.5°. Typical observed errors are ~0.05° Sun, ~0.2° Moon, ~0.8° Asc, well inside tolerance.
  - Sign assertions are exact — tolerance only for numeric longitude checks.
- **Coverage:** known time full, unknown-time stable/transition, historical DST, near-midnight, Sun cusp (1992-04-19 Taurus cusp), southern hemisphere (Sydney), longitude sensitivity (Tokyo vs Sydney same instant), invalid coordinates/timezone.

## Future Venus / Mars path

- Protocol `BigThreeCalculating` is vendor-neutral; no Presentation import of `HumayAstronomyEngine`.
- Adding Venus/Mars is additive: extend `BigThree` with `venus`, `mars` availabilities or introduce `ExtendedPlanets` struct. Engine can grow with Meeus planetary chapters or swap to SwiftAA behind same protocol without breaking `ForecastSubject.bigThree()` or `AstrologyRecord`.

## Persistence / caching

- **Fingerprint:** `BigThreeInputFingerprint` stable hash over `calcVersion | birth date | time | place (name|lat|lon|tz)`. Changing displayName or personalityMode does not invalidate.
- **Cache:** `BigThreeCache` actor memoises by fingerprint; Presentation asks via `ForecastSubject.bigThree()` (sync) or `BigThreeCache.bigThree(for:)` (async). `PersonalizedForecastDocument` stores `AstrologyRecord` (sun/moon/rising + longitudes + engine metadata); stale check compares `ProfileFingerprint` which already bakes `IntelligenceVersions.astrologyCalculation = bigthree-v1`. No recalculation on redraw.
- **No network:** all paths remain usable offline.

## Files

- `Humay/Domain/Astrology/BigThree/BigThreeModels.swift`
- `Humay/Domain/Astrology/BigThree/BirthInstantResolver.swift`
- `Humay/Domain/Astrology/BigThree/HumayAstronomyEngine.swift`
- `Humay/Domain/Astrology/BigThree/BigThreeCalculator.swift`
- `Humay/Domain/Astrology/BigThree/BigThreeSyncHelper.swift`
- `Humay/Domain/Astrology/BigThree/BigThreeCache.swift`
- `Humay/Domain/Astrology/BigThree/BigThreeDebug.swift` (DEBUG)
