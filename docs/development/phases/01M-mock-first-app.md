# Phase 01M — Mock-First iOS Application

Parallel track authorized by [`DEV-001`](../DEVIATIONS.md). This phase does **not** satisfy Phase 00 or Phase 01 exit criteria and does not advance any `ARCH-###` or feature task.

## Purpose

Establish a launchable, navigable iOS application with production-quality architecture, a reusable design system, all major screens and complete primary flows — using mock content only, behind service protocols that real implementations replace later.

## Out of scope

Astrology calculation providers · LLM/AI providers · backend services · authentication · StoreKit/subscriptions · advertisements · analytics · CloudKit or remote sync · iPad layouts.

## Standing constraints

- Every content-bearing domain value carries a non-optional `ContentProvenance`. Mock services emit `.mockFixture`.
- Fixtures live only under `Humay/Data/Mock/Fixtures/`, so the whole directory is deleted rather than migrated when real services arrive.
- No stub entitlement, no simulated ad, no fake paywall. Precise readings are directly reachable.
- Western, Vedic and Chinese chart types share no placement type, no sign type and no common protocol.
- Nomenclature freeze enforced by `Scripts/check-nomenclature.sh`.

## Visual authority

The approved **minimal Humay direction** governs visuals and layout, and is stated in full in [`../../design/MINIMAL_DESIGN_DIRECTION.md`](../../design/MINIMAL_DESIGN_DIRECTION.md): All Paper surfaces, generous whitespace, restrained gold, Cormorant Garamond headlines, SF Pro body and UI, SF Mono for degrees/coordinates/dates, minimal surfaces, subtle borders, limited card usage, native iOS interaction patterns.

`docs/design/claude-reference/Humay Product Prototype - Consolidated.dc.html` is authoritative for **product concepts, feature behaviour, terminology and copy only**. Where it conflicts visually with the minimal direction, the minimal direction wins. See [`../../design/DESIGN_AUTHORITY.md`](../../design/DESIGN_AUTHORITY.md).

---

## Stage A — Project and shell

### IOS-001 — Xcode project, build configuration, launchable app
Status: DONE
Depends on: —

Scope:
- Hand-written `Humay.xcodeproj/project.pbxproj` using `objectVersion = 70` and `PBXFileSystemSynchronizedRootGroup`.
- `Config/{Shared,Debug,Release}.xcconfig`, hand-written `Config/Info.plist`, shared scheme.
- Bundle identifier `online.humay.ios` (permanent; product domain humay.online).
- `IPHONEOS_DEPLOYMENT_TARGET = 18.0`, `TARGETED_DEVICE_FAMILY = 1`, portrait only.
- Swift 6 language mode, `SWIFT_STRICT_CONCURRENCY = complete`, `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated`.

Acceptance:
- `xcodebuild -list` reports the `Humay` scheme.
- Clean Debug build succeeds for an iPhone simulator destination.
- App launches and renders.
- Code signing remains configured for development-device signing and archives. `CODE_SIGNING_ALLOWED = NO` is never committed to project configuration; it may be passed on the command line for simulator verification only.

### IOS-008 — Test targets
Status: DONE
Depends on: IOS-001

Scope: `HumayTests` (Swift Testing) and `HumayUITests` (XCTest) as file-system-synchronized targets.

Acceptance: `xcodebuild test` passes.

### IOS-002 — Layer structure, composition root, enforcement scripts
Status: DONE
Depends on: IOS-001

Scope: `App` / `Domain` / `Data` / `Presentation` / `DesignSystem` folders; `AppEnvironment` composition root holding protocol existentials only; `Scripts/check-layering.sh` and `Scripts/check-nomenclature.sh`.

Acceptance: `Domain/` imports neither SwiftUI nor SwiftData. `Presentation/` imports no SwiftData and names no concrete mock or repository implementation. Both scripts pass.

### IOS-003 — Design system
Status: DONE
Depends on: IOS-002

Scope: palette protocol + Paper palette; ink opacity ramp; spacing, radius, border, motion tokens; bundled Cormorant Garamond (four static faces, SIL OFL 1.1); `ScaledFont` with per-role Dynamic Type caps; `Wordmark`, `OccultationMark`, `HairlineRule`, `MonoKicker`, `GiltBadge`, `GlyphLabel`, `InfoTrigger`, button and segmented styles, tab bar appearance.

Acceptance: all four Cormorant faces resolve at runtime (asserted in DEBUG and by unit test). Display caps at 1.4×, mono at 1.2×, body uncapped. Adding a dark palette requires one new struct and one line in `HumayTheme`, with no view changes. No hex literal outside the palette file. Native iOS tab and navigation appearance reconciled with the minimal direction.

### IOS-004 — Navigation shell
Status: DONE
Depends on: IOS-003

Scope: `AppRouter`, `RootTabView` with Today / Circle / Sky / Chart / Ask, one `NavigationStack` per tab, tab re-selection returns that tab to its root, Settings as a full-screen cover from the header.

Acceptance: all five tabs reachable, per-tab stacks preserved independently, Calendar is not a tab, Settings is not a tab.

---

## Stage B — Data spine

### IOS-006 — Versioned SwiftData persistence
Status: DONE
Depends on: IOS-002

Scope:
- `HumaySchemaV1: VersionedSchema` namespacing all `@Model` entities, with `HumayMigrationPlan: SchemaMigrationPlan` established from the outset.
- Entities: `UserProfileEntity`, `CirclePersonEntity`, `AppSettingsEntity`, `AskConversationEntity`, `AskMessageEntity` — primitives and `String` raw values only.
- Pure mappers between entities and domain value types.
- `SwiftData*Repository` and `InMemory*Repository` behind repository protocols.

Acceptance:
- Future schema revisions add `HumaySchemaV2`; `V1` is never edited retroactively.
- `@Model` types do not appear in `Domain/` or `Presentation/`. No view uses `@Query`; the app does not call `.modelContainer(_:)`.
- `BirthTime.unknown` round-trips as `.unknown`; no code path yields a substituted midnight or noon.
- Onboarding completion, birth details, tradition, tone and Circle people persist across launches.

### MOCK-001 — Mock content boundary
Status: DONE
Depends on: IOS-002

Scope: `ContentProvenance`, `MockContentProvider`, `MockLatency`, banner headers on every file in `Data/Mock/`.

Acceptance: mock services can only produce provenance through the boundary helper. `check-layering.sh` fails if a fixture type is named outside `Data/Mock/` or the composition root.

### MOCK-002 — Domain model
Status: DONE
Depends on: MOCK-001

Scope: profile, content, sky, circle and ask types; three mutually exclusive chart families; `FactValue<T>` and `FactUnavailability`.

Acceptance: `ChineseChart` exposes no house, aspect or transit member. `Rashi` is not a typealias of `WesternSign` and no bridging function exists. `GlossaryTerm.system` is non-optional.

### IOS-005 — Shared presentation components
Status: DONE
Depends on: IOS-003, MOCK-002

Scope: app header, tone chip, insight surface, basis disclosure, section header, loading/empty/error states, glossary sheet.

Acceptance: components support Dynamic Type and VoiceOver from the start; hit targets at or above 44pt.

---

## Stage C — First end-to-end slice

### PROFILE-101 — Onboarding and profile persistence
Status: DONE
Depends on: IOS-004, IOS-006

Scope: four screens — welcome, birth date, tradition, reveal — with a state machine, the occultation reveal, and persistence of profile and tradition. Tone is deliberately **not** collected here.

Acceptance: onboarding runs once, survives relaunch, and never asks for birth time or place as a requirement.

### MOCK-003 — Horoscope fixtures
Status: DONE
Depends on: MOCK-001

Scope: 12 signs × Normal/Roast × headline, overview and four categories, plus a shared basis per fixture.

Acceptance: basis is identical across tones for the same fixture. Every sign and category resolves.

### TODAY-101 — Today, general
Status: DONE
Depends on: PROFILE-101, MOCK-003

Scope: date and sign context, general badge, headline, overview, Love / Career / Finance / Health, basis disclosure, precise entry point.

Acceptance: the general basis is disclosed on screen and never implies natal-level precision.

### TODAY-102 — Today, precise
Status: DONE
Depends on: TODAY-101

Scope: precise reading citing mock natal and transit factors, with an expandable astrological basis.

Acceptance: reachable directly, with no gate, stub entitlement or simulated ad.

### PROFILE-102 — Profile and settings
Status: DONE
Depends on: IOS-006

Scope: birth details (date, exact time, location, including the not-set state), astrology tradition, tone with a live dual-register preview, notifications, subscription placeholder, privacy and data, help and support, about.

Acceptance: notifications carry no Roast toggle. Privacy copy states that data is local to the device and that there is no sign-in.

---

## Stage D — Remaining surfaces

### CIRCLE-101 — Circle people
Status: DONE — list, add person, person detail.

### CIRCLE-102 — Circle visualization
Status: DONE — user-centred minimal arrangement with a structured-text accessibility alternative.

### CIRCLE-103 — Compatibility
Status: DONE — general and precise tiers over four axes: Love & Chemistry, Communication, Emotional Connection, Conflict & Pace. Qualitative verdicts only — Strong, Balanced, Mixed, Friction — each with a short explanation. No score, percentage or ranking anywhere in the subtree. "Shared values" may appear only inside precise prose, never as a general sign-to-sign axis.

### SKY-101 — Sky, current
Status: DONE — moon phase, moon sign, Sun/Mercury/Venus/Mars, and the "In the sky" / "For you" register distinction.

### SKY-102 — Calendar
Status: DONE — month and week views nested under Sky.

### SKY-103 — Event detail
Status: DONE — in the sky, for you, astrological basis.

### CHART-101 — Chart, general
Status: DONE — sign profile across the three traditions, each labelled in its own vocabulary.

### CHART-102 — Chart, full
Status: DONE — in-place system switching with genuinely distinct Western, Vedic and Chinese content. Chart-factor rows are not shared across systems.

### CHART-103 — Glossary
Status: DONE — inline term triggers and a definitions sheet, scoped per system.

### CHART-104 — Chart wheel
Status: DONE — geometry, presentation model and view as three separate layers so calculated coordinates replace mock values without touching the view. Western only. Structured-text accessibility alternative.

### CHART-105 — Placement detail
Status: DONE — placement, sign, degree, then meaning, aspects and houses.

### ASK-101 — Ask
Status: DONE — suggested questions, composer, answers citing mock chart and transit factors with a stated basis, follow-ups retained in the conversation. Behind `AstrologyAssistantService`.

---

## Stage E — Polish and gates

### IOS-009 — Motion and haptics
Status: DONE — the four motion verbs plus the signature reveal; Reduce Motion paths; nothing loops; haptics on tone change only.

### IOS-010 — Accessibility
Status: DONE — VoiceOver order follows visual reading order with insight before basis; every astrological glyph carries a spoken label; hit targets at or above 44pt; Dynamic Type verified at the largest accessibility size on every screen.

Closed 2026-08-11 with `IOS-012`. The Dynamic Type sweep found and fixed:

- **Onboarding could not be completed at the accessibility sizes.** The welcome beat was a `VStack` with no scroll view, so "Begin" sat below the bottom of the screen with no way to reach it. Every onboarding beat now scrolls with the action pinned below it. The UI tests were failing this before the fix and pass after it.
- **Type ceilings inverted the hierarchy.** A flat 1.4× cap on display and title roles against uncapped body copy meant a person's name was set smaller than "Leo · Partner" underneath it. Ceilings are staggered, row titles are uncapped, and `AccessibilityTests` asserts the resulting order.
- **Targets below 44pt.** The Ask send button was 34pt; the glossary triggers were shrunk to 22 and 30pt by their callers to keep rows tight; calendar day cells were 42pt. All now meet the minimum, and `InfoTrigger` separates its visual size from its target so a caller cannot trade one for the other again.
- **Rows that could not reflow.** Label-and-value pairs, the chart triad, the four BaZi pillars and the placement rows now stack rather than compress.
- **The glossary sheet clipped.** A definition at the largest size is several times the height of a medium detent, with no scroll view and the action pushed off the sheet.
- **Calendar dates wrapped mid-number.** Set in the body face and uncapped, the tenth of the month broke across two lines in a 50pt column. Dates are mono, per the typography lock, and mono is capped.

Reduce Motion paths were re-verified: the occultation reveal, the circle draw and the chart chords all take their reduced alternative, and nothing loops.

### IOS-007 — Diagnostics and configuration
Status: DONE — privacy-redacted logging and build configuration flags. No secrets, no analytics.

### MOCK-004 — Provenance sweep
Status: DONE — test coverage asserting mock provenance across every mock service method, and DEBUG runtime marking.

### IOS-011 — Architecture documentation
Status: DONE — `docs/architecture/IOS_ARCHITECTURE.md`, `DATA_MODEL.md`, `MOCK_DATA_STRATEGY.md`, `TESTING_STRATEGY.md`.

### IOS-012 — Visual reconciliation and accessibility closure
Status: DONE
Depends on: every task above

The application was built from the written design rules rather than against the approved minimal direction screen by screen. This pass reconciled the two and closed `IOS-010`. **No product feature was added, and no architectural boundary was touched** — `check-layering.sh` and `check-nomenclature.sh` pass unchanged, and the repository, provenance, chart-family and service boundaries are as they were.

Scope:
- The approved direction was written down as [`../../design/MINIMAL_DESIGN_DIRECTION.md`](../../design/MINIMAL_DESIGN_DIRECTION.md), including what counts as drift, so the next pass has something to check against.
- Every screen listed in that document's §04 was reviewed against it.
- The Dynamic Type and hit-target work above.
- Screenshots of the result in [`../../design/review/`](../../design/review/README.md).

What was reconciled:
- **Twelve hand-rolled screen scaffolds became one.** Each pushed screen, settings page and sheet repeated the same four modifiers, and the top inset had already drifted between them. `HumayPage` now owns the gutter, insets, ground and title treatment; `ScreenScaffold` and `DetailScaffold` are the two shapes above it.
- **The general tier badge lost its outline.** It appeared on nearly every screen and distinguished nothing.
- **Chevrons and icons come from shared components.** The same chevron had been set at 11, 12 and 13 points in different files.
- **Glossary triggers moved inside their section headers**, so a section with a definition rules to the same width as one without.
- **A withheld triad glyph is drawn at the disabled weight** rather than as a gold mark that means nothing.

Acceptance:
- Clean build; 49 unit tests and 5 UI tests pass. One of the UI tests drives onboarding at the largest accessibility text size, so the overflow above cannot come back unnoticed.
- `check-layering.sh` and `check-nomenclature.sh` pass.
- Driven on iPhone SE (3rd generation), iPhone 17 Pro and iPhone 17 Pro Max, at default and largest accessibility Dynamic Type.

---

## Phase exit criteria

- App builds, launches and is navigable through every major flow on an iPhone simulator.
- Unit and UI tests pass; layering and nomenclature scripts pass.
- Every astrological value on screen is traceable to a mock fixture, and mock provenance is asserted by test.
- Architecture documentation describes the layers, the data model, the mock strategy, the service boundaries and the remaining integrations.
- No provider, payment, advertising, analytics or authentication code exists in the tree.

---

## Outcome

**Every task above is `DONE`.** The phase closed on 2026-08-11 with `IOS-012`, which reconciled the implementation against the minimal design direction and completed the accessibility sweep that `IOS-010` was waiting on.

Verified at close:

- Clean Debug build for an iPhone simulator; the app launches and every flow is navigable.
- 49 unit tests and 5 UI tests pass, one of which drives onboarding at the largest accessibility text size — the case that caught the onboarding overflow.
- `check-layering.sh` and `check-nomenclature.sh` pass.
- Onboarding, Today (both tiers), Circle, compatibility, Sky, Calendar, event detail, Chart (all three systems), placement detail, glossary, Ask and every settings page were driven in the simulator on iPhone SE (3rd generation), iPhone 17 Pro and iPhone 17 Pro Max.
- Screenshots of the ten primary screens are in [`../../design/review/`](../../design/review/README.md).

This is the first stable UI baseline. It is still mock content throughout.

### Decisions taken during implementation

- **`SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated`.** Under MainActor-by-default the synthesized conformances on domain value types become isolated and cannot satisfy `Sendable` on generics such as `FactValue<Bhava>`.
- **`UIDesignRequiresCompatibility = YES`.** The iOS 26 floating tab bar is translucent and capsule-shaped, so a reading is visible through the chrome while being read. Transitional; revisit when the design takes a position on the newer appearance.
- **Tab roots use the system large title.** A header drawn inside the scroll view neither collapses on scroll nor keeps content clear of the status bar. Navigation titles stay in the system face per the typography lock; Cormorant carries the editorial headline below.
- **Fixtures are Swift rather than JSON.** Type-checked, no decode failure path, and no loader to delete later.
