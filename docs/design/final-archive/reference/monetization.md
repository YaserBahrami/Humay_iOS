# Monetization — Free, Rewarded Access, Premium

**Purpose:** The three-tier monetization model and its rewarded-ad mechanics.

**Current authority:** Pass 4.1 is the monetization reference, **subject to Pass 6/6.1 corrections** below. Pass 6.1 is controlling wherever it conflicts with Pass 4.1 or Pass 6.

**Source artifacts:** `Product Design - Pass 4.dc.html` (§07 Premium architecture), `Product Design - Pass 4.1 - Rewarded Access.dc.html`.

**Final decisions:**
- Hierarchy is strict: **Free → Rewarded Access → Premium**. Rewarded access never outranks Premium and is never framed as equal to it.
- Two rewarded-entitlement shapes only: a **single-use unlock** (e.g. Ask's extra question) and a **persistent unlock that stays unlocked** (e.g. a Compare Systems breakdown once granted). There is no third shape (Pass 6.1 §"Two rewarded entitlement shapes, and only two").
- Persistent rewarded unlocks, once granted, **stay unlocked** — they do not re-lock or expire.
- Saved People capacity is **not** part of the rewarded system (see `product-completion.md`).
- Premium must never be described as permanent (e.g. no "lifetime" language) — it is a subscription framed as durability of value, not permanence of the deal.
- Ad states are always recoverable: every technical ad failure has a retry or fallback path, never a dead end.

**Canonical screens:**
| Screen | File |
|---|---|
| Full paywall | `previews/monetization/monetization-01-premium-paywall.png` |
| Rewarded gate (contextual unlock, generic pattern) | `previews/monetization/monetization-02-rewarded-gate.png` |
| Ask rewarded extension | `previews/monetization/monetization-03-ask-rewarded-extension.png` |
| Rewarded ad states / unlocked confirmation | `previews/monetization/monetization-04-unlocked-confirmation.png` |
| Premium sheet, updated (acknowledges rewarded access) | `previews/monetization/monetization-05-premium-sheet-updated.png` |

Overview: `previews/overviews/monetization-overview.png`

**Supersession notes:** Pass 4.1's "+1 Saved People slot per ad" is reversed by Pass 6.1, as is Pass 6's approval of it. All other Pass 4.1 monetization mechanics stand.

> Prototype astrology values shown in design artifacts are illustrative only and must not be used as engineering fixtures. Deterministic astrology engines and validated outputs are the source of truth.
