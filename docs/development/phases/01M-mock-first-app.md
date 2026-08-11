# Phase 01M — Mock-First iOS Application

**Status:** COMPLETE — 2026-08-11  
**Deviation:** [`DEV-001`](../DEVIATIONS.md)

This completed parallel track established a launchable/navigable iOS application over fixture content before Phase 00 production architecture was finished. It remains an engineering history and test-bed record, **not a current design plan or visual authority**.

## Purpose and boundaries

Delivered:

- Xcode project/configuration and test targets;
- app/domain/data/presentation/design-system layering;
- SwiftData V1 schema/migration foundation;
- mock service/repository boundaries with explicit provenance;
- root navigation for Today / Circle / Sky / Chart / Ask;
- onboarding/profile/settings flows;
- Today general/precise mock flows;
- Circle/people/compatibility mock flows;
- Sky/calendar/event-detail mock flows;
- Western/Vedic/Chinese Chart mock flows and glossary;
- Ask mock conversation flow;
- accessibility, Dynamic Type, Reduce Motion and architecture documentation.

Explicitly excluded:

- production astrology calculation providers;
- LLM/interpretation providers;
- backend/networking services;
- authentication;
- StoreKit/subscriptions;
- advertisements;
- analytics;
- production entitlement/cache behavior;
- iPad layouts.

## Standing provenance rules

- Every content-bearing domain value carries non-optional `ContentProvenance`.
- Mock services emit `.mockFixture`.
- Fixtures live under `Humay/Data/Mock/Fixtures/` and are replaced rather than migrated into production logic.
- No hidden fake birth time is used.
- Methodology-pending facts remain explicitly unavailable.
- No mock screen or fixture validates real astrology output.

## Current visual relationship

The Phase 01M UI is an existing implementation baseline only. It may be used to verify:

- route coverage;
- state coverage;
- reusable SwiftUI architecture;
- VoiceOver order;
- Dynamic Type reflow;
- hit targets;
- Reduce Motion behavior.

It must **not** be used as visual authority.

Current visuals are defined exclusively by:

1. [`../../design/DESIGN_AUTHORITY.md`](../../design/DESIGN_AUTHORITY.md)
2. [`../../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`](../../design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md)
3. [`../../design/SCREEN_DESIGN_PLAN.md`](../../design/SCREEN_DESIGN_PLAN.md)
4. approved references under `../../design/soulful-reference/`

When a current screen design conflicts with the existing mock-first appearance, the current design wins while retaining valid accessibility/architecture behavior.

## Completed task groups

### Foundation

- `IOS-001` project/build configuration
- `IOS-008` test targets
- `IOS-002` layer structure/composition root/enforcement scripts
- `IOS-003` initial reusable design-system infrastructure
- `IOS-004` navigation shell
- `IOS-006` versioned SwiftData persistence
- `IOS-005` shared presentation components
- `IOS-007` diagnostics/configuration

### Mock data/domain

- `MOCK-001` mock content boundary
- `MOCK-002` domain model
- `MOCK-003` horoscope fixtures
- `MOCK-004` provenance sweep/tests

### Product flows

- `PROFILE-101` onboarding/profile persistence
- `PROFILE-102` profile/settings
- `TODAY-101` Today general
- `TODAY-102` Today precise mock
- `CIRCLE-101` Circle people
- `CIRCLE-102` Circle visualization
- `CIRCLE-103` Compatibility mock
- `SKY-101` current Sky
- `SKY-102` Calendar
- `SKY-103` Event detail
- `CHART-101` Chart general
- `CHART-102` full system-specific Chart
- `CHART-103` glossary
- `CHART-104` Western chart wheel
- `CHART-105` placement detail
- `ASK-101` Ask mock flow

### Polish

- `IOS-009` motion/haptics with Reduce Motion alternatives
- `IOS-010` accessibility
- `IOS-011` architecture documentation
- `IOS-012` shared-layout/accessibility reconciliation

## Accessibility lessons retained

The completed pass found and fixed implementation issues that remain relevant regardless of styling:

- onboarding actions must remain reachable at accessibility text sizes;
- display/title roles must preserve hierarchy as Dynamic Type grows;
- interactive targets stay at least 44pt;
- label/value rows and chart groups reflow rather than compress;
- glossary/definition content must scroll when necessary;
- calendar dates require typography/layout that cannot wrap mid-number;
- fixed-geometry decorative visuals must provide accessible alternatives or step aside when they obstruct content.

## Current compatibility note

The existing Phase 01M compatibility model uses qualitative dimensions. Current design authority permits numeric compatibility presentation, but this does not retroactively create a production scoring algorithm. Before shipping numeric scores, product/methodology must define the actual computation/semantics and implementation must be updated accordingly.

## Verification at completion

At Phase 01M close:

- the app built and launched on iPhone simulator targets;
- unit/UI tests passed;
- layering and nomenclature scripts passed;
- every shown astrology value remained traceable to mock fixtures;
- no production provider/payment/ad/analytics/authentication integration existed.

## Relationship to production roadmap

Phase 01M does **not** satisfy Phase 00 or Phase 01 production exit criteria. It does not mark provider-backed feature tasks complete.

When Phase 00 and production integrations advance:

- mock services are replaced behind existing protocols;
- production access/cache primitives follow `ARCH-007`/related architecture;
- each feature family receives final visual polish only from its approved current Light/Dark references.
