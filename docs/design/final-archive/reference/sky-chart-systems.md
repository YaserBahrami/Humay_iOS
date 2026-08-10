# Sky, Chart & Astrology Systems

**Purpose:** The Sky tab (current sky + calendar), the Chart tab (Western/Vedic/Chinese, Compare Systems), and the shared unknown-birth-time chart behavior.

**Current authority:** Pass 3 for Chart/Sky/Vedic/Chinese/Compare Systems visuals; Pass 4 for the astrology Calendar (month/week views); Pass 6.1 governs unknown-birth-time and methodology-vs-implementation classification.

**Source artifacts:** `Product Design - Pass 3.dc.html`, `Product Design - Pass 4.dc.html`.

**Final decisions:**
- Compare Systems describes differences between traditions; it never ranks or scores one against another (Pass 6 "native system terminology" ruling).
- Without a birth time, the chart degrades gracefully to sign-based content; house-based detail stays off until a time is added — behavior frozen in Pass 6.1.
- A decision that changes a *calculated* astrological fact is methodology (engineering-owned); a decision about how to *display* an already-calculated fact is implementation choice (design-owned) — see Pass 6.1 §"Methodology vs. implementation choice." BaZi Luck Cycle direction is flagged methodology-pending, not silently decided (Pass 6 §07).

**Canonical screens:**
| Screen | File |
|---|---|
| Chart — overview | `previews/chart/chart-01-overview.png` |
| Chart — Western | `previews/chart/chart-02-western.png` |
| Chart — Vedic | `previews/chart/chart-03-vedic.png` |
| Chart — Chinese / BaZi | `previews/chart/chart-04-chinese-bazi.png` |
| Chart — Compare Systems | `previews/chart/chart-05-compare-systems.png` |
| Chart — unknown birth time | `previews/chart/chart-06-unknown-time.png` |
| Sky — current | `previews/sky/sky-01-current.png` |
| Sky — Calendar, month | `previews/sky/sky-02-calendar-month.png` |
| Sky — Calendar, week | `previews/sky/sky-03-calendar-week.png` |
| Sky — event detail | `previews/sky/sky-04-event-detail.png` |

Overview: `previews/overviews/astrology-systems-overview.png`, `previews/overviews/core-product-overview.png`

**Supersession notes:** Two rows of Pass 6 §13 are superseded by Pass 6.1's methodology/implementation split — treat Pass 6.1 as controlling wherever the two disagree.

> Prototype astrology values shown in design artifacts are illustrative only and must not be used as engineering fixtures. Deterministic astrology engines and validated outputs are the source of truth.
