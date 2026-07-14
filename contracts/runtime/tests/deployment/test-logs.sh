#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Logs Validation
#
##############################################################################

set -Eeuo pipefail

CONTAINER_NAME="app"

echo
echo "=============================================="
echo "Logs Validation"
echo "=============================================="

##############################################################################
# Validate Container
##############################################################################

if ! sudo docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then

    echo "[FAIL] Application container is not running."

    exit 1

fi

##############################################################################
# Read Logs
##############################################################################

LOGS=$(
sudo docker logs \
    --tail 300 \
    "${CONTAINER_NAME}" 2>&1 || true
)

if [[ -z "${LOGS}" ]]; then

    echo "[FAIL] Container produced no logs."

    exit 1

fi

echo "[PASS] Logs detected."

##############################################################################
# Fatal Errors
##############################################################################

FATAL_ERRORS=(
    "Segmentation fault"
    "OutOfMemoryError"
    "Unable to start"
    "Application run failed"
    "BeanCreationException"
    "Failed to start"
    "NoSuchMethodError"
    "NoClassDefFoundError"
)

for PATTERN in "${FATAL_ERRORS[@]}"; do

    if echo "${LOGS}" | grep -qi "${PATTERN}"; then

        echo "[FAIL] Fatal log detected: ${PATTERN}"

        echo
        echo "========== Matching Logs =========="

        echo "${LOGS}" | grep -in "${PATTERN}" | tail -20

        exit 1

    fi

done

##############################################################################
# Restart Count
##############################################################################

RESTART_COUNT=$(
sudo docker inspect \
    --format='{{.RestartCount}}' \
    "${CONTAINER_NAME}"
)

echo "Restart Count : ${RESTART_COUNT}"

if [[ "${RESTART_COUNT}" -gt 0 ]]; then

    echo "[FAIL] Container has restarted ${RESTART_COUNT} time(s)."

    exit 1

fi

##############################################################################
# Success
##############################################################################

echo "[PASS] Runtime Logs Validation"

exit 0