# Testing Strategy

Swift Testing is used for unit/domain tests and XCTest for UI tests.

```bash
xcodebuild test -project Humay.xcodeproj -scheme Humay \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -derivedDataPath .build/DerivedData
```

## Current high-value tests

The suite targets rules that can fail silently rather than chasing coverage percentage.

| Suite | Purpose |
|---|---|
| `RepositoryTests` | CRUD/migration-sensitive persistence behavior. |
| Birth-time cases | `.unknown` remains distinguishable from a real clock time. |
| `LiveWiringTests` | Exercises composition/persistence resource lifetimes. |
| `TypographyTests` | Bundled Cormorant faces resolve rather than silently falling back. |
| `AccessibilityTests` | Dynamic Type hierarchy/reflow and hit-target invariants. |
| `ToneInvarianceTests` | Normal and Roast use the same underlying astrology basis/facts. |
| `MockProvenanceTests` | Every mock service result is explicitly marked as mock provenance. |
| `FixtureCompletenessTests` | Required mock shapes/keys resolve without treating fixture values as truth. |
| `ChartWheelGeometryTests` | Pure geometry/math behavior for the current wheel implementation. |
| UI tests | Launch and core navigation/onboarding smoke coverage. |

## Deliberately excluded from the mock baseline

- Tests that assert fixture astrology values are scientifically/astrologically correct.
- Provider contract/golden-value tests before the real calculation layer exists.
- Snapshot goldens that would accidentally canonize fixture content as calculation truth.
- iPad layout tests while iPad remains a dedicated later phase.

## Static checks

Run alongside the suite:

```bash
./Scripts/check-layering.sh
./Scripts/check-nomenclature.sh
```

`check-layering.sh` enforces dependency direction. `check-nomenclature.sh` protects active product naming and user-facing claims that remain invalid (for example historical product names, fake accounts, token/coin wallets, and misleading absolute compatibility language).

**Compatibility percentages/scores are no longer banned by nomenclature.** Current design authority permits numeric presentation, but tests must not treat illustrative UI percentages as a validated production algorithm.

## Light + Dark UI verification

As current D0–D9 screen families are implemented, UI/accessibility coverage should include:

- representative Light and Dark launches for each finalized family;
- contrast checks for text/controls separately by appearance;
- Dynamic Type at accessibility sizes;
- VoiceOver reading order and semantic labels;
- Reduce Motion alternatives for hero/reveal motion;
- verification that decorative artwork does not hide or replace factual content;
- appearance-specific assets resolving correctly when used.

Pixel snapshots may be reconsidered after the actual screen family is approved and production data is decoupled from its visual fixture. Snapshot tests should protect layout/system regressions, not declare mock astrology values authoritative.

## When the calculation layer lands

Fixture-shape tests are complemented/replaced by validation against independently sourced golden values that record source, methodology and version. Design references are never accepted as astrology truth merely because they appear in an approved screen.
