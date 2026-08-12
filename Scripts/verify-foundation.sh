#!/bin/bash
# Canonical repository-local verification entry point for the Humay Apple foundation.
#
# Xcode build/test commands stay documented separately because simulator destinations
# are machine-specific. This script intentionally runs only deterministic repository
# checks that require no simulator selection.

set -euo pipefail
cd "$(dirname "$0")/.."

run_step() {
  local label="$1"
  shift
  echo "==> $label"
  "$@"
}

run_step "Layering" bash ./Scripts/check-layering.sh
run_step "Nomenclature" bash ./Scripts/check-nomenclature.sh
run_step "Diagnostics" bash ./Scripts/check-diagnostics.sh

if git rev-parse --verify HEAD^ >/dev/null 2>&1; then
  run_step "Latest committed diff whitespace" git diff --check HEAD^ HEAD
fi
run_step "Working-tree whitespace" git diff --check

echo "verify-foundation: OK"
