# Content Generation Guide — Offline Pack (No API)

Humay runtime never calls an AI API. AI authors **offline source JSON** that is validated, compiled, and bundled.

This tool has **no AI SDK**, no endpoint, no key. Any model may author batches by following this contract.

## Production principle

```
reusable offline content + deterministic Big Three → local personalization → Humay experience
```

No runtime AI. No user-specific content in bundled assets. Quality over shaving 500 KB.

## Score plan comes first (Phase J preparation)

Before prose, generate a coherent score/theme skeleton:

```bash
python3 Tools/ContentPack/compile/generate_score_plan.py --mode pilot
python3 Tools/ContentPack/compile/generate_score_plan.py --mode production --seed cycle-2027-v1
```

Output: `Tools/ContentPack/source/scorePlan.pilot.json` (pilot) or `scorePlan.json` (production 366×12).

Each entry:

```json
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
```

The writing model receives this skeleton and must write prose consistent with those values.
Do not let each batch invent random scores. The score plan is **Humay-original entertainment scaffolding**, not astronomical prediction.

## Batch contract

Input: a batch request listing day keys + sun signs + their scorePlan slice to author.

Output: JSON array of `SunDayRecord` objects matching `Humay/Domain/ContentPack/ContentPackModels.swift`.

Batch size: 20–40 records per LLM call is ideal (stay within token limits, allow review).  
Recommended batch files: `Tools/ContentPack/source/sun/03/batch-01.json` (e.g., 01-01_01-07 × 12). Compiler auto-discovers `source/sun/**/*.json`.

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
- Humay voice: smart, mischievous, premium, concise (see below)
- Summary style: prefer `"High confidence, low patience. Pick one fight and make it useful."` — avoid machine-looking `"Libra 03-14: overall 73, patience 42."`

### Voice

Avoid: "the universe says", crystal-shop language, fake certainty, cheesy zodiac clichés on every line, every day chaotic/positive, corporate wellness, aging slang, repeated "Keep the window short." artifacts.

Prefer: standalone grammatical sentences that compose cleanly when modifiers append one extra sentence.

## Additional layers (thematic fragments)

- **Moon modifiers** (12): `moonSign`, `deltas` (±14), `emotionalFragment` (legacy) + `fragments: { theme: [variations] }` (≈6–10 themes × 2–4 variations, e.g., romance, career, social, confidence, patience, chaos)
- **Rising modifiers** (12): `risingSign`, `deltas` (±12), `outwardFragment` + `fragments` (≈6–8 themes)
- **Archetype modifiers** (12): Humay archetype `id`, `deltas` (±10), `fragment` + `fragments` (thematic, used via controlled rotation so archetype does not disappear when Moon exists)
- **Copy pools**: reusable green/red flags, roast lines, reveals

Resolver selects fragments deterministically from `contentCycleVersion + dayKey + Sun/Moon/Rising/archetypeID + slot + theme` (SHA256 / FNV, never Swift `hashValue` or Python `hash()`).

Composition policy (resolver, documented & tested):
- Headline: Sun record
- Personal: Sun personal + either Moon OR archetype accent (deterministic rotation)
- Love: Sun love + Moon romance accent occasionally
- Career: Sun career + archetype/career accent occasionally
- Social: Sun social + Rising accent on selected days
- Scores receive all applicable bounded deltas each day; text rotation is separate.

## Production workflow (required)

1. Generate score/theme skeleton: `generate_score_plan.py --mode production`
2. Select batch: e.g., `01-01_01-07` × 12 = 84 records
3. Author batch with AI (pass score plan slice + schema + voice + length constraints)
4. Structural validation: `python3 Tools/ContentPack/compile/compile.py --mode production --validate`
5. Repetition QA: exact + near duplicates, per-sign, adjacent-day, score coherence (see `.qa/content-report.json`)
6. Score/prose consistency QA: flag romance=18 but "Romance is unstoppable" etc.
7. Second-model review: **generation model ≠ review model** when multiple models available
8. Manual spot check
9. Approve batch: update `source/batches/status.json` (`qaStatus: approved`)
10. Compile production pack: `python3 Tools/ContentPack/compile/compile.py --mode production`

Compiler supports `--mode pilot` (permissive) and `--mode production` (strict).

Production mode fails if:
- fewer than 4392 Sun records / any canonical key missing / any sign missing / duplicate day/sign
- Moon/Rising/archetype incomplete
- manifest lifecycle missing (`contentCycleVersion`, `activeFrom`, `activeThrough`)
- compiled size >4 MiB (preferred ≤3 MiB)
- serious duplicate thresholds exceeded
- score-plan coverage incomplete
- unresolved rejected batches remain

## Model assignment

Production may use different models per batch. Batches carry provenance:

```json
{
  "batchID": "03-01_03-07",
  "dayKeyRange": "03-01_03-07",
  "signs": null,
  "sourceModel": "Muse Spark 1.2",
  "promptVersion": "pack-prompt-v1",
  "generationMethod": "ai-batch-authored",
  "qaStatus": "approved"
}
```

Compiled pack stores compact summary; detailed provenance stays in source tooling. Do not put batch provenance inside every SunDayRecord.

## Batch file structure

```
Tools/ContentPack/source/sun/
  01/
    batch-01.json
    batch-02.json
  02/
    ...

Tools/ContentPack/source/batches/status.json  # batchID, coverage, model, qaStatus
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
