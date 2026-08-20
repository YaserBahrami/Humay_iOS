# Apple Verification

`Scripts/verify-apple.sh` is the normal repository-local verification entry
point. It calls `Scripts/verify-foundation.sh`; the foundation script remains the
fast static-only check.

Humay does not currently use GitHub Actions or another CI service. Verification
is intentionally local until CI is designed as its own task.

## Normal workflow

Run from the repository root:

```bash
bash Scripts/verify-apple.sh quick
bash Scripts/verify-apple.sh standard
bash Scripts/verify-apple.sh full
```

`quick` runs foundation checks, one Debug iPhone build, and `HumayTests`. It is
for active implementation, not phase completion.

`standard` runs foundation checks, Debug iPhone and iPad builds, a Release
Simulator build, unit tests, and four existing high-value iPhone UI flows:

- completed onboarding/root relaunch;
- Today/Daily Horoscope period switching;
- loaded Chart placement navigation;
- Connections compatibility selection and result.

`full` runs everything in `standard`, then all of `HumayUITests` on a
representative iPhone and iPad. It can take substantially longer because the UI
suite deliberately launches many isolated fixture states.

The smoke list uses existing tests only. No test plan was added: command-line
`-only-testing` selectors keep this organization explicit without project-file
churn.

## Simulator selection and health

The runner never commits simulator UUIDs. It chooses an available iOS simulator,
preferring a modern Pro-class iPhone and a 13-inch/12.9-inch iPad Pro, then a
same-family fallback. Before builds or tests it confirms that the selected device
is available, boots it if needed, waits for boot completion, and probes
SpringBoard responsiveness.

Inspect local prerequisites without booting devices:

```bash
bash Scripts/verify-apple.sh doctor
```

`doctor` reports Xcode, active developer directory, installed iOS runtimes,
available selected devices, boot state, a SpringBoard probe for already-booted
devices, and disk space.

To choose exact destinations, pass available matching simulator IDs. Overrides
take precedence and are never silently replaced by another device:

```bash
IPHONE_ID="<iPhone UDID>" IPAD_ID="<iPad UDID>" \
  bash Scripts/verify-apple.sh full
```

The runner never erases a simulator, resets all simulators, or shuts down a
simulator after a run. If manual recovery is needed, first preserve the result
bundle and log, then explicitly reboot only the affected simulator:

```bash
xcrun simctl shutdown "<UDID>"
xcrun simctl boot "<UDID>"
xcrun simctl bootstatus "<UDID>" -b
```

An erase is intentionally not part of this workflow because it destroys local
simulator data.

## Test result policy

Every test command writes an `.xcresult` bundle and an unfiltered `xcodebuild`
log under the git-ignored `.verification-results/<timestamp>-<mode>/` directory.
The final summary prints that directory; failures additionally print their result
bundle path. `xcresulttool` supplies actual passed/failed counts and extracts a
failed test name where possible. Do not infer test counts from this document.

The runner uses ordinary `xcodebuild test`. On Xcode 26.6 with iOS 26.5, both
ordinary `test` and verified `build-for-testing` followed by
`test-without-building` emitted `DebuggerLLDB.DebuggerVersionStore.StoreError`
yet successfully launched the app/test runner and passed a focused UI test.
The split path did not isolate or improve that behavior, so it is not added as
extra complexity.

In particular, an LLDB store warning by itself is not a failure signal. A test is
only `PASS` when `xcodebuild` succeeds and its `.xcresult` reports at least one
passed test. A warning before bootstrap with no verifiable test result is instead
an `INFRASTRUCTURE FAILURE`.

The runner reports these categories separately and returns non-zero for either:

- `PRODUCT/TEST FAILURE`: compile failure, assertion failure, application crash,
  application launch failure, or an incomplete run after XCTest/XCUITest began.
  It never retries this category.
- `INFRASTRUCTURE FAILURE`: unavailable/failed simulator boot, disappearing
  destination, test-runner installation/test-manager/toolchain failure before
  bootstrap, or an unverifiable test run. It preserves artifacts and makes at
  most one retry. For an automatically selected device, that retry prefers
  another healthy simulator of the same family. An explicit override is retried
  only on that same device.

If a retry succeeds, both the first infrastructure failure and the subsequent
passing retry remain in the summary. The command still returns non-zero: an
infrastructure incident is not a clean verification pass.

## Fast static check

Run this directly when only repository/static validation is wanted:

```bash
bash Scripts/verify-foundation.sh
```

It runs typography, asset policy, layering, nomenclature, diagnostics, and
whitespace checks. It neither selects nor boots simulators.

### Asset-policy guard

```bash
bash Scripts/check-asset-policy.sh
```

It rejects production Swift use of custom `Shape` conformances, `Canvas`, `Path`,
Core Graphics/Bézier path construction, and non-system `Image(...)` access outside
the typed asset renderer. Exact-file exceptions remain intentionally small:

- `Humay/Presentation/Chart/ChartWheel.swift` draws chart houses/aspects from
  `ChartWheelModel` data.
- `Humay/DesignSystem/Assets/HumayAssets.swift` owns typed non-system asset
  rendering.

## Manual diagnosis

Use raw `xcodebuild` only when isolating an already-reported failure. Keep its
result bundle outside source control and preserve the destination used:

```bash
xcodebuild \
  -project Humay.xcodeproj \
  -scheme Humay \
  -configuration Debug \
  -destination "platform=iOS Simulator,id=$IPHONE_ID" \
  -resultBundlePath .verification-results/manual-ui.xcresult \
  -only-testing:HumayUITests/LaunchUITests/testOnboardingFlowCompletes \
  test
```

## Completion rule

A phase is verified only when its relevant checks actually pass after the latest
source change. A previous pass does not cover later source/test changes. Do not
commit DerivedData, simulator artifacts, local result bundles, machine-specific
simulator IDs, or Xcode caches.
