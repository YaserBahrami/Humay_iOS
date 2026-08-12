#!/bin/bash
# Humay layer discipline for the production baseline.
#
# Intended dependency direction as feature folders are added:
#   App -> Presentation -> Domain <- Data

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

# Domain remains UI/persistence-framework free.
report "Domain must not import SwiftUI" \
  "$(grep -rn '^import SwiftUI' Humay/Domain/ 2>/dev/null)"
report "Domain must not import SwiftData" \
  "$(grep -rn '^import SwiftData' Humay/Domain/ 2>/dev/null)"
report "Domain must not import UIKit" \
  "$(grep -rn '^import UIKit' Humay/Domain/ 2>/dev/null)"

# Persistence must not leak into views/app composition.
report "Presentation/App must not import SwiftData" \
  "$(grep -rn '^import SwiftData' Humay/Presentation/ Humay/App/ 2>/dev/null)"
report "No view may use @Query" \
  "$(grep -rn '@Query' Humay/Presentation/ Humay/App/ 2>/dev/null)"

# Prototype providers/fixtures must never become the production runtime by accident.
report "Production source must not name Mock* service/provider implementations" \
  "$(grep -rnE '\bMock[A-Z][A-Za-z]*(Service|Provider|Repository|Astrology)\b' Humay/ --include='*.swift' 2>/dev/null)"
report "Production source must not seed fixture catalogs" \
  "$(grep -rnE '\b[A-Z][A-Za-z]*Fixtures\b' Humay/ --include='*.swift' 2>/dev/null)"

# @Model entities, if/when SwiftData returns, stay inside the persistence boundary.
report "@Model may only appear in Data/Persistence" \
  "$(grep -rn '@Model' Humay/ --include='*.swift' 2>/dev/null | grep -v '^Humay/Data/Persistence/')"

# New design colors are semantic tokens. Literal Swift colors belong only under
# DesignSystem/Tokens when that production layer is reintroduced.
report "Swift color literals must live under DesignSystem/Tokens" \
  "$(grep -rnE 'Color\(red:|Color\(#colorLiteral|UIColor\(red:' Humay/ --include='*.swift' 2>/dev/null | grep -v '^Humay/DesignSystem/Tokens/')"

if [ "$fail" -eq 0 ]; then
  echo "check-layering: OK"
fi
exit "$fail"
