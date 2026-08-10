# Sky, Chart & Astrology Systems

**Purpose:** The Sky tab (current sky + Calendar), the Chart tab (Western/Vedic/Chinese-BaZi, Compare Systems), and the shared uncertainty/methodology rules that constrain those surfaces.

**Current authority:** Pass 3 for Chart/Sky/native-system/Compare visuals; Pass 4 for Calendar; Pass 6.1 for unknown-birth-time behavior and methodology classification.

**Source artifacts:** `Product Design - Pass 3.dc.html`, `Product Design - Pass 4.dc.html`, Pass 6 and Pass 6.1.

**Final decisions:**
- Compare Systems describes **shared themes, different emphasis, and different perspective**. It never ranks systems or treats agreement as scientific confidence.
- Unknown birth time degrades **individual calculated facts** according to the actual uncertainty window; it does not reduce the whole product to a generic sign-only mode.
  - Western Rising/houses require sufficient time; Moon sign/degree and Moon-dependent aspects may also become uncertain.
  - Vedic Lagna/Bhavas depend on time; Nakshatra and Vimshottari reliability follow the actual Moon uncertainty window.
  - BaZi Hour Pillar requires birth time; Year/Month/Day availability follows the validated calendar/day-boundary convention and uncertainty window.
- Any convention that changes calculated astrology is a **methodology/domain decision requiring validation/sign-off**, not ordinary UI engineering discretion.
- Presentation and software-implementation choices may vary only when they do **not** change the calculated astrological facts or approved product behavior.
- Lahiri ayanamsa and BaZi local/solar-time handling are provisional methodology defaults for development only until sign-off.
- Chinese/BaZi production astrology, advanced Luck Cycles, Western composite readings, Vedic non-romantic compatibility and full Compare Systems timing parity retain the feature-specific methodology blockers recorded in Pass 6.1.

**Canonical visual references:**
- [Chart — overview](../previews/chart/chart-01-overview.png)
- [Chart — Western](../previews/chart/chart-02-western.png)
- [Chart — Vedic](../previews/chart/chart-03-vedic.png)
- [Chart — Chinese / BaZi](../previews/chart/chart-04-chinese-bazi.png)
- [Chart — Compare Systems](../previews/chart/chart-05-compare-systems.png)
- [Chart — unknown birth time](../previews/chart/chart-06-unknown-time.png)
- [Sky — current](../previews/sky/sky-01-current.png)
- [Calendar — month](../previews/sky/sky-02-calendar-month.png)
- [Calendar — week](../previews/sky/sky-03-calendar-week.png)
- [Sky — event detail](../previews/sky/sky-04-event-detail.png)
- [Astrology-systems overview](../previews/overviews/astrology-systems-overview.png)
- [Core-product overview](../previews/overviews/core-product-overview.png)

**Methodology caveat:** The Chinese/BaZi and other methodology-blocked PNGs are **visual design references only**. Their sample calculated values and methodology must not be treated as validated production behavior.

> Prototype astrology values shown in design artifacts are illustrative only and must not be used as engineering fixtures. Deterministic astrology engines and validated outputs are the source of truth.
