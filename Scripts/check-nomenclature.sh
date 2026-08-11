#!/bin/bash
# Humay nomenclature/product-language guard.
#
# Protects active naming and user-facing claims that remain invalid. Numeric
# compatibility presentation is intentionally allowed by the current design
# authority; this script does not define the scoring methodology.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0

banned() {
  local pattern="$1"
  local reason="$2"
  local matches
  matches="$(grep -rniE "$pattern" Humay/ HumayTests/ HumayUITests/ --include='*.swift' --include='*.json' --include='*.strings' --include='*.xcstrings' 2>/dev/null \
    | grep -vE ':[[:space:]]*(//|/\\*|\\*)')"
  if [ -n "$matches" ]; then
    echo "FAIL: $reason"
    echo "$matches" | sed 's/^/      /'
    fail=1
  fi
}

# Historical product names.
banned '\\bastara\\b'  'Astara is a historical name and must not appear.'
banned '\\bortus\\b'   'Ortus is a historical placeholder and must not appear.'

# Compatibility may be numerically presented, but an absolute "incompatible"
# verdict still overclaims what the product should say.
banned '\\bincompatible\\b' 'Avoid an absolute "incompatible" compatibility verdict.'

# "Account" implies a sign-in that does not exist; the profile is local to the device.
# Saying there is no account is allowed.
account_hits="$(grep -rniE '"[^"]*\\baccounts?\\b[^"]*"' Humay/ HumayTests/ --include='*.swift' --include='*.json' 2>/dev/null \
  | grep -viE '\\b(no|not|never|without|any|there are none)\\b[^"]{0,24}\\baccounts?\\b' \
  | grep -viE '\\baccounts?\\b[^"]{0,24}\\b(and can.t|here|required|needed)\\b')"
if [ -n "$account_hits" ]; then
  echo 'FAIL: Use "profile", not "account" — there is no sign-in.'
  echo "$account_hits" | sed 's/^/      /'
  fail=1
fi

# "Evidence" was rejected as a UI label; use "astrological basis".
banned '(title|label|kicker|heading)[[:space:]]*:[[:space:]]*"[^"]*\\bevidence\\b' \
  'Use "astrological basis", not "evidence", as a label.'
banned '"[[:space:]]*evidence[[:space:]]*"' \
  'Use "astrological basis", not "evidence", as a label.'

# Premium naming: no currency/wallet semantics.
banned 'Humay Pro|Humay\\+|\\bVIP\\b|\\bcredits\\b|\\bcoins\\b|\\btokens? balance\\b' \
  'Premium is "Humay Premium" or "Premium". No wallet/currency/tier nicknames.'

if [ "$fail" -eq 0 ]; then
  echo "check-nomenclature: OK"
fi
exit "$fail"
