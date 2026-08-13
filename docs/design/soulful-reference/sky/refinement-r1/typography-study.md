# Typography Study — Newsreader vs Cormorant Garamond

**Status:** REVIEW CANDIDATE — NOT APPROVED  
**Decision scope:** global editorial typography, not Sky-only

## Recommendation

Adopt **Newsreader** as the primary candidate for editorial/display UI roles. Keep **Cormorant Garamond** as the Humay wordmark candidate. Keep **SF Pro/system** for body, buttons, navigation, dates, event titles, and metadata. Use SF Pro monospaced digits for changing/aligned dates and times. Reserve SF Mono for chart coordinates and degree-heavy technical surfaces.

Do not change `HumayTypography.swift` until product-owner review approves a global system.

## Why Newsreader leads

- More stable at 26–36 pt, allowing compact editorial hierarchy without losing personality.
- Larger practical x-height and sturdier strokes improve Light/Dark readability.
- Optical-size axis supports display refinement while maintaining text clarity.
- Numerals and punctuation sit more naturally beside SF Pro metadata.
- Less vertical drama than Cormorant, helping Sky and Calendar density.

## Where Cormorant remains stronger

- The Humay wordmark and rare large brand moments.
- High-contrast elegance at generous sizes.
- Existing brand recognition and continuity.

Its weaker fit is compact product UI: narrow forms and delicate hairlines need more size and space, which recreates the tall/serious problem this refinement addresses.

## Pressure test

| Context | Newsreader candidate | Cormorant candidate | Recommendation |
|---|---|---|---|
| Sky hero | 29 pt, 1.08 line height | 31 pt, 1.08 line height | Newsreader; stronger at shorter height. |
| Calendar month title | 27 pt | 30 pt | Newsreader; better density and numeral clarity. |
| Today editorial heading | 32 pt | 35 pt | Newsreader; warm but more readable beside body copy. |
| Compatibility score/title | 34–40 pt | 40–46 pt | Newsreader for title/score UI; Cormorant may remain for exceptional score emphasis after review. |

## Candidate global role map

| Semantic role | Family | Notes |
|---|---|---|
| Brand wordmark | Cormorant Garamond | Isolated treatment; verify real face and avoid synthetic weights. |
| Editorial large title | Newsreader | Variable optical sizing; semibold/medium candidate. |
| Editorial section title | Newsreader | Regular/medium; avoid excessive size jumps. |
| Body and controls | SF Pro/system | Native semantic styles and Dynamic Type. |
| Event title | SF Pro/system | Semibold; prioritize scanning. |
| Dates/times | SF Pro/system | `monospacedDigit()` only where alignment/stability helps. |
| Degrees/coordinates | SF Mono | Technical Chart use only. |

## Dynamic Type and OpenType notes

- Use semantic scaled roles rather than fixed point sizes.
- Prefer the variable Newsreader file when licensing and application footprint are approved.
- Use the high-level optical-size and weight APIs available on the platform; do not force arbitrary variation-axis values without testing.
- Load only intended weights/styles; avoid synthetic bold/italic where emphasis matters.
- Keep heading line height near 1.1 and body near the system semantic default.
- Use tabular/monospaced digits for changing or aligned values, not a monospace font for ordinary prose.

## Font source in this package

The generator embeds the official Google Fonts Newsreader variable font solely for deterministic design-reference rendering. Its OFL license is stored beside it under `reference-fonts/OFL-Newsreader.txt`. This does not add the font to the app bundle or approve its production use.

## Approval questions

1. Approve Newsreader for editorial UI while retaining Cormorant for the wordmark?
2. Keep Cormorant for rare compatibility score moments, or move those to Newsreader too?
3. If approved, which Newsreader weights and optical-size behavior should ship after runtime size/legibility testing?

