# Design Reference

This directory is the repository-owned source of truth for Astara product and UI design artifacts.

## Intended structure

```text
docs/design/
  README.md
  claude-reference/
    Product Strategy.dc.html
    Onboarding.dc.html
    Product Design - Pass 2.dc.html
    Product Design - Pass 3.dc.html
    support.js
    _ds/
      classical-.../
        styles.css
        _ds_bundle.js
        _ds_manifest.json
        _adherence.oxlintrc.json
        readme.md
```

Keep the HTML artifacts together with `support.js` and the referenced `_ds` directory so they remain renderable and self-contained.

## Rules

- Treat these files as design/reference artifacts, not production application code.
- Preserve the original generated HTML instead of manually converting it into SwiftUI.
- When a newer approved design pass supersedes an older one, keep the old artifact for history unless it is explicitly marked invalid.
- Product implementation documents should link back to the relevant design artifact/section.
- Deterministic astrology calculations are the source of truth for chart facts; design/sample copy must not become a calculation source.
- Normal and Roast modes must consume the same underlying calculated/interpreted astrology facts.

## Current design status

The current design direction includes Eclipse, Today / Circle / Sky / Chart / Ask, native Western/Vedic/Chinese experiences, Compare Systems, compatibility/Today Together, and Normal/Roast modes.

Before marking the current HTML package as canonical, its frozen prototype dataset should pass the final cross-document calculation/data-integrity check. Once approved, copy the complete Claude Design export into `claude-reference/` without dropping its support assets.
