# D5.1 Ask the Stars — design specification

**Status: REVIEW CANDIDATE — NOT APPROVED**

## 1. Product role

Today gives guidance. Circle gives relationship perspective. Sky gives current celestial context. Chart gives personal celestial structure. Ask gives a focused question interpreted through the astrology context Humay is actually authorized to use.

The working concept is **Celestial Correspondence**:

```text
focused question
        |
        v
considered reading
```

The vertical line is a relationship in the concept, not a UI instruction to show an assistant transcript. The screen uses editorial hierarchy, a bounded reading column and selective celestial personality.

## 2. Scope and non-goals

This package covers:

- empty/question-entry state;
- answer/reading state;
- generating state;
- future Rewarded Access presentation;
- Premium accommodation without a D7 paywall;
- cached/reopened answer behavior;
- offline with and without a cached answer;
- provider failure and fair recovery pressure;
- insufficient astrology context;
- unsupported methodology and safety refusal language;
- iPhone, iPad portrait, iPad landscape and narrow Split View composition;
- accessibility, keyboard and composer behavior;
- the minimum provider-independent Ask presentation contract.

This package does not design long-term chat history, a conversation sidebar, provider/model branding, a full Premium paywall, rewarded-ad mechanics, subscription UI, backend/API, LLM orchestration, conversation persistence, D6 Settings or production Ask code.

## 3. Empty / question-entry state

### Purpose

The root Ask tab must answer four questions before the user types:

1. What can I ask?
2. What astrology context can Humay use?
3. What happens before an answer is generated?
4. What kinds of questions work well?

### iPhone hierarchy

1. Ask identity and profile entry.
2. Editorial invitation: **What’s on your mind?**
3. One compact folded-note/orbit illustration beside the invitation.
4. Prominent native multiline composer.
5. Small suggested-question set.
6. Quiet context/access disclosure.

The composer appears before a large hero. The first fold shows the input action and at least part of the suggestion/context treatment.

### iPad hierarchy

Regular width uses two bounded regions rather than a stretched phone:

- leading region: invitation, what works well, suggested questions and context scope;
- main region: compact illustration above the composer and the composer as the action center.

Narrow Split View collapses to the iPhone reading order before text becomes cramped.

### Copy boundary

Preferred language includes:

- **Ask the stars**;
- **What’s on your mind?**;
- **Ask a focused question. Humay answers from the astrology context available for it.**

Avoid “Ask me anything.” Ask is not an unrestricted general-purpose assistant.

## 4. Authored illustration concept

The candidate asset is a small folded note carried through a restrained orbit around a moon/star mark. It communicates a question carried into the sky without using a robot, AI sparkle logo, neon speech bubble or dominant crystal ball.

Rules:

- flat/vector, warm and slightly playful;
- simple enough to compose separately for Light and Dark;
- illustration is subordinate to the composer;
- sparse orbit and star marks only;
- hidden from VoiceOver when decorative;
- future semantic name: `IllustrationAskStars`;
- reference-only until product-owner approval and a later asset-promotion decision.

## 5. Composer

The composer is a native-feeling multiline input, not a chat bubble.

| Decision | Candidate rule |
|---|---|
| Shape | One quiet rounded surface with a thin hairline and one restrained accent. |
| Growth | Expands for approximately 2–5 lines before the text area scrolls. No fixed height that clips Dynamic Type. |
| Action | A labeled `Ask` action remains visible and understandable; do not rely on a tiny icon-only send control. |
| Disabled state | Empty question leaves the action visibly disabled with a text label, not opacity alone. |
| Enabled state | Filled coral action, still native and calm. |
| Length | No invented character count or fake fixed limit before a product contract exists. |
| Keyboard | Composer and action remain above the keyboard; the action is never covered by a tab tray or keyboard. |
| Accessibility | Label, hint, value, focus state and activation behavior are exposed through native controls. |
| Decoration | No typing dots, neon glow or dense star field. |

The composer does not trigger a paid call. Question entry and access/generation are separate concepts.

## 6. Suggested questions

Show a small authored set that explains the product:

- **What should I focus on today?**
- **How can I work with my Moon in Libra?**
- **What pattern should I notice in relationships?**

These are examples for the reference package, not a frozen production prompt library. Suggestions must not imply unsupported facts or certainty. Use full-width native rows or chips with comfortable wrapping; do not make a dense prompt catalogue.

## 7. Context presentation

Use a quiet disclosure such as:

> Using: Western · your available chart context

Supporting copy explains that only relevant structured context is used. The surface must not expose provider, model name, raw prompt, backend artifact ID or a full birth profile. Exact birth date/time/location appears only when directly needed and product-approved.

The visual distinction is important:

- the answer body is interpretation;
- the context/basis region contains supplied facts and their reliability/basis;
- neither is represented as an opaque provider response.

## 8. Answer / reading state

The answer reads as a Humay reading, not as an assistant bubble stack.

### Primary fixture

Question:

> How can I work with my Moon in Libra?

Supplied sample facts:

- Western;
- Tropical;
- Moon in Libra;
- `14° 27′`;
- 5th house;
- known-time development fixture;
- sample reliability supplied by the fixture.

The primary answer references contain one quiet disclosure: **Development sample · not generated**.

### Answer anatomy

1. compact original-question identity;
2. short editorial opening, one or two sentences;
3. two or three structured sections;
4. practical/reflection section where appropriate;
5. **What this answer used** factual basis;
6. Ask another question / return action.

Candidate section language:

- **Balance before reaction**
- **Make room for beauty and play**
- **Try this**

Interpretive copy may use only supplied factors. It may use language such as “may,” “can,” “points toward” and “worth noticing.” It must not introduce planets, aspects, houses or life claims absent from the supplied fixture.

### Fact and interpretation hierarchy

The answer body is interpretation. The basis region contains:

- Moon in Libra;
- `14° 27′`;
- 5th house;
- Western · Tropical;
- known-time development fixture.

The basis is a compact trustworthy region, preferably inline/disclosure-style in V1. No provider provenance is shown.

### iPhone answer

Use one bounded reading column. Keep the original question compact but visible. Let answer sections breathe on the warm ground. One selective cosmic surface may hold the practical reflection; do not turn every paragraph into a card. Keep cached/offline disclosure, basis and new-question action clear.

### iPad answer

Regular width uses:

- leading bounded rail: original question and basis/context summary;
- main bounded reading column: editorial answer.

The main prose measure remains comfortable. No conversation-history sidebar. No full-width prose spanning the iPad canvas. Narrow Split View collapses the rail below the question or above the answer.

## 9. Generating state

Generating is a calm transition, not a fake answer.

Candidate copy:

- **Reading the context you shared…**
- **Putting the pieces together…**
- **No answer has been generated yet.**

The state may show the submitted question, a small orbit/note treatment and stable skeleton lines. It must not show fabricated answer paragraphs, deterministic calculation progress, fake percentage completion or typing dots that imply a human conversation.

If the calculation artifact already exists, copy must not imply that astrology is being recalculated. The state represents interpretation generation only.

Motion concept:

- slow small orbit or gentle correspondence movement;
- no particle storm;
- no looping mascot;
- Reduce Motion shows the same static composition and removes the movement.

## 10. Access states

Access is separate from question composition and calculation truth.

Conceptual flow:

```text
compose question
      |
      v
evaluate cache and access
   /              \
cached          generation needed
  |                   |
reopen       Rewarded Access or Premium
                          |
                      generating
                          |
                        answer
```

### Rewarded Access

Hierarchy:

1. **Your question is ready**;
2. short explanation;
3. **Watch an ad for this answer**;
4. calm Premium alternative.

One successful rewarded completion authorizes one needed provider-backed generation for this question/result key. It is not coins, stars currency, a credit wallet, a token balance or temporary Premium. Ask should not look like an ad screen.

### Premium

Only show enough to establish the alternative path:

> Premium members can ask included questions without this per-generation step.

The full paywall, plan detail, StoreKit and entitlement implementation belong to D7/ARCH-007.

### Cached reopen

If the exact valid answer exists:

- reopen the answer;
- consume no new reward;
- make no new provider generation;
- show a quiet Saved/Cached indicator when useful;
- preserve basis, validity/freshness and source disclosure.

The user must not unlock the same valid answer again.

## 11. Offline, failure and context states

These states must be visually distinct:

| State | Visual/copy direction | Forbidden implication |
|---|---|---|
| Offline + cached answer | Answer remains readable with `Offline · saved answer` and saved-time/freshness context. | Do not imply current generation. |
| Offline + no cache | `A new answer needs a connection.` Keep the submitted draft if later product policy allows. | Do not silently queue paid generation or consume reward. |
| Provider failure | `Humay couldn’t finish this reading.` Calm retry/recovery placeholder owned by later contracts. | Do not expose provider name, HTTP code, timeout or stack. |
| Reward completed, provider failed | Explain that the authorized generation needs fair retry/recovery; do not ask for another reward for the same scope. | Do not invent a bankable credit or silently consume again. |
| Insufficient context | Show what Humay knows and what is missing. | Do not invent a house, Ascendant, aspect or chart. |
| Unsupported methodology | Explain that this question needs a method/context not available or approved. | Do not collapse into generic network failure. |
| Safety refusal | Decline astrology-based high-stakes guidance and redirect to an appropriate real-world source of help. | Do not generate a probability or certainty claim. |
| Malformed/validation failure | `This reading could not be verified.` Offer later Humay-owned recovery. | Do not present provider text as a valid answer. |

Safety example pressure case:

> “Should I stop taking my medication because of my chart?”

The response declines the astrology-based decision, recommends a qualified healthcare professional or emergency help when appropriate, and stays concise. Similar rules apply to legal, financial, emergency, death, illness, pregnancy, violence, infidelity and financial-disaster certainty claims.

## 12. Prediction certainty

Ask must not present high-impact outcomes as certain astrology predictions. The reading language remains reflective and non-deterministic. No certainty percentage, risk score or pseudo-clinical confidence meter is introduced.

Normal is the primary D5 register. No Ask-specific Roast toggle is introduced. The architecture may accommodate Normal/Roast later as variants over the same facts; this package does not expand into a Roast pass.

## 13. Typography

Use the frozen global system:

- Cormorant Garamond: Humay wordmark only;
- Newsreader: Ask editorial title and major reading headline;
- SF Pro/system: question, body, composer, buttons, basis labels and supporting copy;
- SF Mono/system: not for ordinary Ask text; existing technical role may format degree values in factual basis when useful.

No new font or provider-branded type is introduced. Dynamic Type remains the source of truth for production sizes.

## 14. Surfaces and color

Light uses warm cream ground, off-white surfaces, quiet hairlines, a restrained lavender/blue context tone and small coral actions. Dark uses midnight/navy ground, tonal raised surfaces, warm ivory text and controlled brighter accents.

Ask may lean slightly lavender/celestial blue, but it must not become “the purple AI tab.” No neon assistant glow. Dark mode is authored separately rather than inverted.

Recommended geometry follows the current system:

- feature/editorial surfaces: approximately 18–24 pt radius;
- compact rows: approximately 14–18 pt radius;
- labeled primary actions: pill/high-radius control;
- soft elevation in Light only where it aids grouping;
- tonal separation before shadows in Dark.

## 15. Reusable presentation pieces for later review

Candidate pieces, not production implementation:

- Ask header/profile entry;
- focused question composer;
- suggested-question row;
- context/basis disclosure;
- question identity card;
- structured reading section;
- saved/offline disclosure;
- access presentation card;
- safety/context unavailable state;
- folded-note/orbit illustration.

The later UI-first slice should compose these from existing Humay typography, colors, metrics, surfaces and native controls. It should not create an Ask-specific design system.
