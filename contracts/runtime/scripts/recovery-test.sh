#!/usr/bin/env bash

set -Eeuo pipefail

##############################################################################
# Enterprise Runtime Recovery Tests
##############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RECOVERY_DIR="${SCRIPT_DIR}/recovery"

TOTAL=0
PASSED=0
FAILED=0

run_test() {

    local TEST_NAME="$1"
    local TEST_SCRIPT="$2"

    ((TOTAL++))

    printf "%-35s" "${TEST_NAME}"

    if bash "${TEST_SCRIPT}" >/dev/null 2>&1; then

        echo "PASS"

        ((PASSED++))

    else

        echo "FAIL"

        ((FAILED++))

    fi

}

echo
echo "==============================================="
echo "Enterprise Runtime Recovery Validation"
echo "==============================================="
echo

run_test \
    "Deploy Lock" \
    "${RECOVERY_DIR}/test-deploy-lock.sh"

echo
echo "-----------------------------------------------"

echo "Total  : ${TOTAL}"
echo "Passed : ${PASSED}"
echo "Failed : ${FAILED}"

echo "-----------------------------------------------"

if [[ ${FAILED} -eq 0 ]]; then

    echo "Result : SUCCESS"

else

    echo "Result : FAILED"

    exit 1

fi