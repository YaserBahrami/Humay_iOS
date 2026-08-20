#!/bin/bash
# Production artwork and catalog-access guard for Premium Celestial.
#
# This intentionally scans exact Swift files instead of excluding directories.
# Legitimate data visualization and centralized catalog rendering stay explicit.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0

drawing_allowlist=(
  "Humay/Presentation/Chart/ChartWheel.swift"
)

catalog_access_allowlist=(
  "Humay/DesignSystem/Assets/HumayAssets.swift"
)

is_allowlisted() {
  local candidate="$1"
  shift
  local allowed
  for allowed in "$@"; do
    if [ "$candidate" = "$allowed" ]; then
      return 0
    fi
  done
  return 1
}

report_matches() {
  local message="$1"
  local file="$2"
  local matches="$3"
  echo "FAIL: $message"
  echo "      $file"
  echo "$matches" | sed 's/^/        /'
  fail=1
}

drawing_pattern='((struct|class|enum|actor|extension)\s+[A-Za-z_][A-Za-z0-9_]*(\s*<[^>{}]+>)?\s*:[^{]*\bShape\b|\bCanvas(\s*\([^)]*\))?\s*\{|\bPath\s*[\({]|\bCG(Mutable)?Path\b|\bUIBezierPath\b|\.add(Quad)?Curve\s*\()'
catalog_pattern='\bImage\s*\(\s*(?!systemName\s*:)'

while IFS= read -r file; do
  drawing_matches="$(rg --pcre2 -n -U "$drawing_pattern" "$file" 2>/dev/null || true)"
  if [ -n "$drawing_matches" ] && ! is_allowlisted "$file" "${drawing_allowlist[@]}"; then
    report_matches \
      "Programmatic artwork APIs require an exact-file data-visualization exception" \
      "$file" \
      "$drawing_matches"
  fi

  catalog_matches="$(rg --pcre2 -n -U "$catalog_pattern" "$file" 2>/dev/null || true)"
  if [ -n "$catalog_matches" ] && ! is_allowlisted "$file" "${catalog_access_allowlist[@]}"; then
    report_matches \
      "Bundled images must use HumayAsset; SF Symbols must use Image(systemName:)" \
      "$file" \
      "$catalog_matches"
  fi
done < <(rg --files Humay --glob '*.swift' | sort)

if [ "$fail" -eq 0 ]; then
  echo "check-asset-policy: OK"
fi

exit "$fail"
