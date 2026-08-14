# Compatibility Refresh Review Notes

**Status:** APPROVED VISUAL REFERENCE — IMPLEMENTED AND RECONCILED

## Approved product decisions

1. Pair Composer makes the selected relationship explicit before comparison.
2. Compact selection uses one-column person rows to preserve readable names and signs.
3. iPad selection uses a bounded two-region composition.
4. Compatibility result uses one warm, Humay-specific Relationship Field rather than dating-app, `VS`, or technical synastry UI.
5. Pair identity and long names receive enough width to wrap as whole words.
6. Free/Precise disclosure remains visible before the score without overpowering the field.
7. Score, relationship label, and summary belong to the shared relationship composition.
8. Light and Dark appearances receive intentional treatments.
9. Compact iPhone keeps the action in a safe-area tray; iPad keeps it in the pair-context region.

## Deliberate choices

- The pair composer replaces the compact adaptive grid.
- Long names/signs are used in the reference content to expose pressure early.
- Initial medallions remain the reference default because no approved/licensed portrait assets are assumed.
- The connector is one restrained orbit with a small heart node. It is not a giant heart, `VS`, constellation chart, or synastry diagram.
- Result identity, score, label, and summary share one field.
- Summary copy is editorial text, not a detached capsule.
- Free/Precise basis stays explicit and appears before the score.
- iPad gets a different composition, not a scaled phone screen.

## Out of scope for this approval

- metrics, Our Take, precise-access, cache/offline/error redesign;
- share-card visual design or image rendering;
- changes to the existing toolbar share control;
- Domain/model/state/test changes;
- D3.3 Event Detail or unrelated Today/Circle work.

The current plain-text `ShareLink` is temporary/non-final UI. Its replacement is now specified in the D8/Phase 10 roadmap as a Humay-branded rendered Compatibility share card. That future family is not designed in this package.

## Approval and reconciliation record

Approval was recorded on 2026-08-13 after the documented 0/1/2 selection states, product-truth disclosures, adaptive behavior, and accessibility behavior were implemented in `CompatibilitySelectionView.swift` and `CompatibilityView.swift` and reconciled with real iPhone/iPad Light/Dark evidence in [`../../../implementation-evidence/d2-today-circle/compatibility-refresh/`](../../../implementation-evidence/d2-today-circle/compatibility-refresh/README.md). This package now supersedes only the relevant Compatibility-selection and result-hero portions of the older D2 reference.
