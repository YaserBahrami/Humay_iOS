#!/bin/bash
# Narrow production diagnostics and obvious-secret guard for Humay.
#
# This scans only production Swift source under Humay/. It intentionally does not
# inspect tests, documentation or git history.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0

report_matches() {
  local message="$1"
  local matches="$2"
  if [ -n "$matches" ]; then
    echo "FAIL: $message"
    echo "$matches" | sed 's/^/      /'
    fail=1
  fi
}

print_matches="$(grep -RInE --include='*.swift' '(^|[^[:alnum:]_])(print|debugPrint)[[:space:]]*\(' Humay/ 2>/dev/null \
  | grep -vE ':[[:space:]]*(//|/\*|\*)')"
report_matches "Production source must not use print or debugPrint" "$print_matches"

secret_declarations="$(grep -RInE --include='*.swift' \
  '^[[:space:]]*((private|fileprivate|internal|public|static|class|lazy|final|nonisolated)[[:space:]]+)*(let|var)[[:space:]]+(apiKey|apiSecret|clientSecret|bearerToken)([[:space:]]*[:=]|[[:space:]]*$)' \
  Humay/ 2>/dev/null \
  | grep -vE ':[[:space:]]*(//|/\*|\*)')"
report_matches "Production source must not declare obvious client secrets" "$secret_declarations"

if [ "$fail" -eq 0 ]; then
  echo "check-diagnostics: OK"
fi
exit "$fail"
