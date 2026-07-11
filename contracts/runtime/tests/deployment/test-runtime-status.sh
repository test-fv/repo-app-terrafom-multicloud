#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Runtime Status
#
##############################################################################

set -Eeuo pipefail
set -x
RUNTIME_DIR="/opt/runtime"

echo
echo "=============================================="
echo "Runtime Status Validation"
echo "=============================================="

##############################################################################
# Validate Script
##############################################################################

STATUS_SCRIPT="${RUNTIME_DIR}/scripts/runtime-status.sh"

if [[ ! -f "${STATUS_SCRIPT}" ]]; then

    echo "[FAIL] runtime-status.sh not found."

    exit 1

fi


echo "STATUS_SCRIPT=${STATUS_SCRIPT}"

ls -l "${STATUS_SCRIPT}"

cat "${STATUS_SCRIPT}"



##############################################################################
# Execute Script
##############################################################################

OUTPUT="$(bash "${STATUS_SCRIPT}")"

echo "===================="
echo "${OUTPUT}"
echo "===================="

##############################################################################
# Validate Runtime Version
##############################################################################

echo "${OUTPUT}" | grep -q "Runtime Version" || {

    echo "[FAIL] Runtime Version not found."

    exit 1

}

##############################################################################
# Validate Deployment
##############################################################################

echo "${OUTPUT}" | grep -q "Application" || {

    echo "[FAIL] Application information missing."

    exit 1

}

##############################################################################
# Validate Docker
##############################################################################

echo "${OUTPUT}" | grep -q "Docker Service" || {

    echo "[FAIL] Docker section missing."

    exit 1

}

##############################################################################
# Validate Container
##############################################################################

echo "${OUTPUT}" | grep -q "Container" || {

    echo "[FAIL] Container section missing."

    exit 1

}

##############################################################################
# Validate Health
##############################################################################

echo "${OUTPUT}" | grep -q "Health" || {

    echo "[FAIL] Health information missing."

    exit 1

}

##############################################################################
# Success
##############################################################################

echo "[PASS] Runtime Status Validation"

exit 0