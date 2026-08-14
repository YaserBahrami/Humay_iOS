# Phase 08 — Ask the Stars

Status: **TODO**

Depends on:
- Phase 01 platform/design-system foundation;
- stable structured astrology/context contracts required by the questions Humay supports;
- ARCH-005 interpretation boundary;
- ARCH-007 access/entitlement contract;
- approved D5 cross-device design references before feature-specific UI implementation.

Goal: implement contextual astrology Q&A over validated structured facts without creating an uncontrolled Free paid-model path.

The D5.1 UI-first presentation slice is implemented over a Debug-only sample fixture and reconciled against the approved D5 reference package. The production provider, access, persistence and methodology tasks below remain TODO.

## Tasks

### ASK-001 — Define Ask request/context contract
Status: TODO

Acceptance:
- includes selected system, relevant structured facts, question, locale/tone and access context;
- missing/unsupported calculations are explicit;
- only the minimum relevant profile/context data is sent.

### ASK-002 — Implement Ask orchestration/provider abstraction
Status: TODO  
Depends on: ASK-001, ARCH-005

Acceptance:
- the selected interpretation provider is behind a replaceable Humay interface;
- retries/timeouts/errors/idempotency are typed;
- interpretation cannot silently invent chart facts;
- client code does not hold provider secrets.

### ASK-003 — Implement D5 question/answer UI for iPhone + iPad
Status: TODO  
Depends on: ASK-002, approved D5 package

Acceptance:
- uses current Design Authority and approved D5 references;
- iPhone Light/Dark and iPad Light/Dark are intentional compositions;
- long-form conversation width is bounded on iPad;
- answer can expose the astrological basis/factors actually supplied;
- cached/reopened answer behavior is explicit where applicable.

### ASK-004 — Implement safety and unsupported-data behavior
Status: TODO  
Depends on: ASK-002

Acceptance:
- sensitive-life-event constraints are enforced;
- unknown-time/methodology limitations reach the context;
- unsupported calculation state differs from provider/network failure.

### ASK-005 — Implement Ask access decision
Status: TODO  
Depends on: ASK-003, ARCH-007

Acceptance:
- access/cache decision happens before any paid model generation;
- ordinary Free use cannot cause an uncached paid Ask generation unless a later explicit product decision changes this rule;
- Premium behavior remains product-policy driven and cache-first.

### ASK-006 — Implement rewarded one-question generation
Status: TODO  
Depends on: ASK-005, rewarded-ad/entitlement implementation

Acceptance:
- one successful rewarded completion authorizes one needed provider-backed question/answer generation;
- it is single-use, not a bankable balance/token/currency;
- provider failure recovery is explicit and idempotent.

## Exit criteria

- Ask only interprets supplied/validated astrology context;
- no uncontrolled Free paid-provider path exists;
- safety, insufficient-data, entitlement and provider-failure states are distinct/tested;
- shipping Ask surfaces reconcile with approved D5 iPhone+iPad Light/Dark references.
