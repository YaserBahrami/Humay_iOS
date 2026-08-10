# Onboarding

**Purpose:** The 13-stage, one-question-per-screen onboarding flow ending in the Big Three reveal.

**Current authority:** Pass 4/Pass 2 visual reference, unmodified by Pass 6/6.1. Unknown-birth-time behavior inside onboarding follows the Pass 6.1 correction (see `engineering-handoff.md`, §"Unknown birth time, corrected").

**Source artifact:** `Product Design - Pass 2.dc.html` (interactive "Onboarding, all 13 stages" frame).

**Final decisions:**
- Welcome and value proposition are dark ("Ink"); every question screen is light ("Paper"); calculation and reveal return to Ink — this crossing is the app's reused arrival gesture (also seen entering Today).
- A missing birth time is never treated as invalid; the flow explains exactly what each tradition loses without one and offers "rough part of day" or "continue without a time."
- System selection sets first-read tradition only — all three remain available afterward.

**Canonical screens:**
| Screen | File |
|---|---|
| 01 Welcome | `previews/onboarding/onboarding-01-welcome.png` |
| 02 Value proposition | `previews/onboarding/onboarding-02-value-proposition.png` |
| 03 Birth date | `previews/onboarding/onboarding-03-birth-date.png` |
| 04 Birth time | `previews/onboarding/onboarding-04-birth-time.png` |
| 05 Unknown-time path | `previews/onboarding/onboarding-05-unknown-time-path.png` |
| 06 Birth location | `previews/onboarding/onboarding-06-birth-location.png` |
| 07 System selection | `previews/onboarding/onboarding-07-system-selection.png` |
| 08 Calculation | `previews/onboarding/onboarding-08-calculation.png` |
| 09 Big Three reveal | `previews/onboarding/onboarding-09-big-three-reveal.png` |

Overview: `previews/overviews/onboarding-overview.png`

**Supersession notes:** None specific to onboarding beyond the general unknown-birth-time correction in Pass 6.1.

> Prototype astrology values shown in design artifacts are illustrative only and must not be used as engineering fixtures. Deterministic astrology engines and validated outputs are the source of truth.
