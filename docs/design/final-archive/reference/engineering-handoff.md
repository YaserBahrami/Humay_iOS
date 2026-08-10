# Engineering Handoff & Final Freeze

**Purpose:** The authoritative handoff summary for what is frozen for build, plus the explicit corrections made in Pass 6 and Pass 6.1.

**Current authority:** Pass 6 is the engineering-handoff/audit record. **Pass 6.1 is the final correction/freeze layer — where it explicitly conflicts with Pass 6 or any earlier pass, Pass 6.1 wins.** This archive reflects Pass 6.1 as final.

**Source artifacts:** `Product Design - Pass 6 - Engineering Handoff and Final Audit.dc.html`, `Product Design - Pass 6.1 - Final Engineering Freeze.dc.html`.

**Final corrections locked by Pass 6.1:**
- Humay is the consumer brand; Eclipse is visual direction only; Astara is the repo/project working name only.
- Roast never appears in notifications — notifications are **Normal only**, with no Roast toggle.
- Saved People capacity is **not** rewarded-gated. Pass 4.1 left that mechanic under review; Pass 6 temporarily approved `+1 slot per ad`; Pass 6.1 reverses that Pass 6 decision. Free has a base limit and Premium a larger limit; exact numbers remain product configuration.
- Persistent rewarded-content unlocks, once granted, **stay unlocked** for that identified item.
- The Ask rewarded extension is **single-use** and is not a bankable currency/balance.
- No account/login infrastructure is assumed by design — use **local profile**, not account, for local user data.
- Premium must never be described as permanent.
- Unknown-birth-time behavior follows Pass 6.1's fact-by-fact uncertainty rules.
- Methodology-dependent features must not be presented as finalized calculation methodology while their listed methodology remains unresolved.
- Pass 6's zero-blocker wording is narrowed: there are no blockers to foundation work, but there are feature-specific methodology blockers.
- Design contracts define behavior and constraints; StoreKit mechanics, ad SDKs, persistence/sync, notification delivery, backend choices and similar implementation mechanics belong to technical architecture.

**Canonical screens:** none — Pass 6 and 6.1 are audit/handoff documents rather than new screen-design passes. See the other reference files and the PNG archive for visual references.

**Supersession rule:** Do not infer authority from pass number alone. Consult [`../../DESIGN_AUTHORITY.md`](../../DESIGN_AUTHORITY.md). Pass 6.1 controls only the scopes it explicitly supersedes; older artifacts remain authoritative where the authority map says they do.

> Prototype astrology values shown in design artifacts are illustrative only and must not be used as engineering fixtures. Deterministic astrology engines and validated outputs are the source of truth.
