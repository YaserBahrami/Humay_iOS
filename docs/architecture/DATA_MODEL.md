# Data Model

Domain types are plain `Sendable` value types with no framework dependency. Persistence entities are a separate, deliberately dumber set that never leaves `Data/Persistence/`.

## The two rules the model exists to enforce

### 1. Content declares where it came from

```swift
enum ContentProvenance: Sendable, Hashable {
    case mockFixture(fixtureID: String)
    case editorialCatalog(catalogVersion: String)
    case calculated(engine: String, methodologyVersion: String)
}
```

Every content-bearing value carries this **non-optionally**. A reading cannot be constructed without stating its origin, so "mock content must never be mistaken for a calculation" is a property of the type system rather than a convention. Today only `.mockFixture` has a producer.

### 2. The three traditions are not skins of one another

There is no shared placement type, no shared sign type and no protocol that a Western, Vedic and Chinese chart all conform to. They are unified only by a closed sum:

```swift
enum SystemChart { case western(WesternChart), vedic(VedicChart), chinese(ChineseChart) }
```

- `WesternChart` — the only place `house`, `aspect`, `transit` and `rising` exist.
- `VedicChart` — `Rashi`, `Graha`, `Nakshatra`, `Bhava`, `DashaPeriod`. No houses, no aspects.
- `ChineseChart` — `Pillar`, `HeavenlyStem`, `EarthlyBranch`, `WuXing`, `DayMaster`. No signs, no houses, no transits, no aspects; there is no property to accidentally populate.

`Rashi` is **not** a typealias of `WesternSign` and there is no bridging function between them. They divide the same circle, and merging them is how Vedic quietly becomes a Western reading in Sanskrit labels — sidereal and tropical also disagree by roughly twenty-four degrees, so the same person's Sun usually falls in different divisions in each system. If a future Compare Systems screen needs to relate them, it gets its own explicitly named type that owns the mapping.

`GlossaryTerm.system` is non-optional for the same reason: a Nakshatra definition must not be reachable from a Western screen.

## Uncertainty

```swift
enum BirthTime { case exact(minutesFromMidnight: Int), approximate(…), unknown }

enum FactValue<Value> {
    case available(Value)
    case uncertain(Value, window: String)
    case unavailable(reason: FactUnavailability)
}

enum FactUnavailability {
    case requiresBirthTime
    case requiresBirthPlace
    case methodologyPending(methodID: String)
}
```

No initialiser takes an optional and substitutes a default — constructing an unknown time requires writing `.unknown`. An unknown birth time degrades only the facts that actually depend on it: `WesternChart.rising` becomes `.unavailable(.requiresBirthTime)` rather than a fabricated sign, and `ChineseChart.luckCycle` ships `.unavailable(.methodologyPending("METHOD-006"))` because the direction it runs has not been settled.

Carrying the *reason* rather than an optional means the interface can explain itself instead of showing a blank.

## Type inventory

| Area | Types |
|---|---|
| Profile | `UserProfile`, `BirthDetails`, `BirthTime`, `BirthPlace`, `AstrologyTradition`, `Tone`, `AppSettings`, `NotificationSettings` |
| Content | `ContentProvenance`, `PrecisionTier`, `ReadingCategory`, `HoroscopeReading`, `ReadingBasis`, `BasisFactor` |
| Chart, shared | `ChartSystem`, `SystemChart`, `ChartFeature`, `ChartTriad`, `SignProfile`, `GlossaryTerm`, `PlacementDetail` |
| Chart, Western | `WesternSign`, `Planet`, `Ecliptic`, `PlanetPlacement`, `AspectKind`, `Aspect`, `House`, `Transit`, `WesternChart` |
| Chart, Vedic | `Rashi`, `Graha`, `Nakshatra`, `Bhava`, `GrahaPlacement`, `DashaLevel`, `DashaPeriod`, `VedicChart` |
| Chart, Chinese | `HeavenlyStem`, `EarthlyBranch`, `WuXing`, `PillarPosition`, `Pillar`, `DayMaster`, `LuckCycle`, `ChineseChart` |
| Sky | `SkyRegister`, `EventRelevance`, `EventTime`, `MoonPhase`, `MoonIngress`, `SkyEvent`, `SkySnapshot`, `SkyPosition` |
| Circle | `RelationshipRole`, `CirclePerson`, `CompatibilityAxis`, `CompatibilityVerdict`, `CompatibilityAxisReading`, `CompatibilityReading`, `GeneralCompatibilityReading`, `PreciseCompatibilityReading` |
| Ask | `AskRole`, `AskMessage`, `AskConversation`, `AskSuggestion` |

### Compatibility

Four axes, identical at both tiers so the vocabulary a person learns from the general reading still applies to the precise one: **Love & Chemistry, Communication, Emotional Connection, Conflict & Pace**. Verdicts are qualitative — **Strong, Balanced, Mixed, Friction** — each with the sentence that justifies it.

There is no score, no percentage and no ordering anywhere in this subtree. `CompatibilityVerdict` is deliberately not `Comparable` and has no case meaning "incompatible".

"Shared values" is deliberately not an axis: it cannot be responsibly inferred from two Sun signs, so it appears only inside precise prose, where there are two charts to support it.

### Ecliptic

`Ecliptic.longitudeDegrees` is the single value a real ephemeris will populate. The sign, the formatted degree and the position on the chart wheel are all derived from it, so replacing fixture content with calculated content changes one number per body and nothing downstream.

## Persistence schema — `HumaySchemaV1`

| Entity | Notes |
|---|---|
| `UserProfileEntity` | one row; birth date as three `Int`s, time as a kind discriminator plus optional minutes, place as optional name/lat/lon/zone |
| `AppSettingsEntity` | one row; tradition and tone as raw strings, notification flags as `Bool` |
| `CirclePersonEntity` | same birth fields plus a relationship raw value |
| `AskConversationEntity` | cascade relationship to messages |
| `AskMessageEntity` | role raw value, text, optional basis line, provenance fixture identifier |

The birth-time discriminator is what decides the domain case, never the presence of a value — a stored zero is a legitimate midnight birth, and the absence of a *kind* is what means unknown. `BirthMapper` is the only code that knows this encoding, and `RepositoryTests` asserts both directions.

Mappers (`UserProfileMapper`, `CirclePersonMapper`, `AppSettingsMapper`, `AskMapper`) are pure free functions, testable without a store.

## Not modelled

Entitlements, purchases, rewarded unlocks, cached provider results, catalog versions, notification schedules and anything relating to a backend. Access is a separate concern with its own lifecycle; a stub here would be an architecture to delete rather than a head start.
