# Content Generation Guide — Offline Pack (No API)

Humay runtime never calls an AI API. AI authors **offline source JSON** that is validated, compiled, and bundled.

This tool has **no AI SDK**, no endpoint, no key. Any model may author batches by following this contract.

## Batch contract

Input: a batch request listing day keys + sun signs to author.

Output: JSON array of `SunDayRecord` objects matching `Humay/Domain/ContentPack/ContentPackModels.swift`.

Batch size: 20–40 records per LLM call is ideal (stay within token limits, allow review).

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
  "summary": "Warm social weather with a thin patience layer."
}
```

Requirements:

- `dayKey` in `MM-DD` (canonical 366-day calendar, includes 02-29)
- `sunSign` in the 12 lowercase values
- `scores` must contain all 8 dimensions, 0–100
- Text lengths: headline ≤120, personal/love/career/social ≤600, flags ≤140, summary ≤280
- No year-specific trends, no news, no copyrighted horoscope text
- Humay voice: smart, mischievous, premium, concise (see below)

### Voice

Avoid: "the universe says", crystal-shop language, fake certainty, cheesy zodiac clichés on every line, every day chaotic/positive, corporate wellness, aging slang.

Prefer: standalone grammatical sentences that compose cleanly when modifiers append one extra sentence.

## Additional layers

- **Moon modifiers** (12): `moonSign`, `deltas` (±14 per dimension), `emotionalFragment` (≤180 chars, e.g., "You're processing feelings like they need quarterly approval.")
- **Rising modifiers** (12): same shape, `outwardFragment` (≤180 chars, e.g., "Your first impression today is approximately 'move.'")
- **Archetype modifiers** (12): Humay archetype `id`, `deltas` (±10), `fragment` (≤160 chars)
- **Copy pools**: reusable green/red flags, roast lines, reveals (deduplicated; keep pools small)

## Workflow

1. Pick a batch: e.g., 3 consecutive day keys × 12 signs = 36 records.
2. Prompt (record `promptVersion` in manifest.provenance):
   ```
   Author SunDayRecords for dayKeys [03-01, 03-02, 03-03] × all 12 signs.
   Schema: <paste SunDayRecord JSON schema>
   Voice: <paste voice notes>
   Constraints: <paste length & score rules>
   Output: JSON array only, no prose.
   ```
3. Save output to `Tools/ContentPack/source/sunBase.json` (append or replace).
4. Validate:
   ```bash
   python3 Tools/ContentPack/compile/compile.py --validate
   ```
5. Compile:
   ```bash
   python3 Tools/ContentPack/compile/compile.py
   ```
6. QA: check `compile.py --report` for repetition warnings and size projection.
7. Record provenance in `source/manifest.json`:
   ```json
   "provenance": {
     "sourceModel": "Muse Spark 1.2",
     "sourceModelVersion": "2026-08",
     "promptVersion": "pack-prompt-v1",
     "contentLanguage": "en"
   }
   ```

## Validation command

```bash
python3 Tools/ContentPack/compile/compile.py --validate
```

Fails if:

- duplicate `dayKey|sunSign`
- missing dimensions or scores out of range
- string too long / empty required text
- invalid sign / dayKey
- modifier delta out of bounds
- excessive identical headlines / reading paragraphs (reported as warnings)

## Compilation command

```bash
python3 Tools/ContentPack/compile/compile.py
```

Emits:

- `Humay/Resources/ContentPacks/v1/contentPack.json` (minified, deterministic key order)
- Updates manifest `compilerVersion`, `createdAt`, `coverage`

## Recording provenance

At pack/batch level (not per record) store:

- `packVersion` (semver, e.g., "1.0.0-pilot")
- `sourceModel` / `sourceModelVersion`
- `promptVersion`
- `generatedAt` / `reviewedAt`

This provenance is copied into the compiled manifest and into Swift provenance at runtime.

## What NOT to do

- Do not add AI SDK dependencies.
- Do not call any endpoint from the compiler.
- Do not generate 1,728 combination files (libra-capricorn-aries.json etc.).
- Do not pre-generate 630,720 daily records.
