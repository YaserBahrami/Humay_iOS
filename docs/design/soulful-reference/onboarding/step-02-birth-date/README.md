# D1 Step 02 — Birth Date

Status: **iPhone Light/Dark approved; iPad companion references ready for review**

Approved iPhone references remain `birth-date-light.svg`, `birth-date-dark.svg`, `birth-date-light-dark.svg` and `birth-date-elements.svg`.

The new iPad companion review board is `birth-date-ipad-review.svg`. It contains Portrait Light/Dark and Landscape Light/Dark compositions plus the compact-width adaptation rule.

## Product truth

Route: `Welcome → Birth Date → Tradition → Profile Reveal`.

This screen collects date only. It does not request birth time or location, and it keeps native date-input semantics. Dates remain bounded from 1900-01-01 through today unless product policy changes.

Canonical copy remains:
- `01 · Birth date`
- `When were you born?`
- `Your date is enough to start.`
- `Continue`

The existing explanatory copy remains authoritative: general reading starts from the date, while birth time/place are optional later Profile details for features that genuinely require precision.

## iPad composition

Portrait uses a bounded picker region with a quieter calendar/precision region and explanatory notes below. Landscape uses editorial/precision context on the left and the picker/CTA region on the right. Compact iPad windows collapse toward the approved iPhone hierarchy.

Do not stretch the iPhone picker. Preserve native date-picker accessibility semantics and allow reflow/scroll at large Dynamic Type sizes.

Dark enabled primary CTA uses the approved Coral → Lavender treatment with dark semantic foreground.

The sample date `March 14, 1994` is design fixture data only.
