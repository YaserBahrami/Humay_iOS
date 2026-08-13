# Compatibility Refresh Review Notes

**Status:** REVIEW CANDIDATE — NOT APPROVED

## Product-owner decisions requested

1. Does the pair composer make `these are the two people I am comparing` immediate?
2. Is one-column iPhone selection the right tradeoff between scan speed and vertical length?
3. Does the iPad two-region composition use width well without feeling sparse?
4. Does the relationship field feel prestigious, warm, and Humay-specific rather than dating-app, `VS`, or technical synastry UI?
5. Do the single relationship title and long-name examples solve the narrow-column problem?
6. Is the basis disclosure clear enough without overpowering the hero?
7. Does the score feel owned by the relationship rather than floating below it?
8. Are the Light/Dark versions equally intentional?
9. Is the iPhone safe-area CTA preferable to an inline action for this flow?

## Deliberate choices

- The pair composer replaces the compact adaptive grid.
- Long names/signs are used in the reference content to expose pressure early.
- Initial medallions remain the reference default because no approved/licensed portrait assets are assumed.
- The connector is one restrained orbit with a small heart node. It is not a giant heart, `VS`, constellation chart, or synastry diagram.
- Result identity, score, label, and summary share one field.
- Summary copy is editorial text, not a detached capsule.
- Free/Precise basis stays explicit and appears before the score.
- iPad gets a different composition, not a scaled phone screen.

## Out of scope for this review

- SwiftUI implementation or production asset export;
- metrics, Our Take, precise-access, cache/offline/error redesign;
- share-card visual design or image rendering;
- changes to the existing toolbar share control;
- Domain/model/state/test changes;
- D3.3 Event Detail or unrelated Today/Circle work.

The current plain-text `ShareLink` is temporary/non-final UI. Its replacement is now specified in the D8/Phase 10 roadmap as a Humay-branded rendered Compatibility share card. That future family is not designed in this package.

## Approval consequence

Approval authorizes a later task to implement this Compatibility refinement in SwiftUI, cover the documented 0/1/2 states, preserve product truth, and capture real iPhone/iPad Light/Dark evidence for reconciliation. Until approval, the current D2 implementation and approved references remain authoritative.

