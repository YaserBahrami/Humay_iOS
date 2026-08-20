#!/usr/bin/env bash
# Unified repository-local Apple verification for Humay.
#
# This runner deliberately treats a passed xcresult as the authority for a test
# pass. Some Xcode versions emit DebuggerLLDB.DebuggerVersionStore.StoreError
# while still bootstrapping and completing XCTest successfully.

set -u
set -o pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PROJECT="Humay.xcodeproj"
SCHEME="Humay"
MODE="${1:-standard}"
INVALID_MODE=0

case "$MODE" in
    quick|standard|full|doctor)
        ;;
    -h|--help|help)
        MODE="help"
        ;;
    *)
        printf 'Unknown mode: %s\n\n' "$MODE" >&2
        MODE="help"
        INVALID_MODE=1
        ;;
esac

usage() {
    cat <<'EOF'
Usage: bash Scripts/verify-apple.sh <mode>

Modes:
  quick     Foundation checks, Debug iPhone build, unit tests.
  standard  quick plus Debug iPad, Release Simulator, and UI smoke tests.
  full      standard plus complete HumayUITests on iPhone and iPad.
  doctor    Report Xcode, runtimes, selected simulators, and basic health.

Optional destination overrides:
  IPHONE_ID=<simulator-udid> IPAD_ID=<simulator-udid> \
    bash Scripts/verify-apple.sh full

Overrides must name available iOS simulators of the matching device family.
EOF
}

if [[ "$MODE" == "help" ]]; then
    usage
    if [[ "$INVALID_MODE" -eq 1 ]]; then
        exit 2
    fi
    exit 0
fi

for tool in xcodebuild xcode-select xcrun; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'INFRASTRUCTURE FAILURE: required tool unavailable: %s\n' "$tool" >&2
        exit 2
    fi
done

RESULTS_ROOT="${VERIFY_RESULTS_DIR:-$ROOT/.verification-results}"
RUN_DIR=""
DERIVED_DATA=""

# Preserve caller overrides before the selected-device variables are populated.
REQUESTED_IPHONE_ID="${IPHONE_ID:-}"
REQUESTED_IPAD_ID="${IPAD_ID:-}"

XCODE_VERSION=""
DEVELOPER_DIR=""
IOS_RUNTIMES=""

IPHONE_ID=""
IPHONE_NAME=""
IPHONE_RUNTIME=""
IPHONE_OVERRIDE=0
IPAD_ID=""
IPAD_NAME=""
IPAD_RUNTIME=""
IPAD_OVERRIDE=0

LAST_RESOLUTION_REASON=""
LAST_HEALTH_REASON=""
LAST_TEST_STATUS=""
LAST_TEST_DETAIL=""
LAST_TEST_BUNDLE=""
LAST_TEST_LOG=""
LAST_TEST_RETRYABLE=0
LAST_TEST_TOTAL=""
LAST_TEST_PASSED=""

OVERALL_FAILURE=0
PRODUCT_FAILURE=0
INFRA_FAILURE=0

SUMMARY_LABELS=()
SUMMARY_RESULTS=()
SUMMARY_DETAILS=()

record() {
    SUMMARY_LABELS+=("$1")
    SUMMARY_RESULTS+=("$2")
    SUMMARY_DETAILS+=("${3:-}")
}

mark_failure() {
    OVERALL_FAILURE=1
    case "$1" in
        product)
            PRODUCT_FAILURE=1
            ;;
        infrastructure)
            INFRA_FAILURE=1
            ;;
    esac
}

capture_environment() {
    XCODE_VERSION="$(xcodebuild -version 2>/dev/null | tr '\n' ' ' | sed 's/[[:space:]]*$//')"
    DEVELOPER_DIR="$(xcode-select -p 2>/dev/null || true)"
    IOS_RUNTIMES="$(xcrun simctl list runtimes 2>/dev/null | sed -n '/^iOS /p')"
}

write_environment_report() {
    {
        printf 'Xcode:\n'
        xcodebuild -version
        printf '\nDeveloper directory:\n%s\n' "$DEVELOPER_DIR"
        printf '\nSimulator runtimes:\n'
        xcrun simctl list runtimes
        printf '\nBooted simulators:\n'
        xcrun simctl list devices booted
        printf '\nDisk:\n'
        df -h "$ROOT"
    } > "$RUN_DIR/environment.txt" 2>&1
}

# Produces state|name|udid records only for available iOS simulators. Parsing the
# human-readable list avoids a jq/Python dependency and never persists a UDID.
device_records() {
    xcrun simctl list devices available 2>/dev/null \
        | awk '
            /^-- iOS / { in_ios = 1; next }
            /^-- / { in_ios = 0 }
            in_ios { print }
        ' \
        | sed -E -n 's/^[[:space:]]*(.*) \(([0-9A-Fa-f-]{36})\) \((Booted|Shutdown)\)[[:space:]]*$/\3|\1|\2/p'
}

record_for_id() {
    local identifier="$1"
    device_records | awk -F'|' -v identifier="$identifier" '$3 == identifier { print; exit }'
}

device_state() {
    local record
    record="$(record_for_id "$1")"
    if [[ -n "$record" ]]; then
        printf '%s\n' "${record%%|*}"
    fi
}

runtime_for_id() {
    local identifier="$1"
    xcrun simctl list devices available 2>/dev/null | awk -v identifier="$identifier" '
        /^-- iOS / {
            runtime = $0
            sub(/^-- /, "", runtime)
            sub(/ --$/, "", runtime)
            in_ios = 1
            next
        }
        /^-- / { in_ios = 0 }
        in_ios && index($0, identifier) { print runtime; exit }
    '
}

family_matches_name() {
    local family="$1"
    local name="$2"
    case "$family" in
        iphone)
            [[ "$name" == iPhone\ * ]]
            ;;
        ipad)
            [[ "$name" == iPad\ * ]]
            ;;
        *)
            return 1
            ;;
    esac
}

preferred_name() {
    local family="$1"
    local name="$2"
    case "$family" in
        iphone)
            [[ "$name" == iPhone\ *Pro* ]]
            ;;
        ipad)
            [[ "$name" == iPad\ Pro\ 13-inch* || "$name" == iPad\ Pro\ 12.9-inch* ]]
            ;;
        *)
            return 1
            ;;
    esac
}

candidate_matches() {
    local family="$1"
    local state="$2"
    local name="$3"
    local preference="$4"

    case "$preference" in
        booted-preferred)
            [[ "$state" == "Booted" ]] && preferred_name "$family" "$name"
            ;;
        shutdown-preferred)
            [[ "$state" == "Shutdown" ]] && preferred_name "$family" "$name"
            ;;
        booted-any)
            [[ "$state" == "Booted" ]] && family_matches_name "$family" "$name"
            ;;
        shutdown-any)
            [[ "$state" == "Shutdown" ]] && family_matches_name "$family" "$name"
            ;;
        *)
            return 1
            ;;
    esac
}

choose_candidate() {
    local family="$1"
    local excluded_id="${2:-}"
    local preference
    local state
    local name
    local identifier
    local records

    records="$(device_records)"
    for preference in booted-preferred shutdown-preferred booted-any shutdown-any; do
        while IFS='|' read -r state name identifier; do
            [[ -z "$identifier" || "$identifier" == "$excluded_id" ]] && continue
            if candidate_matches "$family" "$state" "$name" "$preference"; then
                printf '%s|%s|%s\n' "$state" "$name" "$identifier"
                return 0
            fi
        done <<< "$records"
    done

    return 1
}

set_selected_device() {
    local family="$1"
    local name="$2"
    local identifier="$3"
    local runtime
    runtime="$(runtime_for_id "$identifier")"

    case "$family" in
        iphone)
            IPHONE_NAME="$name"
            IPHONE_ID="$identifier"
            IPHONE_RUNTIME="$runtime"
            ;;
        ipad)
            IPAD_NAME="$name"
            IPAD_ID="$identifier"
            IPAD_RUNTIME="$runtime"
            ;;
    esac
}

override_for_family() {
    case "$1" in
        iphone)
            printf '%s\n' "${IPHONE_ID:-}"
            ;;
        ipad)
            printf '%s\n' "${IPAD_ID:-}"
            ;;
    esac
}

set_override_flag() {
    case "$1" in
        iphone)
            IPHONE_OVERRIDE=1
            ;;
        ipad)
            IPAD_OVERRIDE=1
            ;;
    esac
}

is_overridden_family() {
    case "$1" in
        iphone)
            [[ "$IPHONE_OVERRIDE" -eq 1 ]]
            ;;
        ipad)
            [[ "$IPAD_OVERRIDE" -eq 1 ]]
            ;;
    esac
}

resolve_family() {
    local family="$1"
    local requested_id=""
    local selected_record=""
    local state
    local name
    local identifier

    LAST_RESOLUTION_REASON=""
    case "$family" in
        iphone)
            requested_id="$REQUESTED_IPHONE_ID"
            ;;
        ipad)
            requested_id="$REQUESTED_IPAD_ID"
            ;;
    esac

    if [[ -n "$requested_id" ]]; then
        set_override_flag "$family"
        selected_record="$(record_for_id "$requested_id")"
        if [[ -z "$selected_record" ]]; then
            LAST_RESOLUTION_REASON="override $requested_id is not an available iOS simulator"
            return 1
        fi
    else
        selected_record="$(choose_candidate "$family" || true)"
        if [[ -z "$selected_record" ]]; then
            LAST_RESOLUTION_REASON="no available ${family} simulator found"
            return 1
        fi
    fi

    IFS='|' read -r state name identifier <<< "$selected_record"
    if ! family_matches_name "$family" "$name"; then
        LAST_RESOLUTION_REASON="$identifier is $name, not an ${family} simulator"
        return 1
    fi

    set_selected_device "$family" "$name" "$identifier"
    return 0
}

prepare_simulator() {
    local identifier="$1"
    local name="$2"
    local log="$3"
    local state

    LAST_HEALTH_REASON=""
    {
        printf 'Simulator: %s (%s)\n' "$name" "$identifier"
        printf 'Started: %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
    } > "$log"

    state="$(device_state "$identifier")"
    if [[ -z "$state" ]]; then
        LAST_HEALTH_REASON="simulator disappeared or runtime is unavailable"
        return 1
    fi

    if [[ "$state" != "Booted" ]]; then
        if ! xcrun simctl boot "$identifier" >> "$log" 2>&1; then
            state="$(device_state "$identifier")"
            if [[ "$state" != "Booted" ]]; then
                LAST_HEALTH_REASON="CoreSimulator could not boot $name"
                return 1
            fi
        fi
    fi

    if ! xcrun simctl bootstatus "$identifier" -b >> "$log" 2>&1; then
        LAST_HEALTH_REASON="bootstatus did not complete for $name"
        return 1
    fi

    # SpringBoard is a small, non-destructive responsiveness probe. It does not
    # reset, erase, or otherwise mutate the user's simulator data.
    if ! xcrun simctl spawn "$identifier" launchctl print system/com.apple.SpringBoard >> "$log" 2>&1; then
        LAST_HEALTH_REASON="SpringBoard did not respond on $name"
        return 1
    fi

    return 0
}

family_label() {
    case "$1" in
        iphone) printf 'iPhone' ;;
        ipad) printf 'iPad' ;;
    esac
}

family_id() {
    case "$1" in
        iphone) printf '%s\n' "$IPHONE_ID" ;;
        ipad) printf '%s\n' "$IPAD_ID" ;;
    esac
}

family_name() {
    case "$1" in
        iphone) printf '%s\n' "$IPHONE_NAME" ;;
        ipad) printf '%s\n' "$IPAD_NAME" ;;
    esac
}

prepare_family() {
    local family="$1"
    local label
    local candidate
    local state
    local name
    local identifier
    local log

    label="$(family_label "$family")"
    if ! resolve_family "$family"; then
        record "$label simulator" "INFRASTRUCTURE FAILURE" "$LAST_RESOLUTION_REASON"
        mark_failure infrastructure
        return 1
    fi

    identifier="$(family_id "$family")"
    name="$(family_name "$family")"
    log="$RUN_DIR/simulator-${family}.log"
    if prepare_simulator "$identifier" "$name" "$log"; then
        return 0
    fi

    record "$label simulator" "INFRASTRUCTURE FAILURE" "$LAST_HEALTH_REASON; $log"
    mark_failure infrastructure

    # An explicit user choice always wins. The runner may recheck it once during
    # a test retry, but never silently swaps it for another simulator.
    if is_overridden_family "$family"; then
        return 1
    fi

    candidate="$(choose_candidate "$family" "$identifier" || true)"
    if [[ -z "$candidate" ]]; then
        return 1
    fi

    IFS='|' read -r state name identifier <<< "$candidate"
    log="$RUN_DIR/simulator-${family}-alternate.log"
    if ! prepare_simulator "$identifier" "$name" "$log"; then
        record "$label simulator retry" "INFRASTRUCTURE FAILURE" "$LAST_HEALTH_REASON; $log"
        return 1
    fi

    set_selected_device "$family" "$name" "$identifier"
    record "$label simulator retry" "PASS" "Alternate selected: $name ($identifier)"
    return 0
}

run_logged() {
    local log="$1"
    shift

    {
        printf '$ '
        printf '%q ' "$@"
        printf '\n\n'
    } > "$log"

    "$@" >> "$log" 2>&1
}

first_error_line() {
    local log="$1"
    local line
    line="$(grep -Eim 1 '(^|[[:space:]])(error:|fatal error:)|\*\* (BUILD|TEST) FAILED \*\*' "$log" || true)"
    if [[ -n "$line" ]]; then
        printf '%s\n' "$line"
        return
    fi
    tail -n 1 "$log" | sed 's/^[[:space:]]*//'
}

infrastructure_reason() {
    local log="$1"
    local line
    line="$(grep -Eim 1 'Failed to install or launch the test runner|App installation failed|Unable to Install.*Runner|IDELaunchiPhoneSimulatorLauncher|CoreSimulator|Simulator service|Unable to boot|[Ff]ailed to boot|destination.*(not available|unavailable|not found)|testmanagerd|Test manager|DebuggerLLDB\.DebuggerVersionStore\.StoreError|DTX|Lost connection' "$log" || true)"
    if [[ -n "$line" ]]; then
        printf '%s\n' "$line"
    else
        printf 'Xcode exited before XCTest/XCUITest bootstrap.\n'
    fi
}

has_bootstrap_evidence() {
    grep -Eq "Running tests\\.\\.\\.|Test Suite '.*' started|Test Case '.*' started|Setting up automation session" "$1"
}

has_compilation_failure() {
    grep -Eq '(^|[[:space:]])error:|CompileSwift.*failed|\*\* BUILD FAILED \*\*' "$1"
}

has_application_launch_failure() {
    grep -Eiq 'fatal error:|EXC_(BAD_ACCESS|CRASH|SIGABRT)|Application .* (crashed|failed to launch)|Terminated due to signal' "$1"
}

has_prebootstrap_infrastructure_failure() {
    grep -Eiq 'Failed to install or launch the test runner|App installation failed|Unable to Install.*Runner|IDELaunchiPhoneSimulatorLauncher|testmanagerd.*(failed|unavailable)|Test manager.*(failed|unavailable)|CoreSimulator.*(failed|unavailable)|destination.*(not available|unavailable|not found)' "$1"
}

has_build_infrastructure_failure() {
    grep -Eiq 'CoreSimulator.*(failed|unavailable|invalid|error)|Simulator service.*(failed|unavailable)|Unable to boot|[Ff]ailed to boot|destination.*(not available|unavailable|not found)|Failed to locate any simulator|Lost connection.*Simulator|com\.apple\.CoreSimulator\.SimError' "$1"
}

json_number() {
    local field="$1"
    local file="$2"
    sed -n -E 's/^[[:space:]]*"'"$field"'"[[:space:]]* : ([0-9]+),?/\1/p' "$file" | tail -n 1
}

json_result() {
    sed -n -E 's/^[[:space:]]*"result"[[:space:]]* : "([^"]+)".*/\1/p' "$1" | tail -n 1
}

extract_failed_test() {
    local bundle="$1"
    local tests_file="${bundle}.tests.json"
    local tool_log="${bundle}.xcresulttool-tests.log"
    local test_name=""

    if xcrun xcresulttool get test-results tests --path "$bundle" --format json > "$tests_file" 2> "$tool_log"; then
        test_name="$(awk -F'"' '/"name" :/ { current = $4 } /"result" : "Failed"/ { if (current != "") { print current; exit } }' "$tests_file")"
    fi

    if [[ -n "$test_name" ]]; then
        printf '%s\n' "$test_name"
    else
        printf 'See %s\n' "$tests_file"
    fi
}

classify_test_run() {
    local exit_code="$1"
    local bundle="$2"
    local log="$3"
    local summary_file="${bundle}.summary.json"
    local tool_log="${bundle}.xcresulttool.log"
    local result=""
    local total=""
    local passed=""
    local failed=""

    LAST_TEST_STATUS=""
    LAST_TEST_DETAIL=""
    LAST_TEST_BUNDLE="$bundle"
    LAST_TEST_RETRYABLE=0
    LAST_TEST_TOTAL=""
    LAST_TEST_PASSED=""

    if [[ -d "$bundle" ]] \
        && xcrun xcresulttool get test-results summary --path "$bundle" --format json > "$summary_file" 2> "$tool_log"; then
        result="$(json_result "$summary_file")"
        total="$(json_number totalTestCount "$summary_file")"
        passed="$(json_number passedTests "$summary_file")"
        failed="$(json_number failedTests "$summary_file")"
        LAST_TEST_TOTAL="$total"
        LAST_TEST_PASSED="$passed"
    fi

    if [[ "$exit_code" -eq 0 && "$result" == "Passed" && "$total" =~ ^[1-9][0-9]*$ ]]; then
        LAST_TEST_STATUS="PASS"
        LAST_TEST_DETAIL="${passed:-0}/${total}"
        return
    fi

    # Xcode represents a runner-install failure as a synthetic failed test in
    # xcresult and may log an otherwise-generic `error:` line. It is still
    # infrastructure when no XCTest/XCUITest case began.
    if ! has_bootstrap_evidence "$log" && has_prebootstrap_infrastructure_failure "$log"; then
        LAST_TEST_STATUS="INFRASTRUCTURE FAILURE"
        LAST_TEST_DETAIL="$(infrastructure_reason "$log")"
        LAST_TEST_RETRYABLE=1
        return
    fi

    if has_compilation_failure "$log"; then
        LAST_TEST_STATUS="PRODUCT/TEST FAILURE"
        LAST_TEST_DETAIL="$(first_error_line "$log")"
        return
    fi

    if [[ "$failed" =~ ^[1-9][0-9]*$ || "$result" == "Failed" ]]; then
        LAST_TEST_STATUS="PRODUCT/TEST FAILURE"
        LAST_TEST_DETAIL="Failed test: $(extract_failed_test "$bundle")"
        return
    fi

    if has_application_launch_failure "$log"; then
        LAST_TEST_STATUS="PRODUCT/TEST FAILURE"
        LAST_TEST_DETAIL="$(first_error_line "$log")"
        return
    fi

    if has_bootstrap_evidence "$log"; then
        LAST_TEST_STATUS="PRODUCT/TEST FAILURE"
        LAST_TEST_DETAIL="Test execution began but did not produce a passing result bundle."
        return
    fi

    LAST_TEST_STATUS="INFRASTRUCTURE FAILURE"
    if [[ "$result" == "Passed" && "$exit_code" -ne 0 ]]; then
        LAST_TEST_DETAIL="Xcode returned $exit_code after test results reported Passed."
        LAST_TEST_RETRYABLE=0
    else
        LAST_TEST_DETAIL="$(infrastructure_reason "$log")"
        LAST_TEST_RETRYABLE=1
    fi
}

report_failure() {
    local label="$1"
    local status="$2"
    local detail="$3"
    local log="$4"
    local bundle="${5:-}"

    printf '%s: %s\nReason: %s\nLog: %s\n' "$label" "$status" "$detail" "$log" >&2
    if [[ -n "$bundle" ]]; then
        printf 'Result bundle: %s\n' "$bundle" >&2
    fi
}

run_foundation() {
    local log="$RUN_DIR/foundation.log"
    printf 'Running Foundation...\n'
    if run_logged "$log" bash ./Scripts/verify-foundation.sh; then
        record "Foundation" "PASS"
        return 0
    fi

    record "Foundation" "PRODUCT/TEST FAILURE" "$(first_error_line "$log"); $log"
    mark_failure product
    report_failure "Foundation" "PRODUCT/TEST FAILURE" "$(first_error_line "$log")" "$log"
    return 1
}

run_build() {
    local label="$1"
    local configuration="$2"
    local identifier="$3"
    local slug="$4"
    local log="$RUN_DIR/${slug}.log"
    local detail

    printf 'Running %s...\n' "$label"
    if run_logged "$log" \
        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -configuration "$configuration" \
            -destination "platform=iOS Simulator,id=$identifier" \
            -derivedDataPath "$DERIVED_DATA" \
            build; then
        record "$label" "PASS"
        return 0
    fi

    if has_build_infrastructure_failure "$log"; then
        detail="$(infrastructure_reason "$log")"
        record "$label" "INFRASTRUCTURE FAILURE" "$detail; $log"
        mark_failure infrastructure
        report_failure "$label" "INFRASTRUCTURE FAILURE" "$detail" "$log"
        return 1
    fi

    detail="$(first_error_line "$log")"
    record "$label" "PRODUCT/TEST FAILURE" "$detail; $log"
    mark_failure product
    report_failure "$label" "PRODUCT/TEST FAILURE" "$detail" "$log"
    return 1
}

run_test_once() {
    local slug="$1"
    local attempt="$2"
    local identifier="$3"
    shift 3
    local bundle="$RUN_DIR/${slug}-${attempt}.xcresult"
    local log="$RUN_DIR/${slug}-${attempt}.log"
    local exit_code

    if run_logged "$log" \
        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -configuration Debug \
            -destination "platform=iOS Simulator,id=$identifier" \
            -derivedDataPath "$DERIVED_DATA" \
            -resultBundlePath "$bundle" \
            "$@" \
            test; then
        exit_code=0
    else
        exit_code=$?
    fi

    classify_test_run "$exit_code" "$bundle" "$log"
    LAST_TEST_LOG="$log"
}

run_test_with_retry() {
    local label="$1"
    local family="$2"
    local primary_id="$3"
    local primary_name="$4"
    local slug="$5"
    shift 5
    local first_detail
    local first_bundle
    local retry_id
    local retry_name
    local retry_note
    local candidate
    local state
    local name
    local identifier
    local retry_log

    printf 'Running %s...\n' "$label"
    run_test_once "$slug" 1 "$primary_id" "$@"

    case "$LAST_TEST_STATUS" in
        PASS)
            record "$label" "PASS (${LAST_TEST_DETAIL})" "$primary_name"
            return 0
            ;;
        PRODUCT/TEST\ FAILURE)
            record "$label" "PRODUCT/TEST FAILURE" "$LAST_TEST_DETAIL; $LAST_TEST_BUNDLE"
            mark_failure product
            report_failure "$label" "PRODUCT/TEST FAILURE" "$LAST_TEST_DETAIL" "$LAST_TEST_LOG" "$LAST_TEST_BUNDLE"
            return 1
            ;;
    esac

    first_detail="$LAST_TEST_DETAIL"
    first_bundle="$LAST_TEST_BUNDLE"
    record "$label" "INFRASTRUCTURE FAILURE" "$first_detail; $first_bundle"
    mark_failure infrastructure
    report_failure "$label" "INFRASTRUCTURE FAILURE" "$first_detail" "$LAST_TEST_LOG" "$first_bundle"

    if [[ "$LAST_TEST_RETRYABLE" -ne 1 ]]; then
        return 1
    fi

    retry_id="$primary_id"
    retry_name="$primary_name"
    retry_note="same simulator"

    if ! is_overridden_family "$family"; then
        candidate="$(choose_candidate "$family" "$primary_id" || true)"
        if [[ -n "$candidate" ]]; then
            IFS='|' read -r state name identifier <<< "$candidate"
            retry_log="$RUN_DIR/simulator-${family}-test-retry.log"
            if prepare_simulator "$identifier" "$name" "$retry_log"; then
                retry_id="$identifier"
                retry_name="$name"
                retry_note="alternate simulator"
            fi
        fi
    fi

    if [[ "$retry_id" == "$primary_id" ]]; then
        retry_log="$RUN_DIR/simulator-${family}-test-retry.log"
        if ! prepare_simulator "$retry_id" "$retry_name" "$retry_log"; then
            record "$label retry" "INFRASTRUCTURE FAILURE" "$LAST_HEALTH_REASON; $retry_log"
            return 1
        fi
    fi

    printf 'Retrying %s once on %s...\n' "$label" "$retry_name"
    run_test_once "$slug" 2 "$retry_id" "$@"
    case "$LAST_TEST_STATUS" in
        PASS)
            record "$label retry" "PASS (${LAST_TEST_DETAIL})" "Initial infrastructure failure; $retry_note: $retry_name ($retry_id)"
            if [[ "$retry_id" != "$primary_id" ]]; then
                set_selected_device "$family" "$retry_name" "$retry_id"
            fi
            return 0
            ;;
        PRODUCT/TEST\ FAILURE)
            record "$label retry" "PRODUCT/TEST FAILURE" "$LAST_TEST_DETAIL; $LAST_TEST_BUNDLE"
            mark_failure product
            report_failure "$label retry" "PRODUCT/TEST FAILURE" "$LAST_TEST_DETAIL" "$LAST_TEST_LOG" "$LAST_TEST_BUNDLE"
            return 1
            ;;
        *)
            record "$label retry" "INFRASTRUCTURE FAILURE" "$LAST_TEST_DETAIL; $LAST_TEST_BUNDLE"
            report_failure "$label retry" "INFRASTRUCTURE FAILURE" "$LAST_TEST_DETAIL" "$LAST_TEST_LOG" "$LAST_TEST_BUNDLE"
            return 1
            ;;
    esac
}

record_not_run() {
    record "$1" "NOT RUN" "$2"
}

print_summary() {
    local index
    local result

    printf '\nHumay Verification\n\n'
    for ((index = 0; index < ${#SUMMARY_LABELS[@]}; index++)); do
        if [[ -n "${SUMMARY_DETAILS[index]}" ]]; then
            printf '%-22s %s — %s\n' "${SUMMARY_LABELS[index]}" "${SUMMARY_RESULTS[index]}" "${SUMMARY_DETAILS[index]}"
        else
            printf '%-22s %s\n' "${SUMMARY_LABELS[index]}" "${SUMMARY_RESULTS[index]}"
        fi
    done

    printf '\n'
    printf 'iPhone: %s%s\n' "${IPHONE_NAME:-not resolved}" "${IPHONE_ID:+ ($IPHONE_ID)}"
    printf 'iPad: %s%s\n' "${IPAD_NAME:-not resolved}" "${IPAD_ID:+ ($IPAD_ID)}"
    printf 'Xcode: %s\n' "${XCODE_VERSION:-unknown}"
    printf 'Runtime: %s\n' "${IOS_RUNTIMES:-unknown}"
    printf 'Logs/results: %s\n' "$RUN_DIR"

    if [[ "$PRODUCT_FAILURE" -eq 1 && "$INFRA_FAILURE" -eq 1 ]]; then
        result="FAILURE (PRODUCT/TEST + INFRASTRUCTURE)"
    elif [[ "$PRODUCT_FAILURE" -eq 1 ]]; then
        result="PRODUCT/TEST FAILURE"
    elif [[ "$INFRA_FAILURE" -eq 1 ]]; then
        result="INFRASTRUCTURE FAILURE"
    else
        result="PASS"
    fi
    printf 'Result: %s\n' "$result"
}

print_doctor_device() {
    local label="$1"
    local name="$2"
    local identifier="$3"
    local state
    local health=""
    local device_status=0

    state="$(device_state "$identifier")"
    if [[ "$state" == "Booted" ]]; then
        if xcrun simctl spawn "$identifier" launchctl print system/com.apple.SpringBoard >/dev/null 2>&1; then
            health="responsive"
        else
            health="SpringBoard probe failed"
            device_status=1
        fi
    elif [[ "$state" == "Shutdown" ]]; then
        health="shutdown (doctor does not boot devices)"
    else
        health="missing or unavailable"
        device_status=1
    fi

    printf '%s: %s (%s) — %s; %s\n' "$label" "$name" "$identifier" "${state:-missing}" "$health"
    return "$device_status"
}

run_doctor() {
    local doctor_status=0

    capture_environment
    printf 'Humay Verification Doctor\n\n'
    printf 'Xcode: %s\n' "$XCODE_VERSION"
    printf 'Developer directory: %s\n' "${DEVELOPER_DIR:-unknown}"
    printf 'Installed iOS runtimes:\n%s\n' "${IOS_RUNTIMES:-none}"
    printf 'Disk:\n'
    df -h "$ROOT"

    if resolve_family iphone; then
        if ! print_doctor_device "iPhone" "$IPHONE_NAME" "$IPHONE_ID"; then
            doctor_status=1
        fi
    else
        printf 'iPhone: unavailable — %s\n' "$LAST_RESOLUTION_REASON"
        doctor_status=1
    fi

    if resolve_family ipad; then
        if ! print_doctor_device "iPad" "$IPAD_NAME" "$IPAD_ID"; then
            doctor_status=1
        fi
    else
        printf 'iPad: unavailable — %s\n' "$LAST_RESOLUTION_REASON"
        doctor_status=1
    fi

    printf 'Booted simulators:\n'
    xcrun simctl list devices booted
    return "$doctor_status"
}

if [[ "$MODE" == "doctor" ]]; then
    run_doctor
    exit $?
fi

capture_environment
mkdir -p "$RESULTS_ROOT"
RUN_ID="$(date '+%Y%m%d-%H%M%S')-$MODE"
RUN_DIR="$RESULTS_ROOT/$RUN_ID"
if [[ -e "$RUN_DIR" ]]; then
    RUN_DIR="${RUN_DIR}-$$"
fi
mkdir -p "$RUN_DIR"
DERIVED_DATA="$RUN_DIR/DerivedData"
write_environment_report

run_foundation || true

IPHONE_READY=0
IPAD_READY=0
if prepare_family iphone; then
    IPHONE_READY=1
fi

if [[ "$MODE" == "standard" || "$MODE" == "full" ]]; then
    if prepare_family ipad; then
        IPAD_READY=1
    fi
fi

if [[ "$IPHONE_READY" -eq 1 ]]; then
    run_build "Debug iPhone" Debug "$IPHONE_ID" "debug-iphone" || true
else
    record_not_run "Debug iPhone" "No healthy iPhone simulator."
fi

if [[ "$MODE" == "standard" || "$MODE" == "full" ]]; then
    if [[ "$IPAD_READY" -eq 1 ]]; then
        run_build "Debug iPad" Debug "$IPAD_ID" "debug-ipad" || true
    else
        record_not_run "Debug iPad" "No healthy iPad simulator."
    fi

    if [[ "$IPHONE_READY" -eq 1 ]]; then
        run_build "Release Simulator" Release "$IPHONE_ID" "release-simulator" || true
    elif [[ "$IPAD_READY" -eq 1 ]]; then
        run_build "Release Simulator" Release "$IPAD_ID" "release-simulator" || true
    else
        record_not_run "Release Simulator" "No healthy simulator."
    fi
fi

UNIT_ID=""
UNIT_NAME=""
UNIT_FAMILY=""
if [[ "$IPHONE_READY" -eq 1 ]]; then
    UNIT_ID="$IPHONE_ID"
    UNIT_NAME="$IPHONE_NAME"
    UNIT_FAMILY="iphone"
elif [[ "$IPAD_READY" -eq 1 ]]; then
    UNIT_ID="$IPAD_ID"
    UNIT_NAME="$IPAD_NAME"
    UNIT_FAMILY="ipad"
fi

if [[ -n "$UNIT_ID" ]]; then
    run_test_with_retry \
        "Unit tests" \
        "$UNIT_FAMILY" \
        "$UNIT_ID" \
        "$UNIT_NAME" \
        "unit-tests" \
        -only-testing:HumayTests || true
else
    record_not_run "Unit tests" "No healthy simulator."
fi

if [[ "$MODE" == "standard" || "$MODE" == "full" ]]; then
    # Existing canonical flows only: completed root launch, Daily Horoscope,
    # loaded Chart navigation, and Connections compatibility.
    SMOKE_TESTS=(
        "HumayUITests/LaunchUITests/testCompletedOnboardingPersistsAcrossRelaunch"
        "HumayUITests/LaunchUITests/testPhase2DailyPeriodSwitchingAndFreeReading"
        "HumayUITests/LaunchUITests/testD4LoadedWesternChartOpensPlacementDetail"
        "HumayUITests/LaunchUITests/testD2PrimaryNavigationAndCompatibilityFlow"
    )
    SMOKE_ARGUMENTS=()
    for test_identifier in "${SMOKE_TESTS[@]}"; do
        SMOKE_ARGUMENTS+=("-only-testing:$test_identifier")
    done

    if [[ "$IPHONE_READY" -eq 1 ]]; then
        run_test_with_retry \
            "UI smoke" \
            iphone \
            "$IPHONE_ID" \
            "$IPHONE_NAME" \
            "ui-smoke-iphone" \
            "${SMOKE_ARGUMENTS[@]}" || true
    else
        record_not_run "UI smoke" "No healthy iPhone simulator."
    fi
fi

if [[ "$MODE" == "full" ]]; then
    if [[ "$IPHONE_READY" -eq 1 ]]; then
        run_test_with_retry \
            "UI full iPhone" \
            iphone \
            "$IPHONE_ID" \
            "$IPHONE_NAME" \
            "ui-full-iphone" \
            -only-testing:HumayUITests || true
    else
        record_not_run "UI full iPhone" "No healthy iPhone simulator."
    fi

    if [[ "$IPAD_READY" -eq 1 ]]; then
        run_test_with_retry \
            "UI full iPad" \
            ipad \
            "$IPAD_ID" \
            "$IPAD_NAME" \
            "ui-full-ipad" \
            -only-testing:HumayUITests || true
    else
        record_not_run "UI full iPad" "No healthy iPad simulator."
    fi
fi

print_summary
exit "$OVERALL_FAILURE"
