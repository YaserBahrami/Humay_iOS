# D3.1 — Current Sky

**Status:** requirements prepared; visual references not created or approved.

This package defines the handoff for the Current Sky visual-design pass. [design-spec.md](design-spec.md) is the working specification. There are intentionally no final reference images in this package yet.

## Required reference set

Current Sky requires all of the following before approval:

- [ ] iPhone Light
- [ ] iPhone Dark
- [ ] iPad Light
- [ ] iPad Dark
- [ ] iPad landscape/adaptive notes
- [ ] compact-width fallback behavior
- [ ] state-reference coverage recorded
- [ ] accessibility risks reviewed
- [ ] final review outcome recorded

Approval is package-wide. One device or appearance cannot be approved as the implementation source while another remains missing.

## Design and implementation gates

1. Create the four main visual references from [design-spec.md](design-spec.md).
2. Review hierarchy, semantics, adaptation, accessibility, assets, and sample disclosures.
3. Record approval only after all four main references and adaptive notes are accepted.
4. Implement Current Sky SwiftUI only after that approval.
5. Capture real iPhone/iPad implementation evidence and reconcile it in a later task.

Until then, the existing Sky placeholder remains unchanged. This package does not authorize CurrentSkyView, Calendar UI, event-detail UI, new routes, provider integration, caching, or persistence.
