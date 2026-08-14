#!/bin/bash
# Production Presentation typography guard.
#
# Humay-owned feature text consumes semantic HumayTypography roles. This guard
# intentionally does not inspect system/SF Symbol sizing or native controls.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

matches="$(rg -n --glob '*.swift' \
  'Font\.custom|\.font\([[:space:]]*\.custom|CormorantGaramond|Newsreader16pt' \
  Humay/Presentation 2>/dev/null || true)"

if [ -n "$matches" ]; then
  echo "FAIL: Presentation must use semantic HumayTypography roles for custom fonts"
  echo "$matches" | sed 's/^/      /'
  exit 1
fi

echo "verify-typography: OK"
