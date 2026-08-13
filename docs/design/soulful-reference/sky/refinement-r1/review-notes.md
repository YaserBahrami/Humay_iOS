# R1 Review Notes

**Status:** REVIEW CANDIDATE — NOT APPROVED

## Problems identified from real simulator evidence

### Current Sky

- The iPhone hero occupies roughly one third of the useful viewport before current events begin.
- Empty art area and a generic orbit motif weaken the focal point.
- The Debug disclosure reads like a primary product status pill.
- `Happening now` and individual rows use oversized editorial/card rhythm for factual scanning.
- SF Mono on ordinary dates/times makes the feed feel developer-facing.
- The floating tab bar visibly overlays lower event content.

### Month

- Header, Debug disclosure, segmented control, month title, and range arrows form too many separate vertical bands.
- Six rows reserve large permanent empty slots for markers.
- Today’s outline plus top bar plus label uses more height than its semantic importance needs.
- Outside-month month labels create extra vertical bands.
- On iPhone the selected agenda begins below the tab bar/viewport.

### Week

- Today and selected use tall capsules that dominate the rail.
- `Week begins Monday` occupies a major line despite being secondary metadata.
- Range controls and title are spatially disconnected.
- The selected agenda starts too late on iPhone.
- `Across the week` is valuable on iPad but adds avoidable scroll weight on iPhone.

## Candidate decisions

- Replace Lunar Meridian with a shorter **Lunar Compass** hero and standalone Light/Dark vector asset.
- Reduce Debug disclosure to a quiet inline development note.
- Use one compact event surface with hairline-separated rows, inline methodology, and monospaced SF Pro digits.
- Retain six Month rows using 44 pt interaction bands and sparse in-cell markers.
- Merge range title, Monday-first metadata, and previous/next actions into one compact hierarchy.
- Replace Week capsules with small discs inside a shared rail.
- Keep `Across the week` on iPad; replace it with optional compact later-week signals on iPhone.
- Reserve explicit bottom clearance above the floating tab bar.
- Recommend Newsreader for editorial UI, while keeping Cormorant eligible for the Humay wordmark.

## Newsreader versus Cormorant

Newsreader is denser and more legible at 26–36 pt, has a larger practical x-height, and feels editorial without requiring oversized lines. Cormorant remains more distinctive and elegant at wordmark scale but appears fragile in compact UI headings and encourages larger vertical rhythm. See `typography-comparison.svg` and [`typography-study.md`](typography-study.md).

## Preserved behavior and semantics

- Today / Circle / Sky / Chart / Ask.
- Calendar remains nested under Sky.
- Monday-first civil calendar contract.
- Today, selected, coincident Today + selected, event-bearing, and outside-month states.
- Exact, interval, date-only, and unavailable timing.
- Astronomical, Western, and Vedic methodology labels.
- iPhone/iPad, Light/Dark, Dynamic Type, VoiceOver, 44 pt targets.

## Approval boundary

- This package does not update `DESIGN_AUTHORITY.md`.
- It does not supersede the approved D3.1/D3.2 references.
- It does not modify shipping SwiftUI, `HumayTypography.swift`, `Info.plist`, or production `Assets.xcassets`.
- It does not implement `SKY-002`, `SKY-005`, or any Domain/Data behavior.
- Illustration files are review candidates only and must not be promoted into the asset catalog without explicit product-owner approval.

## Implementation-time verification still required after approval

- Runtime Dynamic Type through accessibility sizes.
- VoiceOver rotor order and combined labels.
- Increase Contrast and Differentiate Without Color.
- Pointer/keyboard focus on iPad.
- Actual tab-shell inset ownership to avoid missing or doubled bottom padding.
- Asset optimization and final PDF/SVG-to-asset-catalog export choice.

