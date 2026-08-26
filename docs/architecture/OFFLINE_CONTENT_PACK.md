# Offline AI Content Pack — Architecture (Phase I)

## Why no runtime AI

Humay is entertainment-first. Requiring an AI API at runtime would demand keys, network, latency, and a backend — antithetical to offline delight and to our cost/privacy posture. The production loop is:

```
AI AUTHORS ONCE (development time)
        ↓ validates & compiles
Bundled Content Pack (versioned JSON, ≤3 MiB)
        ↓ Big Three selects & modifies
Offline resolver (local, deterministic, 0 network calls)
```

The app never knows which AI model authored the content, never holds an API key, never contacts an endpoint.

## Why no 1,728 combination table

Full combinatorial storage would be `12 Sun × 12 Moon × 12 Rising × 366 = 630,720` daily records — huge, repetitive, and hard to author/validate. Humay instead stores:

- **Daily Sun base**: `366 × 12 = 4,392` records (AI-authored, entertainment copy)
- **Moon modifiers**: 12 (deltas + reusable fragment)
- **Rising modifiers**: 12
- **Archetype modifiers**: 12
- **Copy pools**: shared reusable lines (flags, roasts, reveals)

Personalization composes at runtime: `Sun base (+ Moon delta ×0.55 + Rising delta ×0.45 + Archetype delta ×0.40)`, clamped `0…100`. Text composes as Sun primary paragraph + at most one compatible modifier sentence (Moon/Rising), never mad-lib concatenation.

No `libra-capricorn-aries.json` files ever exist.

## Canonical 366-day calendar

Pack keys are `MM-DD` (e.g., `03-15`), 366 possibilities including `02-29`. Non-leap years never request `02-29`. This lets one annual pack power Today, tomorrow, 30-day previews, and a full year timeline across any calendar year without per-year datasets. Weekday/year/timeline position remain local via `ForecastAnchor` → civil date mapping.

Leap handling: `CanonicalDayKey.from(date:)` derives from a real `Date`; rolling `ForecastAnchor.date(forDayOffset:)` walks a real Gregorian calendar, so Feb 27–Mar 3 sequences naturally produce `02-27,02-28,02-29,03-01,03-02` in leap years and skip `02-29` otherwise.

## Source vs compiled assets

```
Tools/ContentPack/source/        ← readable, reviewable, AI-friendly (not in app)
  manifest.json
  sunBase.json
  moonModifiers.json
  risingModifiers.json
  archetypeModifiers.json
  copyPools.json

Humay/Resources/ContentPacks/v1/
  contentPack.json                ← minified, validated, bundled (in app)
  # (compiler may split files; repository merges)
```

Source uses long descriptive keys; compiled uses compact keys (`k`, `s`, `sc` as `[8]` array, `h`, `p`, …) and score deltas as ordered arrays to meet size budget. Swift decodes both (long for source validation, short for runtime). String intern/dedup is reserved for future flag interning if needed.

## Schema / versioning

`ContentPackManifest.schemaVersion` (current `1`) is the sole invalidation gate. `packVersion` is semver (`1.0.0-pilot`), `contentCycleVersion` identifies the authoring cycle, `language` is `en` (future `fa`, `tr` packs parallel this shape), `compilerVersion` is `humay-pack-compiler-v1`. `Coverage` records `isPilot`, `dayKeyCount`, `sunRecordCount`, `includesLeapDay`. Provenance (`sourceModel`, `promptVersion`, `generatedAt`) lives at manifest level, not per record.

`CompiledContentPack.validate()` enforces: unique `dayKey|sunSign`, score `0…100`, text lengths (`headline ≤120`, `reading ≤600`, `flag ≤140`), delta bounds (`Moon ±14`, `Rising ±12`, `Archetype ±10`), and manifest schema. Corrupt/missing packs fail open.

## Fallback strategy

Pilot covers only 14 days; production will cover 366. `HybridOfflineContentProvider(primary: BundledAIContentProvider, fallback: DeterministicContentProvider)` is the composition used by `ForecastGenerationCoordinator` and `ForecastStore.fallbackForecast`.

- Bundled hit → `ContentBasis.aiGenerated(modelIdentifier: "bundled-ai-v1")`, scores/text from resolver.
- Missing day (pilot gap) → deterministic fallback, `ContentBasis.entertainmentFixture`.
- Corrupt/unsupported pack → `BundledContentPackRepository.State.failed`, hybrid falls through to deterministic — never crashes, logs load error for DEBUG inspector.

Provenance is explicit; deterministic fallback is never labeled AI.

## Size budget

Target `≤2 MiB` uncompressed, hard ceiling `≤3 MiB` for the full `4392 + 36 + pools` English pack (`Tools/ContentPack/compile/compile.py --report`).

Pilot (14×12) actuals:

- Source `~161 KiB`, compiled `~104 KiB`, `≈596 bytes/sunRecord`.
- Projected full Sun bytes `≈2.56 MiB` + modifiers/copy `~32 KiB` ⇒ `≈2.5 MiB` total (passes `≤3 MiB`; flag interning would bring toward `≤2 MiB` for production).

Compiler reports `sourceBytes`, `compiledBytes`, `bytesPerSunRecord`, `modifierBytes`, and `projectedTotalMiB = avgSun * 4392 + overhead`.

## Generation workflow

No SDK/API in the tool. Any model may author batches (20–40 records) following `Tools/ContentPack/GENERATION_GUIDE.md`:

1. Batch contract + schema + prompt version + voice notes.
2. Produce JSON array of `SunDayRecord` (or modifier) objects.
3. Append to `source/*.json`, record `provenance` (`sourceModel`, `promptVersion`).
4. `python3 Tools/ContentPack/compile/compile.py --validate` (non-zero on error).
5. `python3 Tools/ContentPack/compile/compile.py` → emits `Humay/Resources/ContentPacks/v1/contentPack.json`.
6. `--report` shows repetition warnings and size projection.

## Future

- **Full-year generation**: repeat batched authoring until 366×12, rerun compiler; no app change.
- **Localization**: new `language` + `contentCycleVersion` packs under `Resources/ContentPacks/<lang>/vX/`; runtime selects by `Locale`.
- **Trend overlays**: separate small additive layer (non-canonical), fetched later without bloating base pack.
