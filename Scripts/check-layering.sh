#!/bin/bash
# Humay layer discipline.
#
# The application is a single target with folder-based layering, so the compiler
# cannot enforce the dependency direction. These greps do instead. Run before
# committing; also run in CI.
#
#   App  ->  Presentation  ->  Domain  <-  Data
#
# Domain is pure Swift. Presentation never sees persistence or a concrete mock.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0

report() {
  local message="$1"
  local matches="$2"
  if [ -n "$matches" ]; then
    echo "FAIL: $message"
    echo "$matches" | sed 's/^/      /'
    fail=1
  fi
}

# Domain is framework-free: no UI, no persistence.
report "Domain must not import SwiftUI" \
  "$(grep -rn '^import SwiftUI' Humay/Domain/ 2>/dev/null)"
report "Domain must not import SwiftData" \
  "$(grep -rn '^import SwiftData' Humay/Domain/ 2>/dev/null)"
report "Domain must not import UIKit" \
  "$(grep -rn '^import UIKit' Humay/Domain/ 2>/dev/null)"

# Persistence never reaches the view layer. @Query would destroy the boundary.
report "Presentation must not import SwiftData" \
  "$(grep -rn '^import SwiftData' Humay/Presentation/ Humay/App/ Humay/DesignSystem/ 2>/dev/null)"
report "No view may use @Query" \
  "$(grep -rn '@Query' Humay/Presentation/ Humay/App/ 2>/dev/null)"

# Views depend on protocols. Only the composition root names an implementation.
#
# Matches the mock service and helper types specifically rather than any identifier
# beginning with "Mock" — SampleContentMarker is design-system chrome that renders a
# provenance, not an implementation the view is reaching past its protocol for.
report "Presentation must not name a concrete mock implementation" \
  "$(grep -rnE '\bMock[A-Z][A-Za-z]*(Service|Repository|Latency|Astrology|ContentProvider)\b' Humay/Presentation/ 2>/dev/null)"
report "Presentation must not name a concrete repository implementation" \
  "$(grep -rnE '\b(SwiftData|InMemory)[A-Z][A-Za-z]*Repository' Humay/Presentation/ 2>/dev/null)"

# @Model entities are an implementation detail of the persistence layer.
report "@Model may only appear in Data/Persistence" \
  "$(grep -rn '@Model' Humay/ --include='*.swift' 2>/dev/null | grep -v '^Humay/Data/Persistence/')"

# Fixtures live in exactly one place, so the whole directory can be deleted rather than
# migrated when real services arrive. The composition root is the one exception: it is
# already the file that names every implementation, and seeding is wiring.
report "Fixtures may only be named under Data/Mock or the composition root" \
  "$(grep -rnE '\b[A-Z][A-Za-z]*Fixtures\b' Humay/ --include='*.swift' 2>/dev/null \
     | grep -v '^Humay/Data/Mock/' \
     | grep -v '^Humay/App/AppEnvironment')"

# Colour is a token, not a literal.
report "Colour literals belong only in HumayPalette.swift" \
  "$(grep -rnE 'Color\(red:|Color\(#colorLiteral|UIColor\(red:' Humay/ --include='*.swift' 2>/dev/null | grep -v 'HumayPalette.swift')"

if [ "$fail" -eq 0 ]; then
  echo "check-layering: OK"
fi
exit "$fail"
