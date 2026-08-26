# Humay Offline Content Pack — Tools

Production architecture:

```
  DEVELOPMENT TIME                APP RUNTIME
  AI authors source JSON  →  compile →  bundled JSON → resolver → personalized Today/Year
                                         no AI calls, no backend, no keys
```

## Layout

```
Tools/ContentPack/
  README.md                ← this file
  GENERATION_GUIDE.md      ← authoring workflow for ANY AI model
  schema/                  ← JSON Schema references (informal, Swift is source of truth)
  source/                  ← human-readable source (AI-generation friendly, reviewable)
    manifest.json
    sunBase.json
    moonModifiers.json
    risingModifiers.json
    archetypeModifiers.json
    copyPools.json
  compile/
    compile.py             ← validator + compiler (Python 3, stdlib only)

Humay/Resources/ContentPacks/v1/
  contentPack.json         ← compiled minified bundle (copied into app)
```

## Source vs compiled

- **Source**: readable, descriptive keys, reviewable in Git, not in app target.
- **Compiled**: validated, minified, checksummed, only files in app bundle. Must be ≤ 3 MiB for eventual full pack.

## Commands

```bash
# Validate only
python3 Tools/ContentPack/compile/compile.py --validate

# Compile (validate + emit)
python3 Tools/ContentPack/compile/compile.py

# Validate + show size breakdown
python3 Tools/ContentPack/compile/compile.py --report
```

Exit non-zero on validation errors.

## Size budget

- Target: ≤ 2 MiB uncompressed bundled JSON for full 366×12 pack
- Hard ceiling: ≤ 3 MiB
- Pilot (14×12) is small; the compiler projects full-pack size linearly from average `bytesPerSunRecord`.

See `compile.py --report` for breakdown.

## Manifest

Single source of truth for `schemaVersion`, `packVersion`, `language`, `compilerVersion`, `provenance`.
The Swift type `ContentPackManifest` (Domain/ContentPack/ContentPackManifest.swift) is authoritative; this README tracks it loosely.
