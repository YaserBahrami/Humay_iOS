# iOS Architecture

Describes the application as built in Phase 01M. Anything marked **mock** is fixture content behind a replaceable boundary — see [`MOCK_DATA_STRATEGY.md`](MOCK_DATA_STRATEGY.md) and [`../development/DEVIATIONS.md`](../development/DEVIATIONS.md).

## Platform

| | |
|---|---|
| Minimum deployment target | iOS 18.0 |
| Language | Swift 6, strict concurrency, `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated` |
| UI | SwiftUI |
| Persistence | SwiftData, versioned from V1 |
| Devices | iPhone, portrait (`TARGETED_DEVICE_FAMILY = 1`) |
| Bundle identifier | `online.humay.ios` |
| Third-party dependencies | none |

Isolation is opt-in rather than defaulted to `MainActor`. Under MainActor-by-default, the synthesized `Hashable`/`Equatable` conformances on domain value types become actor-isolated and can no longer satisfy the `Sendable` requirement on generics like `FactValue<Bhava>` — the layer that should be the most concurrency-neutral becomes the most constrained. SwiftUI views still get `MainActor` from the `View` protocol; repositories, view models and the composition root declare it explicitly.

## Project layout

The Xcode project is hand-written and uses `PBXFileSystemSynchronizedRootGroup` (`objectVersion = 70`), so folders sync automatically and adding a Swift file requires no project edit. Build settings live in `Config/*.xcconfig`; only per-target settings that cannot be shared stay in the project file.

```
Humay.xcodeproj/          project.pbxproj + shared scheme
Config/                   Shared/Debug/Release xcconfig + Info.plist
Scripts/                  check-layering.sh, check-nomenclature.sh
Humay/
├── App/                  entry point, composition root, routing, logging
├── Domain/               pure Swift: value types, service and repository protocols
│   ├── Shared/           FactValue
│   ├── Profile/          UserProfile, BirthDetails, AstrologyTradition, Tone, AppSettings
│   ├── Content/          ContentProvenance, HoroscopeReading, ReadingBasis
│   ├── Chart/            Shared, Western, Vedic, Chinese — three unrelated families
│   ├── Sky/              SkyEvent, SkySnapshot, MoonPhase
│   ├── Circle/           CirclePerson, CompatibilityReading
│   ├── Ask/              AskConversation, AskMessage
│   ├── Services/         protocols only
│   └── Repositories/     protocols only
├── Data/
│   ├── Persistence/      SwiftData schema, container, mappers, repositories
│   ├── InMemory/         repositories for previews and fast tests
│   └── Mock/             THE BOUNDARY — fixture services and content
├── DesignSystem/         Tokens, Typography, Components, Motion
├── Presentation/         one folder per surface, plus Common
└── Resources/            Assets.xcassets, Fonts
HumayTests/               Swift Testing
HumayUITests/             XCTest
```

`Config/` is a plain group rather than a synchronized one. Synchronized groups copy every non-source file into the Resources phase, which would produce "Multiple commands produce Info.plist".

## Layers

```
App  →  Presentation  →  Domain  ←  Data
```

`Domain` imports nothing but Foundation. `Presentation` depends on domain protocols and never on an implementation. `Data` depends on `Domain` and is depended on only by the composition root.

The compiler cannot enforce this in a single target, so `Scripts/check-layering.sh` does: no SwiftUI/SwiftData/UIKit in `Domain/`, no SwiftData or `@Query` in `Presentation/`, no concrete `Mock*` or `*Repository` type named in `Presentation/`, `@Model` only under `Data/Persistence/`, and colour literals only in the palette file.

`HumayDomain` becomes a local Swift package the moment a real calculation engine lands and needs to be tested without an app host or shared with a widget extension. Until then, folders.

## Composition root

`AppEnvironment` is `@Observable`, `@MainActor`, and holds every dependency as a protocol existential. `AppEnvironment+Live` is the only file in the application that names a concrete repository or service; replacing the mocks is a change to that one file.

It also owns the small amount of state more than one screen must agree about — the profile, the settings and the Circle — and every write goes through it so the in-memory copy and the store cannot drift.

`AppEnvironment.preview` (DEBUG only) is built from in-memory repositories with zero latency, so previews never touch SwiftData.

## Persistence

- `HumaySchemaV1: VersionedSchema` namespaces every `@Model` type. `HumayMigrationPlan: SchemaMigrationPlan` exists from the first release with no stages. A later revision becomes `HumaySchemaV2` with a stage; **V1 is never edited retroactively**, because once a shipped build has written data in that shape the file describes what is on disk rather than what we would like.
- Entities store primitives and `String` raw values only — no enums with associated values, no `Codable` composites. That is SwiftData's most migration-fragile area, and a flat shape makes `BirthTime.unknown` impossible to confuse with a stored zero.
- `@Model` types never leave `Data/Persistence/`. The app does not call `.modelContainer(_:)` and no view uses `@Query`; either would put SwiftData in the view layer.
- Repositories are `@MainActor` and synchronous. The dataset is one profile, a handful of people and a few conversations. If one ever needs background work, the protocol becomes `async` and gains a backing actor — call sites already `try`, so the change is mechanical.
- **Repositories hold the `ModelContainer`, not just its context.** A `ModelContext` does not keep its container alive, so a repository storing only `container.mainContext` works for as long as something else happens to hold the container and then traps inside SwiftData once that reference goes away. `LiveWiringTests` exercises the composition root itself for exactly this reason.

The store lives at `Application Support/Humay.store`. That directory does not exist in a fresh container and SwiftData does not create it; `HumayModelContainer.storeURL()` does.

## Navigation

Five tabs — Today, Circle, Sky, Chart, Ask — each with its own `NavigationStack`, so switching tabs never discards position. Re-selecting the active tab pops that stack to its root and leaves the others untouched. Calendar is a segment inside Sky. Profile and settings are a full-screen cover reached from the header, not a sixth tab.

`AppRouter` owns per-tab paths and the settings cover. `Route` and `SettingsPage` are `Hashable` enums.

## Appearance

`UIDesignRequiresCompatibility` is set. The iOS 26 floating tab bar is translucent and capsule-shaped, so a reading would be visible through the chrome while being read — the opposite of a design built on a flat ground, square edges and hairline rules. The alternative, a hand-built tab bar, would cost the free accessibility, keyboard and state behaviour of the real one. This key is transitional and should be revisited when the design takes an explicit position on the newer appearance.

The application is light-only (`UIUserInterfaceStyle = Light`) because the surface model is All Paper. Ink and Paper are semantic tokens, not a light/dark pair — a dark appearance is a separate design decision and must not be implemented by inverting them.

## Testing

Swift Testing for unit tests, XCTest for UI tests, not mixed in one target. See [`TESTING_STRATEGY.md`](TESTING_STRATEGY.md).

## Not built

No networking, no astrology provider, no interpretation provider, no authentication, no StoreKit, no advertising, no analytics, no CloudKit, no widgets, no notification scheduling, no iPad layouts. There is no HTTP client in the tree.
