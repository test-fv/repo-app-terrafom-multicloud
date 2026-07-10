#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation Framework
#
##############################################################################

set -Eeuo pipefail

echo "#############################################"
echo "RUN-ALL VERSION 2"
echo "#############################################"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PASS=0
FAIL=0
TOTAL=0

##############################################################################
# Colors
##############################################################################

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

##############################################################################
# Header
##############################################################################

echo
echo "=================================================="
echo "Enterprise Runtime Validation"
echo "=================================================="

##############################################################################
# Execute Test
##############################################################################

run_test() {

    local TEST_FILE="$1"

    local TEST_NAME
    TEST_NAME="$(basename "${TEST_FILE}" .sh)"

    printf "  %-45s" "${TEST_NAME}"

    ((TOTAL++))

    echo "Executing: ${TEST_FILE}"

    if bash -x "${TEST_FILE}"; then

        printf "${GREEN}PASS${RESET}\n"

        ((PASS++))

    else

        printf "${RED}FAIL${RESET}\n"

        ((FAIL++))

    fi

}

##############################################################################
# Discover Categories
##############################################################################

while IFS= read -r CATEGORY_DIR; do

    CATEGORY_NAME="$(basename "${CATEGORY_DIR}")"

    echo
    echo "--------------------------------------------------"
    echo "${CATEGORY_NAME}"
    echo "--------------------------------------------------"

    while IFS= read -r TEST_FILE; do

        run_test "${TEST_FILE}"

    done < <(
        find "${CATEGORY_DIR}" \
            -maxdepth 1 \
            -type f \
            -name "*.sh" \
            | sort
    )

done < <(

    find "${ROOT_DIR}" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        | sort

)

##############################################################################
# Summary
##############################################################################

echo
echo "=================================================="
echo "Validation Summary"
echo "=================================================="

printf "%-20s %s\n" "Total Tests :" "${TOTAL}"
printf "%-20s %b\n" "Passed :" "${GREEN}${PASS}${RESET}"
printf "%-20s %b\n" "Failed :" "${RED}${FAIL}${RESET}"

echo

if [[ ${FAIL} -eq 0 ]]; then

    echo -e "${GREEN}Runtime CERTIFIED${RESET}"

    exit 0

fi

echo -e "${RED}Runtime VALIDATION FAILED${RESET}"

exit 1