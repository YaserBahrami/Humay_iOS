#!/bin/bash
# Humay nomenclature freeze.
#
# Some of these words are banned because they are historical names, and some
# because they make a claim the product must not make — a compatibility score, a
# permanent unlock, an "account" for what is a local profile on one device.
#
# See docs/design/DESIGN_AUTHORITY.md sections 05 and 07.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0

# Comment lines are skipped throughout: these rules are about the words the product
# says, and a doc comment explaining why a word is banned must not itself trip the check.
banned() {
  local pattern="$1"
  local reason="$2"
  local matches
  matches="$(grep -rniE "$pattern" Humay/ HumayTests/ HumayUITests/ --include='*.swift' --include='*.json' --include='*.strings' --include='*.xcstrings' 2>/dev/null \
    | grep -vE ':[[:space:]]*(//|/\*|\*)')"
  if [ -n "$matches" ]; then
    echo "FAIL: $reason"
    echo "$matches" | sed 's/^/      /'
    fail=1
  fi
}

# Historical product names.
banned '\bastara\b'  'Astara is a historical name and must not appear.'
banned '\bortus\b'   'Ortus is a historical placeholder and must not appear.'

# Claims the product does not make.
banned 'matchscore|compatibilityscore|\bmatchPercent'  'Compatibility is never scored or ranked.'
banned '[0-9]+% match'                                 'Compatibility is never expressed as a percentage.'
banned '\bincompatible\b'                              'Compatibility uses qualitative verdicts, never a negative absolute.'

# "Account" implies a sign-in that does not exist; the profile is local to the device.
# Saying there is *no* account is the point, so negations are allowed through.
account_hits="$(grep -rniE '"[^"]*\baccounts?\b[^"]*"' Humay/ HumayTests/ --include='*.swift' --include='*.json' 2>/dev/null \
  | grep -viE '\b(no|not|never|without|any|there are none)\b[^"]{0,24}\baccounts?\b' \
  | grep -viE '\baccounts?\b[^"]{0,24}\b(and can.t|here|required|needed)\b')"
if [ -n "$account_hits" ]; then
  echo 'FAIL: Use "profile", not "account" — there is no sign-in.'
  echo "$account_hits" | sed 's/^/      /'
  fail=1
fi

# "Evidence" was rejected as a *label*; the term is "astrological basis". The word is
# still ordinary English and may appear inside a reading, so only heading-shaped uses
# are flagged — a short quoted string, or one passed as a title.
banned '(title|label|kicker|heading)[[:space:]]*:[[:space:]]*"[^"]*\bevidence\b'  'Use "astrological basis", not "evidence", as a label.'
banned '"[[:space:]]*evidence[[:space:]]*"'  'Use "astrological basis", not "evidence", as a label.'

# Premium naming.
banned 'Humay Pro|Humay\+|\bVIP\b|\bcredits\b|\bcoins\b|\btokens? balance\b' \
  'Premium is "Humay Premium" or "Premium". No wallet, currency or tier nicknames.'

if [ "$fail" -eq 0 ]; then
  echo "check-nomenclature: OK"
fi
exit "$fail"
