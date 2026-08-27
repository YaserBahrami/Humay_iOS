# Content Generation Guide — Offline Pack (No API)

Humay runtime never calls an AI API. AI authors **offline source JSON** that is validated, compiled, and bundled.

This tool has **no AI SDK**, no endpoint, no key. Any model may author batches by following this contract.

## Production principle

```
reusable offline content + deterministic Big Three → local personalization → Humay experience
```

No runtime AI. No user-specific content in bundled assets. Quality over shaving 500 KB.

## Deterministic North Star (§58)

```
DETERMINISTIC SCORE/THEME PLAN
        ↓
SMALL AI WRITING BATCH (scores frozen)
        ↓
NO SCORE MODIFICATION
        ↓
STRUCTURAL VALIDATION
        ↓
QUALITY QA (uniqueness, adjacent, coherence, theme streak)
        ↓
SECOND-MODEL REVIEW
        ↓
EXPLICIT APPROVAL (qaStatus = approved)
        ↓
REPRODUCIBLE COMPILER (compact, deterministic)
        ↓
SMALL OFFLINE PACK (≤3 MiB preferred, ≤4 MiB hard)
        ↓
LOCAL BIG THREE PERSONALIZATION
```

## Score plan comes first (§12-16)

Before prose, generate a coherent score/theme skeleton:

```bash
python3 Tools/ContentPack/compile/generate_score_plan.py --mode pilot
python3 Tools/ContentPack/compile/generate_score_plan.py --mode production --seed cycle-2027-v1
```

Output: `Tools/ContentPack/source/scorePlan.pilot.json` (pilot, 168 entries) or `scorePlan.json` (production 366×12, wrapped).

Wrapped production shape:

```json
{
  "schemaVersion": 1,
  "generatorVersion": "humay-score-plan-v1",
  "contentCycleVersion": "cycle-2027-v1",
  "seed": "cycle-2027-v1",
  "createdAt": "2026-08-27T00:00:00Z",
  "mode": "production",
  "entryCount": 4392,
  "entries": [
    {
      "dayKey": "09-14",
      "sunSign": "libra",
      "plan": {
        "primaryTheme": "romance",
        "secondaryTheme": "social",
        "scores": {"overall":73,"romance":81,"social":88,"career":54,"energy":68,"confidence":77,"patience":41,"chaos":62},
        "toneHints": ["high social confidence","low patience"]
      }
    }
  ]
}
```

The writing model receives this skeleton and must write prose consistent with those values.
The AI **must not** change scores, primaryTheme, secondaryTheme. Compiler verifies `record.scores == plan.scores` exactly, and that tags contain the planned themes. The score plan's `contentCycleVersion` must equal `manifest.contentCycleVersion` or compilation fails.

Do not let each batch invent random scores. The score plan is **Humay-original entertainment scaffolding**, not astronomical prediction.

Curves are deterministic waves + jitter: varied per sign, no cheap periodicity, no identical/inverse sign copies, no dominant jitter, median stdev ~15, mean ~54, bounded 10–95.

## Batch contract

Input: a batch request listing day keys + sun signs + their scorePlan slice to author.

Output: JSON array of `SunDayRecord` objects matching `Humay/Domain/ContentPack/ContentPackModels.swift`.

Batch size: **24–36 records per LLM call** is ideal (see §47/48 below). Large 84-record calls sacrifice quality and review. Compiler auto-discovers `source/sun/**/*.json`.

Recommended batch manifest (Phase J, §48):

```
3 days × 12 signs = 36 records/batch  → 122 batches
or 2 days × 12 = 24 records/batch      → 183 batches
```

Prefer `36 (3×12)` for quality/retry balance. Each batch file: `Tools/ContentPack/source/sun/01/batch-036.json` e.g., `01-01_01-03 ×12`.

## Schema (source)

Each Sun record:

```json
{
  "dayKey": "03-02",
  "sunSign": "libra",
  "scores": {"overall":76,"romance":84,"social":88,"career":64,"energy":72,"confidence":91,"patience":37,"chaos":69},
  "tags": ["romance","social"],
  "headline": "You have opinions today. Unfortunately, so does everyone else.",
  "personal": "Your timing in close conversations is unusually good today. The room listens when you don't force it.",
  "love": "Warm, direct, and slightly disarming. Say the smaller true thing.",
  "career": "Progress comes from finishing one thing properly, not starting three.",
  "social": "One invitation deserves a yes. The rest can wait.",
  "greenFlag": "You send the message without rewriting it four times.",
  "redFlag": "You explain a joke that already landed.",
  "summary": "High confidence, low patience. Pick one fight and make it useful."
}
```

Requirements:

- `dayKey` in `MM-DD` (canonical 366-day calendar, includes 02-29)
- `sunSign` in the 12 lowercase values
- `scores` must contain all 8 dimensions, 0–100 (must match the score plan for that day/sign)
- Text lengths: headline ≤120, personal/love/career/social ≤600, flags ≤140, summary ≤280
- Tags: small typed taxonomy: romance, career, social, confidence, patience, energy, chaos, reset, boundaries, communication, focus (compiler validates)
- No year-specific trends, no news, no copyrighted horoscope text
- Humay voice: smart, mischievous, premium, self-aware, slightly chaotic, not childish. Avoid "the universe", "energy" (overuse), "alignment", "manifest", "cosmic", "healing", "journey", crystal-shop language, fake certainty, corporate wellness.
- Summary style: prefer `"High confidence, low patience. Pick one fight and make it useful."` — avoid machine-looking `"Libra 03-14: overall 73, patience 42."`

Prefer: standalone grammatical sentences that compose cleanly when modifiers append one extra sentence.

## Additional layers (thematic fragments)

- **Moon modifiers** (12): `moonSign`, `deltas` (±14), `emotionalFragment` + `fragments: { theme: [variations] }` (8 themes ×3 variants ≈288 fragments, themes: romance/career/social/confidence/patience/chaos/communication/reset)
- **Rising modifiers** (12): `risingSign`, `deltas` (±12), `outwardFragment` + `fragments` (8 themes ×3 variants ≈288)
- **Archetype modifiers** (12): Humay archetype `id`, `deltas` (±10), `fragment` + `fragments` (8 themes ×2 variants ≈192)
- **Copy pools**: green 40–60, red 40–60, reveals 24–40, follow-ups 20–30, roast/reaction pools per personality mode

Resolver selects fragments deterministically from `contentCycleVersion + dayKey + Sun/Moon/Rising/archetypeID + slot + theme` (SHA256, never Swift `hashValue` or Python `hash()`).

Composition policy (resolver, documented & tested):

- Headline: Sun record
- Personal: Sun personal + either Moon OR archetype accent (deterministic rotation, not every day)
- Love: Sun love + Moon romance accent occasionally
- Career: Sun career + archetype/career accent occasionally
- Social: Sun social + Rising accent on selected days
- Scores receive all applicable bounded deltas each day; text rotation is separate (§41).
- Personality mode (Normal/Bestie/Roast/Savage/Delulu/Drama/Soft) never changes scores (§42), only expression.

## Production workflow (required, §46)

1. generate/freeze production score plan: `generate_score_plan.py --mode production --seed cycle-2027-v1`
2. validate score plan: `generate_score_plan.py --check` and `compile.py --mode production --validate`
3. select next generation batch (e.g., `01-01_01-03 ×12 =36` records, mark file)
4. prepare writer prompt with exact score/theme slice (scores + primary/secondary + toneHints + schema + voice)
5. writer generates prose only (scores frozen)
6. save source batch JSON under `source/sun/...`
7. mark `qaStatus: generated` in `source/batches/status.json`
8. structural validation: `compile.py --mode production --validate`
9. mark `validated`
10. QA/repetition/prose-score checks (see `.qa/content-report.json`)
11. independent second-model review (generation model ≠ review model when available, §25)
12. mark `reviewed`
13. explicit approval (human or reviewer model sets `qaStatus: approved`)
14. mark `approved`
15. production compile only when all batches `approved`: `compile.py --mode production --report`

The AI writer is **forbidden** from changing scores, primaryTheme, secondaryTheme.

Batch status canonical field is **`qaStatus`** (§9) with allowed values: `generated | validated | reviewed | approved | rejected`. Production requires `qaStatus == approved` for every batch; missing/unknown/rejected blocks compilation. Pilot remains permissive. Approval is explicit — compiler never auto-approves.

Source records map to batch provenance via `dayKeyRange` + `signs` coverage (§10). Every Sun record must belong to exactly one approved batch; orphan/overlap/empty approved batch fails.

## Batch size reassessment (§47/48)

Empirically, ~84 records (7×12) is too large for high-quality writing in one call (headline+personal+love+career+social+flags+summary ×84 ≈ >25k tokens, coherence drops, retry cost high).

Recommended Phase J batch:

```
3 days × 12 signs = 36 records/batch → 122 batches
or 2 days × 12 = 24 records/batch   → 183 batches
```

Choose 36 (3-day window) as default: easier review, better Git diff, cheaper retry, stays within token limits. Do not optimize for fewest calls.

Batch manifest before Phase J must be deterministic (e.g., `01-01_01-03`, `01-04_01-06`, …). Document it in `source/batches/status.json`.

## Production QA gates (§17-23)

Compiler enforces configurable blocking thresholds (see `compile.py:THRESHOLDS`):

- **Exact duplicates**: identical adjacent-day headline/personal for same sign → error
- **Per-sign uniqueness (§19)** per sign separately:
  - headline ≥0.90, personal ≥0.90, love ≥0.75, career ≥0.75, social ≥0.75
- **Adjacent similarity**: highly similar headline/personal above 0.88 ratio warns (blocked if identical)
- **Near duplicates**: per-sign per-field (headline/personal/love/career/social) token-Jaccard + SequenceMatcher, threshold 0.82
- **Score coherence (§22)**: single jump >40 → error; excessive count of jumps >35 (max 12 per sign/dim) → error
- **Theme streak (§23)**: primary theme longest streak ≥9 → error; ≥6 → warn; plus frequency/missing-overrepresented report
- **Size**: projected pack ≤4 MiB hard, ≤3 MiB preferred WARN if exceeded
- **Modifier coverage (§39)**: Moon/Rising ≥6 themes/sign ≥2 variants/theme (preferred 3); Archetype ≥6 themes/archetype ≥2 variants
- **Modifier QA (§38)**: production rejects placeholder suffixes `(career)`, `[career]`, `— career note.`, identical cross-theme reuse, empty pools
- Copy-pool reuse is intentional and separately identified (flags/reveals/roasts have own reuse rules)

QA report: `.qa/content-report.json` (machine) + `.qa/content-report.md` (human) — not bundled.

## Batch provenance (§10/35)

Runtime manifest stores compact `batches: [{batchID, dayKeyRange, signs, sourceModel, qaStatus, generationMethod}]` (no per-record blow-up). DEBUG can map `dayKey|sunSign → batchID` via range lookup for inspector answer "Which batch created this record?"

Source `source/batches/status.json` is canonical QA source:

```json
{
  "batchID": "01-01_01-03",
  "dayKeyRange": "01-01_01-03",
  "signs": null,
  "sourceModel": "Muse Spark 1.2",
  "generationMethod": "ai-batch-authored",
  "qaStatus": "approved"
}
```

## Manifest & lifecycle (§26-28/45)

Production manifest requires:

```
schemaVersion, packVersion, language, contentCycleVersion, createdAt,
canonicalCalendar, coverage, provenance, compilerVersion,
activeFrom, activeThrough, generationMethod, batches
```

Example recommended initial production cycle:

```json
{
  "packVersion": "1.0.0",
  "contentCycleVersion": "cycle-2027-v1",
  "activeFrom": "2027-01-01T00:00:00Z",
  "activeThrough": "2027-12-31T23:59:59Z",
  "generationMethod": "ai-batch-authored"
}
```

Runtime `manifest.isActive(on:)` checks `activeFrom ≤ date ≤ activeThrough` inclusive through calendar day (UTC). Inactive pack → `BundledContentPackRepository.isAvailable == false` → hybrid falls back to deterministic; DEBUG inspector shows `inactive content pack  activeFrom/through/current`. Pilot remains exempt.

Template file `manifest.production.example.json` shows this shape; actual production manifest will be emitted by compiler when all 4392 records are ready. Do not replace pilot with fake incomplete production pack.

## Provenance & EffectiveForecast (§29-31)

`YearlyForecast.contentSource` records `{kind: bundled|deterministic|mixed, bundledDays, deterministicDays, packVersion, contentCycleVersion}`.
`EffectiveForecast` preserves `{basis, contentSource, counts}` so presentation can inspect source without reconstructing. DEBUG exposes bundled/deterministic/mixed counts, scores, selected fragments, deltas, packVersion, batchID.

Hybrid fallback does not persist deterministic days under bundled identity — yearlyForecast stamps `mixed` correctly; DEBUG inspector exposes truth. Coordinator paths that generate via Hybrid carry deterministic fallback modelIdentifier honestly; stale comment corrected.

## Repository concurrency (§33-34)

`BundledContentPackRepository` is `@unchecked Sendable` with single `NSLock` guarding `_state + indexes` (immutable snapshot after one synchronized initialization). Concurrent first access publishes atomically; subsequent reads copy under lock. No double-initialization races, no per-body decoding.

## Debug inspector (§36)

For a resolved day show: canonical day, Sun/Moon/Rising/archetype, packVersion, contentCycleVersion, pack active/inactive + activeFrom/through/current date, generationMethod, batchID, score-plan primary/secondary theme, chosen Moon/Rising/archetype fragments, score deltas, final scores, bundled/deterministic source. For yearly summary: bundledDays/deterministicDays/totalDays/source kind. DEBUG only.

## Model assignment

Production may use different models per batch. Batches carry provenance as above. Compiled pack stores compact summary; detailed provenance stays in source tooling. Do not put batch provenance inside every SunDayRecord.

## Batch file structure

```
Tools/ContentPack/source/sun/
  01/
    batch-036.json  (01-01_01-03 ×12 =36)
    batch-037.json
  ...

Tools/ContentPack/source/batches/status.json  # batchID, dayKeyRange, signs, model, qaStatus, generationMethod
Tools/ContentPack/source/scorePlan.json       # authoritative wrapped 4392 plan (production)
Tools/ContentPack/source/scorePlan.pilot.json # pilot wrapped 168 plan
```

Compiler discovers `source/sun/**/*.json` and `source/sunBase.json` (legacy pilot) automatically.

## Validation / compilation

```bash
python3 Tools/ContentPack/compile/compile.py --validate --mode pilot
python3 Tools/ContentPack/compile/compile.py --mode production --report
```

Emits:
- `Humay/Resources/ContentPacks/v1/contentPack.json` (minified, deterministic key order)
- `.qa/content-report.json` + `.qa/content-report.md` (dev artifacts, gitignored — not bundled)

Production fails if (strict gates above):

- fewer than 4392 Sun records / any canonical key missing / any sign missing / duplicate day/sign
- Moon/Rising/archetype incomplete or fails modifier QA (placeholder/min coverage)
- manifest lifecycle missing (`contentCycleVersion`, `activeFrom`, `activeThrough`) or generationMethod invalid
- compiled size >4 MiB
- serious duplicate thresholds exceeded / adjacent duplicates / per-sign uniqueness below threshold
- score-plan missing/duplicate/wrong cycle/mismatch Sun vs plan / missing batch provenance
- any batch not `approved`

## Recording provenance

At pack/batch level store:

- `packVersion` (semver)
- `contentCycleVersion` (e.g., `cycle-2027-v1`, with `activeFrom`/`activeThrough`)
- `generationMethod`: `scripted-pilot` | `ai-batch-authored` | `human-curated` | `mixed`
- Batch provenance (see above)
- `sourceModel` / `sourceModelVersion` / `promptVersion` / `generatedAt` / `reviewedByModel`

Do not force one model identifier onto entire production dataset if inaccurate — use `batches`.

## What NOT to do

- Do not add AI SDK dependencies or call any endpoint from the compiler.
- Do not generate 1,728 combination files.
- Do not pre-generate 630,720 daily records.
- Do not use Python `hash()` or Swift `hashValue` for generation/selection.
- Do not append every modifier every day.
- Do not silently ship incomplete production pack relying on deterministic fallback.
- Do not start full 4,392 prose generation in Phase I.2 (§43).
