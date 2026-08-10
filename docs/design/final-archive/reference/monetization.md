# Monetization — Free, Rewarded Access, Premium

**Purpose:** The three-tier monetization model and its rewarded-ad behavior.

**Current authority:** Pass 4.1 is the monetization reference, **subject to explicit Pass 6 / Pass 6.1 corrections**. Pass 6.1 controls wherever it explicitly supersedes Pass 4.1 or Pass 6.

**Source artifacts:** `Product Design - Pass 4.dc.html`, `Product Design - Pass 4.1 - Rewarded Access.dc.html`, plus the Pass 6 / 6.1 correction layers.

**Final decisions:**
- Hierarchy is strict: **Free → Rewarded Access → Premium**. Free remains useful; Rewarded Access is optional; Premium is the best access tier.
- Rewarded Access has exactly two approved behavioral shapes:
  1. **Persistent content unlock** — one completed rewarded ad unlocks one identified reading/section; that item stays unlocked, survives restart, and never asks again.
  2. **Immediate Ask extension** — one completed rewarded ad permits one additional Ask question; the grant is single-use and is not stored or displayed as currency/balance.
- There is no third reward-currency shape: no coins, credits, tokens, energy, stacking balance or wallet UI.
- Saved People capacity is **not** part of Rewarded Access. Pass 4.1 left this under review; Pass 6 temporarily approved `+1 slot per ad`; Pass 6.1 reverses that decision. Free has a base Saved People limit and Premium a larger limit; exact numbers remain product configuration.
- Premium follows a valid subscription entitlement and must never be described as permanent or lifetime access unless a future product explicitly offers such a product.
- Rewarded-ad failure states must remain recoverable; normal reading/navigation must never be trapped behind an ad failure.

**Canonical visual references:**
- [Full paywall](../previews/monetization/monetization-01-premium-paywall.png)
- [Rewarded gate](../previews/monetization/monetization-02-rewarded-gate.png)
- [Ask rewarded extension](../previews/monetization/monetization-03-ask-rewarded-extension.png)
- [Unlocked confirmation](../previews/monetization/monetization-04-unlocked-confirmation.png)
- [Premium sheet, updated](../previews/monetization/monetization-05-premium-sheet-updated.png)
- [Monetization overview](../previews/overviews/monetization-overview.png)

**Supersession notes:** The Saved People rewarded-capacity idea was unresolved in Pass 4.1, temporarily approved in Pass 6, then explicitly rejected in Pass 6.1. Other Pass 4.1 behavior stands unless Pass 6 / 6.1 explicitly says otherwise.

> Prototype astrology values shown in design artifacts are illustrative only and must not be used as engineering fixtures. Deterministic astrology engines and validated outputs are the source of truth.
