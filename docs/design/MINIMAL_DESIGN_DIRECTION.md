# Minimal Humay Design Direction

**Status: current visual and layout authority.** Recorded 2026-08-11, expanded 2026-08-11 during the Phase 01M reconciliation pass.

This document is the reference [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md) §03A points at. It states the approved minimal direction in enough detail to be checked against an implementation, screen by screen.

Scope note: this governs **visuals and layout only**. Product concepts, feature behaviour, terminology and copy remain governed by `claude-reference/Humay Product Prototype - Consolidated.dc.html` and the earlier passes. Where the prototype conflicts visually with this document, this document wins.

---

## 01 — The intent in one line

Humay should feel like a premium, calm, editorial iOS application — not like a horoscope app.

Everything below follows from that. Where a rule and the intent disagree, the intent is the tiebreaker.

## 02 — The visual system

### Surfaces — All Paper

- Every screen renders on Paper: a warm off-white ground.
- The prototype's per-screen ink/paper split is superseded. No screen has a dark ground.
- Ink and Paper are semantic surfaces, not a light/dark theme pair. A dark appearance is a separate future decision and must never be implemented by inverting these tokens.
- Precision and tier are differentiated by **badge, hairline and typographic weight**, never by a dark ground.

### Colour

- Warm off-white background.
- Near-black typography, weighted through the locked six-stop ink-opacity ramp.
- A restrained warm-gold accent, used for marks, rules, glyphs and links — never as a large fill.
- Cinnabar is the Roast expression only. It is never chrome and never a status colour.
- No colour literal outside the palette file.

### Typography

| Family | Used for |
|---|---|
| **Cormorant Garamond** (300–400 only) | Wordmark, screen-defining editorial headlines, major titles |
| **SF Pro** (system) | Body copy, navigation, buttons, forms, settings, all general UI |
| **SF Mono** (system) | Degrees, coordinates, dates, technical chart data, kickers. Never prose |

Lora, IBM Plex Sans and IBM Plex Mono are removed. Views name a semantic **type role**, never a face and a size.

### Space

- Generous whitespace is the primary compositional device.
- One horizontal gutter for the whole application. A screen that sets its own inset is a defect.
- Vertical rhythm comes from the semantic spacing scale, not from ad-hoc numbers.
- Long-form reading gets more air than dense reference lists; both come from the same scale.

### Surfaces, borders and shape

- **Very few cards.** A card must earn itself; the default is content on the ground.
- **Subtle hairline separators** do the work borders and boxes would do elsewhere. One device pixel, not one point.
- **Minimal shadows** — in practice, none.
- **Minimal corner radius.** Square by default. The only sanctioned exceptions are widget surfaces and small inline affordances where a hard corner reads as an error.
- One emphasis border weight exists, reserved for the single deliberate case.

### Controls

- Exactly one primary action per screen at most.
- Three button roles: primary (ink fill), outline (hairline, no fill), quiet (text only). Nothing else.
- Segmented selection is drawn as underlined labels, not a filled capsule.
- Chevrons, info triggers and other affordances come from one shared component each — never re-drawn per screen.

### Navigation and chrome

- Native iOS behaviour throughout: system navigation bar, system tab bar, system large titles, system sheets and covers.
- Navigation titles stay in the system face. Cormorant carries the editorial headline **below** the bar, not the bar itself.
- Navigation bar: opaque Paper, no shadow. Tab bar: opaque Paper with a single hairline top rule.
- Tab roots use the large title and collapse on scroll. Pushed screens use the inline title.
- IA is Today / Circle / Sky / Chart / Ask. Calendar nests under Sky. Profile & Settings is a cover from the header, never a sixth tab.

### Astrology decoration

- Glyphs are used sparingly, at the accent colour, and always carry a spoken name.
- No mystical-purple aesthetic. No gradients. No glows, starfields, particles or other cosmic effects.
- Charts and diagrams are line drawings in the hairline vocabulary, and each has a structured accessible alternative.

### Motion

- Four verbs — rise, draw, strike, turn — plus one signature reveal.
- Nothing loops under any setting. Nothing exists to create urgency.
- Reduce Motion is an honest alternative path, not a disabled animation.

## 03 — What counts as drift

A screen has drifted back toward the older prototype when it shows any of the following.

| Drift | The minimal move |
|---|---|
| A card or filled container around ordinary content | Content on the ground, separated by a rule |
| A border where a rule would do | Hairline |
| A badge that carries no information | Delete it, or make it a plain kicker |
| A gutter or top inset that differs from its neighbours | The shared scaffold |
| A hand-rolled screen scaffold | The shared scaffold |
| A face or point size set inline | A semantic type role |
| Copy that explains what is already visible | Delete it |
| A glyph used as decoration | Delete it |
| A one-off button treatment | One of the three button roles |
| A re-drawn chevron or icon at a new point size | The shared component |
| A rounded container | Square, or a rule |
| Two headers on the same screen doing the same job | One |

## 04 — Screen reconciliation checklist

Every screen below was reviewed against §02 and §03 in the Phase 01M reconciliation pass.

- Onboarding — welcome, birth date, tradition, reveal
- Today — general
- Today — precise
- Circle — list and drawing
- Add person
- Person detail
- Compatibility — general
- Compatibility — precise
- Quick check
- Sky — transits
- Sky — calendar
- Sky — event detail
- Chart — sign profile
- Chart — Western
- Chart — Vedic
- Chart — Chinese
- Placement detail
- Glossary sheet
- Ask — opening
- Ask — conversation
- Profile & settings, and every settings page

## 05 — Accessibility is part of the visual contract

The direction is not met by a screen that only looks right at the default text size.

- Every screen must be usable at the largest accessibility Dynamic Type category.
- Prefer graceful reflow — a horizontal label/value pair becomes a stacked pair — over shrinking important text.
- Display and mono roles cap their scaling and re-wrap; body text is uncapped.
- Every interactive target is at least 44pt, including ones whose glyph is smaller.
- Every astrological glyph carries a spoken name.
- Charts and drawings are replaced for assistive technology by a navigable structured alternative, not described as pictures.
- VoiceOver order follows visual reading order, with the insight before its basis.

## 06 — Device scope

**V1 targets iPhone in portrait.** iPad is a planned dedicated design and implementation phase, not a stretched phone layout.

The iPhone implementation must not make that harder: no hard-coded device dimensions, semantic spacing tokens throughout, reusable layout components, adaptable navigation architecture, chart visualisations responsive to their container, and content separated from presentation. No speculative iPad layouts.

Verified sizes for this phase: a smaller supported iPhone, a normal-size iPhone, and a Pro Max-size iPhone.

## 07 — Relationship to the other design artifacts

1. [`DESIGN_AUTHORITY.md`](DESIGN_AUTHORITY.md) — supersession rules. Start there.
2. **This document** — visual and layout authority.
3. `claude-reference/` — product concepts, feature behaviour, terminology, copy.
4. `final-archive/` — derived browsing reference. Never an authority layer, and its visual treatment is superseded here.
5. `review/` — implementation screenshots from a reconciliation pass. A record of what was built, not a specification.
