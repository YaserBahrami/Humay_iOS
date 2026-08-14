# D5.1 Ask contract review notes

**Status: REVIEW CANDIDATE — NOT APPROVED**

This is a documentation-level recommendation for ASK-001 and the later presentation boundary. It does not add Swift types, production routes or provider adapters.

## 1. Minimum Humay-owned envelope

The future Ask surface needs a provider-independent envelope that keeps question, context, interpretation, access, cache and safety concerns distinct.

### AskQuestion

Recommended fields:

- `questionText`: user-authored text, treated as untrusted content;
- `locale`;
- `tone`: existing `normal` / `roast` accommodation, with Normal as D5 primary;
- `selectedTradition` or system identifier;
- `contextScope`: the minimum authorized context requested for this question;
- `accessContext`: Free, Rewarded-available, Premium or already-authorized generation scope;
- opaque request/idempotency scope owned by Humay orchestration, not a provider DTO.

Question text must not carry hidden instructions that override Humay system, safety, access or provider rules.

### AskContext

Recommended fields:

- stable Humay-owned fact references or normalized relevant fact projections;
- fact display values only when the presentation needs them;
- reliability/uncertainty/unavailability per supplied fact;
- selected methodology/system and basis;
- source disclosure: production, cached, offline cached or Debug-only sample;
- calculation artifact identity/digest where the later cache boundary needs it;
- context validity/freshness metadata where time-sensitive.

AskContext must not be a full profile dump. It must not contain vendor-native response objects, model prompts, provider secrets, all chart facts or unrelated Sky/People data.

### AskAnswer

Recommended fields:

- short summary/opening;
- ordered structured sections;
- optional practical/reflection section;
- supplied fact references used by each section where ASTRO-007/future fact IDs support it;
- warnings/disclosures/safety notes;
- locale/tone and Humay prompt/model/safety provenance when returned to the app at the approved level;
- generated/cached timestamp and valid-through metadata as appropriate;
- opaque result/artifact identity, never provider-native payload.

The app should be able to render sections deterministically rather than receiving one opaque text blob.

### AskState

The presentation envelope should be able to represent at least:

| State | Required meaning |
|---|---|
| `empty` | No question submitted; composer is ready. |
| `readyToSubmit` | Valid question draft; no paid call has started. |
| `accessRequired` | Generation is needed and access must be resolved first. |
| `generating` | Authorized interpretation generation is in progress; no answer yet. |
| `loaded` | Valid current answer returned. |
| `cached` | Exact valid answer reopened without new generation/access. |
| `offlineCached` | Local valid answer reopened while offline, with freshness/saved disclosure. |
| `offlineNoCache` | No local answer; new generation cannot start offline. |
| `insufficientContext` | Relevant structured context is missing/uncertain. |
| `unsupported` | System/methodology/calculation boundary cannot support the question. |
| `safetyRefusal` | Humay will not answer the question as astrology-based high-stakes guidance. |
| `failed` | Humay-owned normalized failure with recovery category. |

Access and calculation must remain separate within these states. `accessRequired` is not proof that calculation succeeded. `cached` is not a new entitlement event. `offlineCached` is not current generation.

## 2. Failure taxonomy

Raw provider/network errors must not cross into Presentation. The later Data boundary should normalize to Humay-owned categories such as:

- unavailable/timeout;
- request rejected;
- malformed response;
- safety refusal;
- validation failure;
- unsupported methodology;
- insufficient context;
- offline/no cache.

The UI can share a surface family, but it must not make provider failure look like missing astrology context or safety refusal.

## 3. Access and cache contract

The design encodes this sequence:

1. normalize question and relevant context;
2. derive the exact result identity;
3. check valid cache before consuming reward or calling a provider;
4. reopen exact cached answer when present;
5. if generation is needed, resolve Rewarded Access or Premium;
6. generate under one idempotent scope;
7. validate, cache and return structured answer;
8. support fair recovery if reward succeeded but generation failed.

The result identity should include only result-changing dimensions: relevant calculation artifact/digest, feature/context scope, question digest, prompt/model/safety policy versions, locale and tone. It must not expose raw question text or birth fields in logs.

Reward semantics remain exactly one successful rewarded completion for one needed provider-backed generation for the selected question/result key. No coin, star, credit or bankable token model is introduced.

## 4. Data minimization

The later Ask request should send only:

- the question text;
- requested locale/tone;
- selected system/methodology identifier;
- relevant authorized fact references/projections;
- reliability and unavailability needed to explain limits;
- opaque artifact/result identity and access scope.

It should not send or display the full user profile, all birth fields, all Chart facts, all Sky events or all Saved People data when irrelevant. Provider secrets, hidden prompts and vendor response objects stay server-side.

Logs/analytics should use opaque identifiers and normalized failure categories. Do not log raw question text, full birth/profile values, prompts containing sensitive context, reading bodies or provider request/response bodies by default.

## 5. Prompt-injection boundary

Question text is untrusted user content. It may be quoted in an interpretation request as the subject of the reading, but it cannot:

- override Humay system/developer rules;
- change the selected methodology or supplied facts;
- authorize a provider call;
- expose hidden prompts, credentials or internal provider details;
- disable safety, access, cache or privacy rules.

No UI surface exposes system prompts, model instructions, provider names or internal orchestration.

## 6. Interpretation truth boundary

The interpretation layer explains already-calculated structured Humay facts. It does not calculate astrology. The answer body may summarize, contextualize and express tone, but deterministic claims must be traceable to supplied context once stable fact identifiers exist.

The visual `What this answer used` region is therefore a deliberate architecture boundary, not decorative metadata.

## 7. UI-first recommendation for ASK-003

After product-owner approval of this D5 package, a later Presentation-only slice may use explicitly labeled Humay-owned Debug-only sample contracts in the same state shape. That slice may demonstrate entry, answer, generating, access and failure visuals before the real provider exists.

Production Ask remains blocked by:

- ASK-001 request/context contract;
- ASK-002 orchestration/provider abstraction;
- ARCH-007 access/entitlement/reward recovery;
- provider/backend/API implementation;
- safety/privacy/cache/idempotency integration;
- approved production methodology and relevant context boundaries.

This recommendation does not mark ASK-001 or ASK-002 complete, change Phase 08 status or authorize production Ask UI.
