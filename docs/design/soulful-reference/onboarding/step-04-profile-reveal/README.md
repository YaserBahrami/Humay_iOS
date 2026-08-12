# D1 Step 04 — Profile Reveal

Status: **cross-device Light/Dark references ready for review**

Review board: `profile-reveal-cross-device-review.svg`.

## Product truth

Route: `Welcome → Birth Date → Tradition → Profile Reveal → main app`.

The reveal may safely show the birth date the user entered, the leading tradition selected, and the fact that the current profile is date-only / not precise. It must not invent rising sign, houses, exact aspects, natal positions, Vedic timing, BaZi pillars or any other time/place/provider-dependent fact.

Sample fixture shown in the board is presentation-only: `March 14, 1994`, `Western`.

Canonical copy:
- `03 · Your profile`
- `Your starting profile is ready`
- `A simple beginning — no fake precision.`
- `Ready to meet your sky?`
- `Precision stays optional`
- `Add birth time and place later only when a feature genuinely needs them.`
- `Enter Humay`

## Layout

iPhone uses one emotional medallion hero followed by factual summary surfaces. iPad portrait uses a bounded reveal surface with hero left and factual summary right. iPad landscape balances the emotional region and profile summary. Compact iPad stacks hero before facts.

User-entered values remain textual. The medallion/orbits are decorative. Dynamic Type can stack regions, and the CTA remains at least 44 pt.
