# Testing Strategy

Swift Testing for unit tests, XCTest for UI tests. The two are not mixed in one target.

```bash
xcodebuild test -project Humay.xcodeproj -scheme Humay \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -derivedDataPath .build/DerivedData
```

## What is worth testing at this stage

The suite deliberately targets the rules that are easy to break silently, not coverage.

| Suite | Why it exists |
|---|---|
| `RepositoryTests` | CRUD over an in-memory container per test. Catches SwiftData relationship and delete-rule mistakes, which are the framework's most common bite. |
| Birth-time cases within it | `.unknown` must round-trip as `.unknown`, and midnight must stay distinguishable from "not set". This is the single rule the whole unknown-time design rests on. |
| `LiveWiringTests` | Exercises the composition root against the real on-disk store. Exists because the repositories originally kept only `container.mainContext` and not the container: every isolated test passed while the application trapped inside SwiftData on its first write. Ownership mistakes of that shape are invisible to narrow tests. |
| `TypographyTests` | Every bundled Cormorant face resolves. A missing font does not crash — UIKit substitutes San Francisco silently, and the mistake can survive for weeks. |
| `ToneInvarianceTests` | Normal and Roast share one basis across all twelve signs. The executable form of "Roast changes expression only". |
| `MockProvenanceTests` | Every value from every mock service reports mock provenance. The executable form of the central rule in `MOCK_DATA_STRATEGY.md`; a new mock method that forgets provenance fails here. |
| `FixtureCompletenessTests` | Every sign and category resolves. Prevents "works for Pisces, crashes for Capricorn". Asserts shape, never truth. |
| `ChartWheelGeometryTests` | Pure maths. The one place a silent visual bug would be invisible in review. |
| UI tests | Launch smoke, and onboarding through to Today. |

## What is deliberately excluded

- **Any test asserting an astrological value is correct.** There is nothing to be correct against, and writing one would convert prototype content into an engineering fixture — precisely what `TASK_CONVENTIONS.md` forbids.
- **Snapshot testing.** Needs a third-party dependency, and several surfaces are pre-reconciliation, so goldens would be re-recorded constantly. Revisit after Phase 00 closes.
- **View-model tests that only exercise a mock.** Most models in this phase are `service.call() → assign`; testing them tests the fixture.
- **Performance, localisation and iPad layout tests.** Nothing to measure and iPad is out of scope.

## Static checks

Run alongside the suite; neither is a build phase, so `ENABLE_USER_SCRIPT_SANDBOXING` stays on.

```bash
./Scripts/check-layering.sh
./Scripts/check-nomenclature.sh
```

`check-layering.sh` enforces the dependency direction the compiler cannot see in a single target. `check-nomenclature.sh` enforces the naming freeze — historical product names, and claims the product must not make such as a compatibility score or an "account" for what is a local profile.

## When the calculation layer lands

Fixture-shape tests are replaced by validation against independently sourced golden values, recording source, method and version. Design artifact values are not accepted as truth merely because they appear in a mockup.
