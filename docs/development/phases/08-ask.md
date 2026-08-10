# Phase 08 — Ask the Stars

Status: **TODO**
Depends on: Phase 02, Phase 07, ARCH-005

Goal: implement contextual astrology Q&A over validated structured facts, not a generic chatbot.

## Tasks

### ASK-001 — Define Ask request/context contract
Status: TODO

Acceptance:
- Request includes selected system, relevant chart/timing facts, question and access context.
- Missing/unsupported calculations are represented explicitly.

### ASK-002 — Implement Ask orchestration and provider abstraction
Status: TODO
Depends on: ASK-001

Acceptance:
- Interpretation provider is replaceable.
- Retries/timeouts/errors are typed.
- No provider can silently calculate astrology facts.

### ASK-003 — Implement question and answer UI
Status: TODO
Depends on: ASK-002

Acceptance:
- Matches final archive.
- Answer can expose Astrological basis/Chart factors.
- Contextual entry from other insights is supported without duplicating facts.

### ASK-004 — Implement safety and unsupported-data behavior
Status: TODO
Depends on: ASK-002

Acceptance:
- Sensitive-life-event inference constraints are enforced.
- Unknown-time and methodology limitations reach the answer context.
- Unsupported calculation state is distinct from provider/network failure.

### ASK-005 — Implement Free/Premium allowance interface
Status: TODO
Depends on: ASK-003

Acceptance:
- Access decision happens before answer generation.
- Daily/period limits remain configurable rather than hard-coded product assumptions.

### ASK-006 — Implement rewarded immediate Ask extension
Status: TODO
Depends on: ASK-005, MON-004 contract

Acceptance:
- One successful rewarded completion permits one additional question.
- It is single-use, not a bankable balance/token/currency.
- No ad gate interrupts an answer already being generated.

## Exit criteria

- Ask answers only from supplied structured astrology context.
- Safety/insufficient-data/provider-failure states are distinct and tested.
- Access decisions happen before generation.
