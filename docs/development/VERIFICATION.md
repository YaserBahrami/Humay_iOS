# Apple Foundation Verification

This document is the canonical local verification contract for the current Humay iOS/iPadOS foundation.

Humay does not currently use GitHub Actions or another CI service. Verification is intentionally local until CI is designed as its own task.

## 1. Repository-local checks

Run from the repository root:

```bash
bash Scripts/verify-foundation.sh
```

This orchestrates:

- `Scripts/check-layering.sh`;
- `Scripts/check-nomenclature.sh`;
- `Scripts/check-diagnostics.sh`;
- whitespace validation for both the latest committed diff and the current working tree.

The script does not choose or boot a simulator and does not mutate application data.

## 2. Resolve representative simulator destinations

Available destinations vary by Xcode installation, so no simulator UUID is committed to the repository.

```bash
xcodebuild \
  -project Humay.xcodeproj \
  -scheme Humay \
  -showdestinations
```

Choose one available iPhone simulator and one available iPad simulator, then export their UDIDs for the commands below:

```bash
export IPHONE_ID="<available iPhone simulator UDID>"
export IPAD_ID="<available iPad simulator UDID>"
```

Record the exact destinations used in the implementation/audit report.

## 3. Representative Debug builds

### iPhone

```bash
xcodebuild \
  -project Humay.xcodeproj \
  -scheme Humay \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$IPHONE_ID" \
  build
```

### iPad

```bash
xcodebuild \
  -project Humay.xcodeproj \
  -scheme Humay \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$IPAD_ID" \
  build
```

## 4. Swift Testing

Run the unit/foundation target on a representative iPhone simulator:

```bash
xcodebuild \
  -project Humay.xcodeproj \
  -scheme Humay \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$IPHONE_ID" \
  -only-testing:HumayTests \
  test
```

The current unit target owns domain, navigation, onboarding, persistence, DesignSystem and privacy-safe logging invariants. Persistence tests must remain isolated from production storage.

## 5. XCUITest

Run the current essential production-flow UI suite on both device families.

### iPhone

```bash
xcodebuild \
  -project Humay.xcodeproj \
  -scheme Humay \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$IPHONE_ID" \
  -only-testing:HumayUITests \
  test
```

### iPad

```bash
xcodebuild \
  -project Humay.xcodeproj \
  -scheme Humay \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$IPAD_ID" \
  -only-testing:HumayUITests \
  test
```

The required correctness flows are intentionally small: fresh onboarding, canonical onboarding completion, back navigation and durable completion across terminate/relaunch. Design-evidence capture tests are supporting tooling, not substitutes for correctness assertions.

## 6. Simulator/tooling failures

Distinguish product/test failures from simulator infrastructure failures.

If a destination fails before the app or test runner bootstraps:

1. rerun the failing command once without output filtering;
2. inspect whether the application/test process actually started;
3. if the failure is simulator infrastructure, use another representative available destination of the same device family and record the failed destination separately;
4. do not modify production code to work around a simulator runner failure.

A test assertion, compile failure, launch failure after app bootstrap or application crash is a product/test failure and must not be reported as infrastructure noise.

## 7. Completion rule

A foundation task may be marked verified only when its relevant static checks, builds and tests have actually passed after the latest source change.

Do not infer a pass from an earlier commit after modifying production/test code. Do not commit DerivedData, simulator artifacts, local result bundles, machine-specific simulator identifiers or secret/config files.
