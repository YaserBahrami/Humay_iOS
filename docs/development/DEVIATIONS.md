# Deviations

This file records deliberate departures from the normal development sequence. A deviation is not a new design or product authority.

---

## DEV-001 — Mock-first iOS implementation ahead of Phase 00 exit

**Status:** OPEN  
**Opened:** 2026-08-11  
**Directed by:** product owner

### Normal rule

Production feature implementation should follow the Phase 00 architecture freeze and the current visual/access contracts.

### Directed exception

Build a first working iOS application with **mock/local data only** to establish architecture, navigation, reusable UI infrastructure, major screens, realistic fixture content and complete primary flows before provider/backend work is available.

Explicitly excluded from this track: astrology calculation APIs, LLM/AI providers, backend services, authentication, StoreKit/subscriptions, advertisements and analytics.

### What this track does not satisfy

- Phase 00 is not complete.
- Phase 01 production exit criteria are not complete.
- No provider-backed feature is production-complete merely because a mock screen exists.
- No astrological value in the mock-first app is calculation truth.
- Methodology blockers remain unchanged.
- The mock-first UI is not the current visual authority; final UI follows the active D0–D9 Light/Dark design program.

### Compensating controls

1. Content-bearing domain values carry explicit `ContentProvenance`.
2. Mock services emit `.mockFixture` provenance and are covered by provenance tests.
3. DEBUG builds visibly mark sample/mock basis where appropriate.
4. Fixture content is contained under `Humay/Data/Mock/Fixtures/`.
5. No paid-provider/network/payment/ad/analytics integration was added by the mock track.
6. No fake entitlement/token system was introduced.
7. `FactValue<T>` keeps unknown birth time and pending methodology explicit rather than substituting values.

### Current reconciliation rule

The mock-first app may continue to serve as a route, architecture and accessibility test bed. Any screen receiving production visual polish must use the current design authority:

- `docs/design/DESIGN_AUTHORITY.md`
- `docs/design/SOULFUL_CELESTIAL_DESIGN_DIRECTION.md`
- `docs/design/SCREEN_DESIGN_PLAN.md`
- approved references under `docs/design/soulful-reference/`

### Exit condition

DEV-001 closes when Phase 00 is complete and production services/access primitives replace the mock-only path sufficiently for normal feature work to proceed.

At closure:

- `Humay/Data/Mock/` is replaced rather than extended for production behavior;
- access-state primitives follow the production entitlement/cache architecture;
- affected screens are re-reviewed against their approved current Light/Dark references before feature tasks are marked production-complete.
