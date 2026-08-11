# Phase 08 — Ask the Stars

Status: **TODO**
Depends on: Phase 02, Phase 07, ARCH-005, ARCH-007

Goal: implement contextual astrology Q&A over validated structured facts without creating an uncontrolled Free LLM cost path.

## Tasks

### ASK-001 — Define Ask request/context contract
Status: TODO

Acceptance:
- Includes selected system, relevant structured facts, question, locale/tone and access context.
- Missing/unsupported calculations are represented explicitly.

### ASK-002 — Implement Ask orchestration/provider abstraction
Status: TODO
Depends on: ASK-001

Acceptance:
- DeepSeek V4 Flash is an initial provider choice behind a replaceable interface.
- Retries/timeouts/errors/idempotency are typed.
- Interpretation cannot silently invent chart facts.

### ASK-003 — Implement question/answer UI
Status: TODO
Depends on: ASK-002

Acceptance:
- Matches reconciled Humay design.
- Answer can expose astrological basis/factors.
- Cached/reopened answer behavior is explicit where applicable.

### ASK-004 — Implement safety and unsupported-data behavior
Status: TODO
Depends on: ASK-002

Acceptance:
- Sensitive-life-event constraints are enforced.
- Unknown-time/methodology limitations reach the context.
- Unsupported calculation state differs from provider/network failure.

### ASK-005 — Implement Ask access decision
Status: TODO
Depends on: ASK-003

Acceptance:
- Access/cache decision happens before any paid model generation.
- Ordinary Free use cannot cause an uncached paid Ask generation unless a later explicit product budget decision supersedes this rule.
- Premium access remains configurable by product policy.

### ASK-006 — Implement rewarded one-question generation
Status: TODO
Depends on: ASK-005, MON-004 contract

Acceptance:
- One successful rewarded completion authorizes one additional provider-backed question/answer generation.
- It is single-use, not a bankable balance/token/currency.
- Ad/provider failure recovery is explicit.

## Exit criteria

- Ask only uses supplied/validated astrology context.
- No uncontrolled Free provider path exists.
- Safety, insufficient-data, entitlement and provider-failure states are distinct/tested.
