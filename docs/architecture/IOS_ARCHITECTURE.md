# iOS Architecture

Describes the application architecture established by completed Phase 01M and the production direction that replaces its mock-only/runtime appearance assumptions. Anything marked **mock** is fixture content behind a replaceable boundary — see [`MOCK_DATA_STRATEGY.md`](MOCK_DATA_STRATEGY.md) and [`../development/DEVIATIONS.md`](../development/DEVIATIONS.md).

Current UI/visual authority is [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md). This architecture document does not define an alternative visual system.

## Platform

| | |
|---|---|
| Minimum deployment target | iOS 18.0 |
| Language | Swift 6, strict concurrency, `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated` |
| UI | SwiftUI |
| Persistence | SwiftData, versioned from V1 |
| Devices | iPhone portrait for V1 (`TARGETED_DEVICE_FAMILY = 1`) |
| Bundle identifier | `online.humay.ios` |
| Third-party dependencies | none in the mock-first baseline |

Isolation is opt-in rather than defaulted to `MainActor`. SwiftUI views receive MainActor isolation from `View`; repositories, view models and composition code declare isolation explicitly where required. Domain value types remain concurrency-neutral.

## Project layout

The Xcode project uses `PBXFileSystemSynchronizedRootGroup` so source folders sync automatically. Shared build settings live in `Config/*.xcconfig`; per-target settings that cannot be shared remain in the project file.

```text
Humay.xcodeproj/          project + shared scheme
Config/                   Shared/Debug/Release xcconfig + Info.plist
Scripts/                  layering/nomenclature checks
Humay/
├── App/                  entry point, composition root, routing, logging
├── Domain/               pure Swift values, service/repository protocols
│   ├── Shared/
│   ├── Profile/
│   ├── Content/
│   ├── Chart/            Western / Vedic / Chinese remain distinct families
│   ├── Sky/
│   ├── Circle/
│   ├── Ask/
│   ├── Services/
│   └── Repositories/
├── Data/
│   ├── Persistence/
│   ├── InMemory/
│   └── Mock/             fixture-only boundary
├── DesignSystem/         semantic tokens, typography, components, motion
├── Presentation/         feature surfaces + Common
└── Resources/            Assets.xcassets, Fonts
HumayTests/
HumayUITests/
```

## Layers

```text
App  →  Presentation  →  Domain  ←  Data
```

`Domain` imports only Foundation. `Presentation` depends on domain protocols and does not know concrete data/provider implementations. `Data` depends on `Domain` and concrete implementations are wired only at the composition root.

`Scripts/check-layering.sh` enforces dependency rules that the compiler cannot see in a single app target.

A local Swift package for domain/calculation code may be introduced when production calculation engines or shared extensions make that boundary valuable; the current folder structure does not preclude it.

## Composition root

`AppEnvironment` owns dependencies behind protocol existentials. Concrete repositories/services are named only by composition wiring, allowing mock services to be replaced without presentation code depending on vendor types.

Shared user state such as profile/settings/Circle data flows through the environment/repository boundary so in-memory and persisted state cannot silently drift.

Preview wiring uses in-memory repositories and must not contact production services.

## Persistence

- `HumaySchemaV1: VersionedSchema` represents the shipped V1 on-disk shape and is never edited retroactively after release.
- Future changes add new schema versions and migration stages.
- Entities store migration-safe primitives/raw values rather than provider-native models.
- `@Model` types stay inside `Data/Persistence/` and do not leak into Domain/Presentation.
- Unknown birth time remains explicitly unknown; it is never represented by a hidden midnight/noon substitute.
- Repositories own the resources required for their model context/container lifetime.

Production cache/result persistence is finalized by Phase 00 architecture (`ARCH-004`) and remains distinct from local profile/settings persistence.

## Navigation

Five primary tabs:

**Today / Circle / Sky / Chart / Ask**

Each tab has its own navigation stack so switching tabs preserves position. Calendar is nested under Sky. Profile/Settings is reached from the header rather than becoming another primary tab.

`AppRouter` owns per-tab paths and presentation routes. Current design work may change composition inside screens but does not change this IA unless `docs/design/DESIGN_AUTHORITY.md` is explicitly updated.

## Appearance and design-system target

Production appearance follows the single current design program: **Soulful Celestial, Light + Dark**.

Architecture requirements:

- use semantic appearance-aware tokens rather than Light-only color literals;
- support intentional Light and Dark surfaces, not token inversion;
- keep illustration assets separate from layout/business logic;
- allow appearance-specific artwork only where the approved asset genuinely differs;
- preserve Dynamic Type, VoiceOver, Reduce Motion and native interaction behavior;
- keep hero/feature artwork responsive to its container rather than hard-coding device dimensions;
- keep utility/data screens calm even though the visual system supports rich illustrated hero moments.

The completed Phase 01M runtime still contains transitional appearance choices from the mock-first implementation. Those are implementation debt, not target architecture, and are reconciled during the production design-system/family implementation tasks. The active target is defined only by:

- [`../design/DESIGN_AUTHORITY.md`](../design/DESIGN_AUTHORITY.md)
- [`../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
- [`../design/SCREEN_DESIGN_PLAN.md`](../design/SCREEN_DESIGN_PLAN.md)

## Testing

Swift Testing is used for unit/domain tests and XCTest for UI tests. See [`TESTING_STRATEGY.md`](TESTING_STRATEGY.md).

Visual implementation adds Light/Dark and accessibility verification as the D0–D9 screen families become production-ready.

## Not yet built for production

Production networking, astrology provider adapters, interpretation provider, authentication (unless later required), StoreKit, advertising, analytics, widgets, notification delivery and iPad layouts are not complete. The existing mock-first service implementations are explicitly non-production.
