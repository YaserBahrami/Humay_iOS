# Event Detail design specification

**Status:** APPROVED VISUAL REFERENCE

## 1. Product role

Event Detail is the deep, explanatory destination opened from:

- Current Sky event rows;
- Calendar Month selected-day agenda rows;
- Calendar Week selected-day agenda rows.

It answers what the event is, when it occurs, which system owns it, what it means in Humay's editorial language, what factual/context information is available, and what is approximate or unavailable.

It is not a scientific encyclopedia, natal chart, generic article, technical dump, share card, or provider-debug screen.

## 2. Visual direction

The package keeps the D3 family language:

- warm cream Light ground and midnight/navy Dark ground;
- tonal surfaces before heavy shadow;
- Cormorant Garamond for identity and editorial headings;
- SF/system for navigation, labels, body and controls;
- SF Mono only where timing benefits from scanability;
- restrained coral, lavender, gold, blue, and sage accents;
- one small semantic Mercury/ingress motif, no large illustration;
- no decorative star field, symbol wall, percentage, or score.

The page is an editorial sheet: focused, intimate, readable, and fact-aware.

## 3. Primary scenario

| Field | Reference fixture |
|---|---|
| Event | Mercury enters Virgo |
| Event type | Planetary ingress |
| System | Western |
| Timing | `Fri 21:00 TRT` — instant layout fixture |
| Involved | Mercury · Virgo |
| Meaning | A useful shift in focus; notice patterns, refine language, and give small details a shape you can use. |
| Availability | Development sample · not calculated |

This content exercises layout only. It makes no claim about the displayed date or actual planetary positions.

## 4. Information hierarchy

### Header

- Native Back action; destination/title follows the actual opening screen. Primary fixture is Calendar-origin and shows `Calendar`.
- Event Detail title context.
- No extra root-navigation confusion.

The iPhone reference retains the existing Sky-selected root tab bar. Event Detail is nested in Sky, not an immersive modal. iPad retains the adaptive root-navigation model.

### Event identity

- Event type label: Planetary ingress.
- Event title: Mercury enters Virgo.
- Quiet method line: Western.
- Timing row: Fri 21:00 TRT.

The identity hero is informative first. It is a tonal surface, not a Current Sky-style emotional hero.

### Editorial meaning

The meaning block is short and emotionally intelligent. It is not a text wall and does not pretend to be factual astronomy.

### Factual context

The fact surface keeps structured information separate from interpretation:

- timing;
- methodology/system;
- involved bodies or points;
- event type;
- availability/precision disclosure only when it provides meaningful user information.

The primary reference omits an availability row because the single Debug disclosure already identifies the development sample. The production projection may omit a field when unavailable. It must not fabricate a clock time, body, sign, method, or source.

Route explanation stays in this specification, not in the simulated app. Navigation itself communicates why the user arrived here.

## 5. Timing semantics

| Timing state | Visual language | Rule |
|---|---|---|
| Exact instant | `Fri 21:00 TRT` | Show clock and timezone only when supplied by a deterministic source. |
| Interval / range | `Fri 21:00 – Sat 03:00` | Keep natural start/end language; never label it “Window.” |
| Date-only | `Date only · 14 August` | Do not imply a clock time. |
| Unavailable | `Timing unavailable` or `Unavailable · timing not supplied` | Make absence intentional; never insert midnight/noon. |

The primary fixture uses instant layout content, but the stress and state boards exercise all four forms.

## 6. Methodology and event flexibility

Methodology stays visible but quiet. It is text, not a loud category-chip system. The layout must accept:

- Astronomical;
- Western;
- Vedic;
- future supported systems.

The event identity layout must remain useful for lunar phase, ingress, aspect, station, seasonal transition, and tradition-specific events. Event glyphs support recognition but never replace event name, type, timing, or system text.

## 7. Factual versus interpretive content

The page has two explicit reading layers:

1. **What it is / factual context** — event type, system, involved bodies or points, timing, precision and availability.
2. **What it may mean in Humay** — concise editorial language, clearly labeled as meaning.

No speculative prose is presented as scientific fact. No over-legalized warning dominates the page. Unknown values remain visible as unavailable or reference-only.

## 8. iPhone composition

Canvas: 430 × 932 pt portrait reference.

Order:

1. origin-aware native Back header;
2. quiet Debug disclosure;
3. identity hero with title, type, method and timing;
4. What this means;
5. Factual context;
6. existing Sky-selected bottom navigation shell.

Basic explanation and core facts appear in the first useful viewport. Cards remain compact; no giant stacked panels are required to understand the event. In production, Dynamic Type expands rows and allows scrolling rather than clipping facts.

## 9. iPad composition

Canvas: 1024 × 1366 pt portrait reference.

The page uses two bounded regions:

- left: identity and meaning;
- right: factual context.

The columns are intentionally sized for reading. Premium breathing room is allowed; no filler card is added only to occupy space. Landscape and split-view behavior are width-driven and documented in `adaptive-notes.md`.

## 10. Glyph and illustration decision

The primary hero uses a small Mercury/ingress motif: orbital arcs, a restrained Mercury glyph, and one tiny accent. It is reference-only art inside this package. It is not a production asset and is hidden from VoiceOver.

Stress references use moon, aspect, and neutral tradition-specific markers only to prove semantic flexibility. No new production asset is created. Color never carries event meaning alone.

## 11. State board

`states.svg` / `states.png` cover:

- loading;
- unavailable;
- offline with cached content;
- offline without cached content;
- failed/error;
- event not found / no longer available.

Loading keeps shell hierarchy without fake facts. Cached content keeps saved-time disclosure. Unavailable, offline-empty, failed, and not-found use distinct copy. No Retry, provider debug data, or unsupported recovery action is presented; Back returns to the opening screen.

## 12. Stress board

`stress.svg` / `stress.png` cover, without extra device mocks:

- long event title;
- aspect involving two bodies;
- tradition-specific event;
- lunar phase;
- date-only timing;
- interval/range timing;
- unavailable timing;
- longer interpretation text;
- sparse factual details;
- dense factual details;
- methodology label pressure;
- large Dynamic Type pressure and one-column collapse concept.

## 13. Accessibility intent

- 44 pt minimum targets for Back, rows, navigation, and any future native controls;
- grouped fact rows with label/value reading order;
- event glyphs hidden or labeled through their parent event identity, never exposed as unexplained symbols;
- VoiceOver order follows visual reading order on phone and left-region-before-right-region on iPad;
- Dynamic Type expands title, meaning, and fact rows; it does not shrink critical text;
- Differentiate Without Color uses labels, borders, text, and layout state;
- Increase Contrast strengthens hairlines, selected states, and secondary text;
- keyboard/pointer focus applies to complete rows and native Back on iPad;
- safe areas reserve the status and home-indicator regions;
- Reduce Motion keeps the final static composition and removes orbit/sparkle motion.

No numerical HIG score is assigned to static references.

## 14. Deferred decisions

1. Production source for editorial meaning.
2. Production event-detail projection and provider provenance.
3. Exact recovery actions after `SKY-002` exists.
4. Whether any reference-only glyph receives a production asset export.

Navigation-origin behavior and root-tab visibility are visual decisions recorded here; these references do not resolve Domain, Data, Presentation, access, provider, cache, or persistence contracts.
