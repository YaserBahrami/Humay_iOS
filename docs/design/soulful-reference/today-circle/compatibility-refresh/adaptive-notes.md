# Compatibility Refresh Adaptive and Accessibility Notes

**Status:** REVIEW CANDIDATE — NOT APPROVED

## Width behavior

| Context | Selection | Result hero |
| --- | --- | --- |
| Compact iPhone / narrow split view | One-column pair composer, one-column person rows, bottom safe-area CTA | One full-width relationship field; title may wrap to two lines |
| Intermediate width | Bounded single column until two regions can remain generous | Bounded single hero; no proportional enlargement |
| Regular iPad | Two regions: pair context left, one-column people list right | One wide field: pair identity left, score/result right |
| iPad landscape | Preserve bounded two-region composition; allow list to gain width first | Preserve hero measure and use remaining width for lower context, not giant medallions |

Implementation should use width-driven composition, not device checks. The regular composition should collapse before the saved-people region falls below roughly 420 pt or the pair-context region below roughly 360 pt.

## Dynamic Type pressure

- Person rows use `minHeight`, never fixed height. Name and sign columns receive horizontal width before wrapping.
- Names use whole-word wrapping and may take two lines. No fixed tiny grid column is permitted.
- At accessibility sizes, medallions can reduce visual priority while retaining 44 pt targets; rows grow vertically.
- Pair composer changes from side-by-side slots to a leading vertical sequence when two readable name regions no longer fit.
- Relationship title can wrap to two centered lines. The score moves below the connector if the horizontal pair axis no longer fits.
- Bottom CTA remains in the safe area and content receives matching bottom inset so the last row is never hidden.
- `Alexandria`, `Christopher`, `Sagittarius`, and `Capricorn` are the reference pressure strings. Longer localized strings require the same reflow behavior.

## Stress-test matrix

| Case | Expected behavior |
| --- | --- |
| 0 selected | Two explicit empty slots; incomplete connector; disabled `Select two people` CTA |
| 1 selected | First slot filled; second says `Choose one more person`; CTA remains disabled |
| 2 selected | Both slots filled; active connector/checkmarks; `See Compatibility` CTA enabled |
| More than 4 saved people | Native vertical scrolling; count remains visible; no card compression |
| `Alexandria` / `Christopher` | Full words in rows and pair title; two-line wrap only when necessary |
| `Gemini` / `Sagittarius` / `Capricorn` | Sign remains secondary and readable; no character-by-character wrapping |
| Compact width | One-column rows; no adaptive two-card grid |
| Regular iPad | Two bounded regions; no stretched phone stack |
| Dark Mode | Tonal surfaces, bright accents, independent contrast treatment |
| Accessibility Dynamic Type | Growing rows and vertical reflow; controls stay reachable |

## VoiceOver model

Suggested reading order:

1. `Compatibility`, heading.
2. `Choose your connection`, heading, then short instruction.
3. Pair composer as one summary element: `Selected pair, Alexandria, Sagittarius, and Christopher, Capricorn. Two people selected.`
4. `Saved people`, heading and count.
5. Each full-row button: `Alexandria, Sagittarius. Selected. Double-tap to remove from comparison.` or `Yaser, Leo. Not selected. Double-tap to add to comparison.`
6. CTA: `See Compatibility` with button trait.

For the result hero, combine visual identity into a concise sequence: `Alexandria and Christopher. Sagittarius Sun and Capricorn Sun. Free Sun-sign pair, not natal synastry. Compatibility score, 82 percent. Magnetic Match. [summary].`

The orbit, heart bridge, ambient circles, sparkles, and endpoint nodes are decorative and hidden from VoiceOver. They must not create separate stops or noisy SVG descriptions in production.

## Differentiate Without Color

- Selected rows use a checkmark shape, `Selected` accessibility value, border-weight change, and optional text label in addition to accent color.
- Empty/filled pair slots differ by icon, line style, and copy, not only tint.
- Enabled/disabled CTA states use label and control semantics in addition to opacity/color.
- Free/Precise basis is written text, not an accent-color code.

## Targets, keyboard, and pointer

- Every person row is one full-width button with a minimum 44 pt target; the reference uses larger rows.
- CTA is at least 56 pt high.
- On iPad, Tab moves through navigation, person rows, and CTA in visual reading order. Space/Return activates the focused row or CTA.
- Pointer hover may add a subtle lift/tint but cannot be the only selected-state cue.
- Focus ring follows the rounded row/button shape and remains visible in Light, Dark, selected, and unselected states.
- Standard back, scrolling, and tab/sidebar behavior remains native.

## Reduce Motion

If implementation adds orbit/connector motion, it is a brief state transition only. With Reduce Motion enabled:

- no orbit rotation, parallax, looping particles, or pulsing heart;
- selection changes use an instant state change or short opacity crossfade;
- functional pressed/selection feedback remains brief and non-spatial.

## Contrast spot check

Reference foreground/background pairs were checked in both appearances. Representative results:

| Pair | WCAG 2 ratio | APCA |
| --- | ---: | ---: |
| Light primary `#151B28` on ground `#FBF7F1` | 16.14:1 | Lc 99.6 |
| Light supporting `#625F62` on ground `#FBF7F1` | 5.90:1 | Lc 76.9 |
| Dark primary `#F5F0EA` on ground `#101725` | 15.82:1 | Lc -97.4 |
| Dark supporting `#D6D0CC` on surface `#171F30` | 10.79:1 | Lc -76.7 |
| Dark CTA text `#101725` on coral endpoint `#FF9998` | 8.76:1 | Lc 63.0 |
| Dark CTA text `#101725` on lavender endpoint `#D89AE9` | 8.30:1 | Lc 60.2 |

The generator uses reference-only supporting/CTA tones within the established Soulful Celestial palette. A future SwiftUI implementation must map them to semantic Light/Dark assets and recheck rendered pairs with Increase Contrast enabled.

## Reference-level HIG diagnostic

**9/10.** The proposal covers safe areas, 44 pt targets, native scrolling/navigation, Light/Dark, Dynamic Type reflow, VoiceOver semantics, redundant selected-state cues, and iPad keyboard/pointer behavior. The remaining point requires an approved SwiftUI implementation followed by real VoiceOver, Accessibility Inspector, largest Dynamic Type, narrow split-view, keyboard, and pointer verification.
