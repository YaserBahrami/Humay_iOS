# Batch source layout

For production, split Sun records into small batch files to keep Git diffs reviewable
and allow easy retry/model assignment.

Recommended:

```
Tools/ContentPack/source/sun/
  01/
    batch-01.json   # 01-01_01-07 x 12 = 84 records
    batch-02.json
  02/
    ...
  batches/status.json  # batchID, coverage, model, promptVersion, qaStatus
```

Compiler automatically discovers all `source/sun/**/*.json` plus legacy `source/sunBase.json`.
Duplicate `dayKey|sunSign` across files is a validation error.

Each batch file contains a JSON array of SunDayRecord objects.
See `scorePlan.pilot.json` for the deterministic score/theme skeleton that should be
fed to the writing model before prose authoring.

QA: before approving a batch, run `compile.py --mode production --validate` and
review `.qa/content-report.json`.
