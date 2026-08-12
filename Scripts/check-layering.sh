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

# Data implementations may depend on Domain, but never on UI frameworks.
report "Data must not import SwiftUI" \
  "$(grep -rn '^import SwiftUI' Humay/Data/ 2>/dev/null)"
report "Data must not import UIKit" \
  "$(grep -rn '^import UIKit' Humay/Data/ 2>/dev/null)"

# Persistence implementations are composed by App and must not leak into Presentation.
report "Presentation must not import SwiftData" \
  "$(grep -rn '^import SwiftData' Humay/Presentation/ 2>/dev/null)"
report "No view may use @Query" \
  "$(grep -rn '@Query' Humay/Presentation/ Humay/App/ 2>/dev/null)"

# Presentation receives boundary abstractions/state. Concrete boundary implementations
# are created only by App composition. This naming guard is intentionally narrow so it
# does not invent requirements for providers or repositories that do not exist yet.
report "Presentation must not construct concrete boundary implementations" \
  "$(grep -rnE '\b[A-Z][A-Za-z0-9]*(Adapter|Client|Provider|Repository)\(' Humay/Presentation/ --include='*.swift' 2>/dev/null)"

# The composition boundary uses explicit ownership rather than a global service locator.
# Keep this focused on dependency-container patterns so unrelated framework-style shared
# instances are not prohibited by accident.
report "Production dependencies must not use a service locator" \
  "$(grep -rnE '\b(class|struct|actor|enum)[[:space:]]+(ServiceLocator|DependencyContainer|DependencyRegistry|AppDependencies)\b' Humay/ --include='*.swift' 2>/dev/null)"
report "AppEnvironment must not become a global shared singleton" \
  "$(grep -rnE 'static[[:space:]]+let[[:space:]]+shared[[:space:]]*=[[:space:]]*AppEnvironment\b' Humay/ --include='*.swift' 2>/dev/null)"

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
