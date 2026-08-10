# Methodology Track

This track runs in parallel with engineering. It records astrology decisions that change calculated output and therefore must not be guessed by implementation.

| ID | Topic | Status | Blocks |
|---|---|---|---|
| METHOD-001 | Western house-system strategy | TODO | production house-based Western behavior beyond chosen initial default |
| METHOD-002 | Western composite-chart technique | TODO | Western composite readings |
| METHOD-003 | Vedic ayanamsa sign-off (Lahiri provisional default) | TODO | canonical production Vedic output |
| METHOD-004 | Vedic non-romantic compatibility dimensions | TODO | Vedic family/friend/coworker compatibility |
| METHOD-005 | Chinese calendar conventions | TODO | Chinese/BaZi production astrology |
| METHOD-006 | BaZi Four Pillars conventions | TODO | Chinese/BaZi production astrology |
| METHOD-007 | BaZi local/solar-time rule sign-off | TODO | canonical production BaZi output |
| METHOD-008 | BaZi Luck Cycle / Da Yun methodology and required inputs | TODO | advanced Luck Cycles |
| METHOD-009 | Cross-system timing/event mapping | TODO | full Compare Systems timing parity |

## Rules

- Provisional defaults may be used for prototypes/dev builds only when clearly marked.
- A methodology item is not closed by choosing whatever an API happens to return.
- Sign-off should document the convention, source/reasoning, edge cases and validation fixtures.
- When a methodology decision is finalized, update the relevant architecture document and affected phase task before enabling the production feature.

## Initial shipping guidance

The iOS foundation, local profile, Western-first engine foundation, core Chart, Today and Sky can proceed while this track is open, provided production behavior does not depend on unresolved items.
