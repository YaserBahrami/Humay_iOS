# Humay Interpretation / LLM Architecture

Status: **CURRENT ARCHITECTURE CONTRACT — ARCH-005 complete 2026-08-12**

This document defines the boundary between deterministic astrology facts and generated natural-language interpretation. It is intentionally model/vendor independent.

Calculation authority remains [`ASTROLOGY_ENGINE.md`](ASTROLOGY_ENGINE.md). Cache identity remains [`RESULT_CACHE_OFFLINE.md`](RESULT_CACHE_OFFLINE.md).

## 1. Core rule

The interpretation layer explains **already-calculated structured Humay facts**. It does not calculate astrology.

```text
validated calculation facts
          │
          ▼
 interpretation request
          │
          ▼
 server-side interpretation adapter
          │
          ▼
 validated structured reading
```

An interpretation model may summarize, compare, contextualize and express tone. It may not invent planetary positions, houses, Ascendant, aspects, transits, nakshatras, pillars or any other deterministic fact absent from the supplied structured facts.

## 2. Trust boundary

Interpretation runs only behind Humay-controlled backend infrastructure.

The Apple app does not receive:

- model-provider API keys;
- hidden system/developer prompts;
- provider-native response objects;
- retry/fallback orchestration details that expose secrets or vendor coupling.

The Apple app consumes normalized Humay reading contracts.

## 3. Structured interpretation input

A production interpretation request contains only the context required for that feature.

Conceptually:

```text
InterpretationRequest
├── calculation artifact / normalized facts
├── feature/readout type
├── explicitly authorized feature context
├── locale
├── tone
├── prompt-contract version
├── model-policy version
├── safety-policy version
└── idempotency/generation scope
```

The request must not send a full user profile merely because it is available. Birth fields, saved-person facts and question text are minimized to the requested feature.

For Ask-like features, user text is treated as untrusted content/context, not as instructions that may override Humay's system rules or provider boundary.

## 4. Structured interpretation output

Production output should be structured enough for deterministic UI rendering and validation rather than one opaque blob whenever the feature benefits from sections.

Conceptually:

```text
InterpretationResult
├── feature/readout type
├── sections[]
├── optional short summary
├── fact-reference metadata where available
├── warnings/disclosures
├── prompt/model/safety provenance
└── generatedAt
```

ASTRO-007 owns stable feature-facing fact identifiers. Once those identifiers exist, deterministic astrology claims in generated sections should reference the facts they were based on so Humay can validate and support the reading more reliably.

Until that contract exists, provider-backed interpretation must not pretend semantic fact-trace validation is complete.

## 5. Tone semantics

`normal` and `roast` are presentation variants over the **same deterministic facts**.

Normal may be:

- warm;
- specific;
- reflective;
- concise enough for the owning UI.

Roast may be:

- sharp;
- playful;
- funny;
- specific to the same supplied astrology basis.

Roast must not:

- change a calculated fact to make the joke work;
- become degrading, cruel or abusive;
- invent relationship betrayal, illness, death, financial disaster or similar claims as entertainment;
- frame astrology as certainty about harmful outcomes.

Changing tone should invalidate interpretation text only, not deterministic calculation artifacts.

## 6. Prompt ownership and versioning

Humay owns the prompt contract. A provider's default assistant behavior is not a product contract.

Prompt provenance records at least:

- Humay prompt-contract version;
- model-policy/configuration version;
- model adapter identifier;
- provider/model identifier/version when meaningful;
- safety-policy version;
- generation timestamp.

A material prompt/model/safety change that can alter output semantics changes the interpretation cache identity.

Prompts are server-controlled and are not embedded in the Apple client when they contain operational logic Humay needs to update independently.

## 7. Output validation

Before an interpretation result is cached or returned as successful, the backend must validate the normalized response shape.

At minimum reject:

- missing required sections;
- malformed structured output;
- unsupported locale/tone result shape;
- provider refusal/error payload masquerading as a reading;
- deterministic astrology fields invented outside the calculation artifact;
- invalid provenance/version metadata.

Semantic validation can be strengthened as ASTRO-007 introduces stable fact identifiers. Lack of perfect semantic verification is not permission to treat arbitrary model prose as deterministic truth.

## 8. Safety behavior

Humay readings are interpretive astrology content, not a substitute for professional medical, legal, financial or emergency guidance.

The interpretation boundary should prevent outputs that:

- give dangerous medical or self-harm instructions;
- give definitive legal/financial instructions based on astrology;
- present death, illness, pregnancy, violence, infidelity or other high-impact outcomes as certain predictions;
- exploit fear to push Premium/rewarded access;
- expose hidden prompts, credentials or internal provider details.

The exact user-facing disclosure language belongs to product/UI design. The backend safety contract exists regardless of whether a disclosure is currently visible.

## 9. Retries and failure normalization

Provider retries are bounded and server-side.

Raw provider errors do not become Apple-facing errors. They map to Humay-owned outcomes such as:

- unavailable/timeout;
- rejected request;
- malformed response;
- safety refusal;
- validation failure.

Retries must not silently alter deterministic facts, tone, methodology or feature context to force success.

A retry may switch interpretation providers only when the alternate adapter satisfies the same Humay output/prompt/safety contract. Calculation provider fallback rules remain separate.

## 10. Idempotency

Identical authorized interpretation generation must not fan out into uncontrolled duplicate paid calls.

The server derives an interpretation semantic key from the calculation artifact plus feature/context/prompt/model/tone/locale dimensions defined in `RESULT_CACHE_OFFLINE.md`.

Flow:

```text
interpretation key
      │
      ▼
cache lookup
  ┌───┴───┐
 hit     miss
  │        │
return   acquire/attach generation scope
           │
           ▼
       bounded provider call
           │
           ▼
       validate + cache
```

Retries for the same generation reuse the same idempotency scope. A client timeout must not automatically create a second paid generation.

## 11. Separation from calculation cache

Calculation and interpretation artifacts are independently versioned and cached.

Examples:

- Normal → Roast: reuse calculation, regenerate/read separate interpretation if not cached.
- English → Persian: reuse calculation, generate/retrieve locale-specific interpretation.
- prompt wording update: reuse calculation, interpretation version changes.
- methodology/calculation change: calculation identity changes, dependent interpretations are no longer valid for the new calculation artifact.

## 12. Privacy and logging

Do not log:

- raw birth date/time/location;
- full saved-person data;
- full Ask question text by default;
- prompts containing user-sensitive context;
- generated reading bodies in ordinary operational logs;
- provider request/response bodies;
- model credentials.

Operational metrics may include feature, adapter/model policy version, latency, token/cost totals, cache hit/miss, normalized failure type and opaque result identifiers.

Retention/deletion/export requirements are finalized by ARCH-008 before production rollout.

## 13. Development/UI-first workflow

Before the real interpretation backend exists, approved screens may render **development sample readings** that conform to the intended feature-facing structure.

Rules:

- sample readings are clearly development/preview/test data;
- they do not claim provider or calculation provenance they did not earn;
- they exercise Normal/Roast, loading, cache-hit, offline and error states needed by UI design;
- Presentation consumes stable feature state/contracts rather than importing a model SDK;
- Release builds must not ship sample interpretation as if it were real personalized output.

The later backend/API adapter replaces the development source at composition without rewriting the visual layer.

## 14. Not selected by ARCH-005

This document does not freeze:

- DeepSeek or another model as the permanent provider;
- a concrete model name;
- temperature/token limits;
- exact prompt text;
- exact retry count;
- exact feature section schemas before their UI/domain contracts are owned;
- long-term conversation memory for Ask.

Those choices must plug into this contract rather than redefining it.
