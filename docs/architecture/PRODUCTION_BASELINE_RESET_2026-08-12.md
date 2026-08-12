# Production Baseline Reset — 2026-08-12

## Why this reset exists

Humay reached a new approved visual direction after an earlier mock-first application had already been generated. Continuing to patch that implementation would preserve assumptions from the old UI and mock provider model. Before production implementation starts, the repository is intentionally reduced to a small, auditable foundation.

This is **not** a new Xcode project. The project/scheme/configuration foundation is retained because it is sound. The reset removes application code that would bias the new implementation.

## Retained

- `Humay.xcodeproj` and shared scheme;
- `Config/*.xcconfig` build configuration;
- Swift 6 + strict concurrency baseline;
- bundle identifier and signing configuration;
- `Humay/Resources/Fonts/` and the asset-catalog shell;
- `BirthDetails`, `UserProfile`, `AstrologyTradition`, `Tone` and the small `AppSettings` baseline;
- application logging utility;
- design/product/methodology documentation and approved visual references;
- unit/UI test targets.

## Removed

- the old `Presentation/` implementation;
- the old Light-only/serious `DesignSystem/` implementation;
- all runtime mock astrology services and fixture catalogs;
- in-memory/mock repository implementations;
- premature Chart/Sky/Circle/Ask/Content service and domain families;
- routing that existed only to support the deleted prototype screens;
- the premature SwiftData V1 persistence schema and repositories;
- prototype UI/unit tests whose subjects were deleted;
- automatic seed-circle behavior and all production-runtime dependencies on `MockAstrology`.

The git history remains the archive if any removed implementation needs to be inspected later. Removed code must not be copied back merely because it already existed.

## Current source baseline

```text
Humay/
├── App/
│   ├── AppEnvironment.swift
│   ├── HumayApp.swift
│   ├── HumayLog.swift
│   └── RootView.swift
├── Domain/
│   └── Profile/
│       ├── AppSettings.swift
│       ├── BirthDetails.swift
│       └── UserProfile.swift
└── Resources/
    ├── Assets.xcassets/
    └── Fonts/
```

`RootView` is intentionally a temporary semantic Light/Dark launch placeholder. The approved production design system and onboarding screens replace it incrementally.

## Persistence decision

Persistence was deliberately removed from the reset rather than carrying an unshipped schema forward. Humay has not shipped, so there is no migration obligation yet.

When the first production data-owning slice is implemented, persistence must be introduced from the actual approved model requirements. It must not silently fall back to volatile in-memory storage for user-owned data.

## Provider decision

No mock provider is wired as `live`. Real networking/calculation/interpretation adapters are introduced behind explicit interfaces when their product phase begins. Preview/sample content may exist later, but it must be feature-local and impossible to confuse with production output.

## Cross-device change

The production baseline now targets:

- iPhone (`TARGETED_DEVICE_FAMILY = 1`);
- iPad (`TARGETED_DEVICE_FAMILY = 2`).

Together: `TARGETED_DEVICE_FAMILY = 1,2`.

iPhone remains portrait-first. iPad supports portrait and landscape and must adapt to regular/compact widths and multitasking windows.

The previous statement that iPad was a later dedicated phase is superseded.

## Appearance change

The old forced-Light setting and the old compatibility-mode opt-out are removed. Humay follows system Light/Dark appearance and the new design system must implement both appearances intentionally.

The launch background and accent color asset entries now contain Light and Dark variants derived from the approved Soulful Celestial direction.

## Implementation rule from this point

Production UI is developed only from approved cross-device references:

1. design iPhone Light/Dark + iPad Light/Dark;
2. approve;
3. implement;
4. verify real screenshots at both device families and relevant size classes;
5. reconcile before moving forward.

Existing iPhone Welcome/Birth Date references remain approved. iPad companion designs are required before those screens are considered cross-device complete.
