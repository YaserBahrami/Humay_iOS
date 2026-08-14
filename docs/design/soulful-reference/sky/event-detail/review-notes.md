# Event Detail reference-specific review notes

**Status:** APPROVED VISUAL REFERENCE

## Chosen direction — Celestial editorial sheet

Event Detail is a focused explanatory destination. It keeps Current Sky's emotional restraint and Calendar's factual rhythm, then adds a short editorial reading without turning into an article page.

The primary fixture is **Mercury enters Virgo**. The hero uses a small Mercury/ingress motif because the event class justifies it. The motif is subordinate to title, timing, and method.

## Reference hierarchy

### iPhone

Origin-aware native Back → Debug disclosure → identity hero → What this means → Factual context → existing Sky tab shell.

### iPad

The left bounded region owns identity and meaning. The right bounded region owns factual context. This is a true two-region composition, not a stretched phone. Breathing room remains intentional; no explanatory filler cards are added.

The primary visual uses Calendar as origin. Current Sky-origin and Calendar-origin behavior remain native-stack decisions, with Month/Week selection preserved when returning to Calendar. iPhone keeps Sky selected in the root tab bar; iPad keeps adaptive root navigation.

## Event identity decision

The hero establishes identity with:

- event type label;
- flexible editorial title;
- quiet methodology/system line;
- timing row;
- small semantic motif.

It does not use a giant illustration, score, percentage, or Current Sky emotional headline. Information comes before decoration.

## Timing decisions

- Primary reference uses `Fri 21:00 TRT` as an instant layout fixture.
- Stress board includes `Fri 21:00 – Sat 03:00` as a natural range.
- Stress board includes `Date only · 27 November` without a fabricated clock.
- Stress board and factual guidance include `Timing unavailable`.
- No “Window” label appears.

## Methodology decision

Western is visible in the primary identity and factual context, but remains quiet text. The stress board exercises Astronomical, Western, and Vedic pressure. Methodology is never encoded by color alone and never becomes a loud chip field.

## Factual versus interpretive decision

“What this means” has its own labeled block. “Factual context” has grouped label/value rows for timing, system, involved bodies/points, and event type. The single Debug badge owns development disclosure; repeated availability/meta rows are removed from the primary product surface.

## State board decisions

- Loading shows shell skeleton and a calm progress message.
- Unavailable says the event needs a connected source.
- Offline with cache shows saved event content and saved-time disclosure.
- Offline without cache says no saved detail is available.
- Failed says event facts could not load.
- Event not found is distinct from source failure and leaves Back to the opening screen available.
- No Retry button, provider-debug panel, or invented recovery action is shown.

## Stress board coverage

- long ingress title and title wrapping;
- lunar phase identity;
- two-body aspect identity;
- tradition-specific event identity;
- date-only, range, and unavailable timing;
- longer interpretation;
- sparse and dense factual context;
- long methodology labels;
- large Dynamic Type pressure and one-column collapse.

No extra device mocks are created for stress cases.

## Light and Dark

### Light

Warm cream ground, off-white factual surface, dark editorial hero, restrained coral/lavender meaning surface, and safe tonal accent text.

### Dark

Midnight ground, navy/plum hero and fact surfaces, warm ivory primary text, brighter coral/lavender/gold/blue accents, and tonal separation instead of inversion or glow.

## Glyph and illustration decision

Use one small reference-only Mercury/ingress motif in the primary hero. It is not a production asset, does not encode scientific position, and is hidden from VoiceOver. Moon, aspect, and neutral tradition markers appear only in the stress board to prove event-class flexibility.

No symbol wall, star field, large illustration, or new `Assets.xcassets` item is introduced.

## Accessibility findings

- [x] Origin-aware Back is visible and has a full target area.
- [x] Factual rows are grouped and carry label/value/detail reading order.
- [x] Timing semantics remain textual and do not rely on accent color.
- [x] Light and Dark use separate tonal hierarchies.
- [x] The hero motif is decorative and should be hidden from VoiceOver.
- [x] Dynamic Type rules preserve title, meaning, timing, and methodology before decorative art.
- [x] iPad uses bounded regions and collapses under width or accessibility pressure.
- [x] Reduce Motion leaves a complete static composition.
- [x] Runtime implementation evidence is captured under [`docs/design/implementation-evidence/d3-sky-calendar/event-detail/`](../../../implementation-evidence/d3-sky-calendar/event-detail/README.md); future regressions must preserve contrast, focus-ring, pointer, keyboard and Dynamic Type behavior.

No numerical HIG score is assigned.

## Deferred decisions

1. Production integration of origin-aware navigation and root-tab behavior.
2. Provider provenance and editorial meaning source.
3. Exact recovery controls after the data pipeline exists.
4. Production promotion of any reference-only glyph or motif.
5. Final content contract for unavailable factual fields.

The product owner approved the four primary references and the complete Celestial editorial sheet package on 2026-08-13. Event Detail SwiftUI is now implemented under `SKY-005`; this package remains visual authority while `SKY-002` and `SKY-006` stay pending.
