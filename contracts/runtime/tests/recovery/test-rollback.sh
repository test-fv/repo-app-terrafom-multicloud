#!/usr/bin/env bash

set -Eeuo pipefail

RUNTIME_DIR="/opt/runtime"

echo
echo "=========================================="
echo "Rollback Test"
echo "=========================================="

##############################################################################
# Preconditions
##############################################################################

if [[ ! -f "${RUNTIME_DIR}/last-good.env" ]]; then

    echo "[FAIL] last-good.env not found"

    exit 1

fi

if [[ ! -f "${RUNTIME_DIR}/scripts/rollback.sh" ]]; then

    echo "[FAIL] rollback.sh not found"

    exit 1

fi

##############################################################################
# Execute Rollback
##############################################################################

echo "Executing rollback..."

bash "${RUNTIME_DIR}/scripts/rollback.sh"

##############################################################################
# Validate Container
##############################################################################

sleep 10

STATUS=$(
docker inspect \
    --format='{{.State.Health.Status}}' \
    app 2>/dev/null || echo "missing"
)

echo "Container Status : ${STATUS}"

if [[ "${STATUS}" != "healthy" ]]; then

    echo "[FAIL] Rollback did not recover application"

    exit 1

fi

echo "[PASS] Rollback completed successfully"

exit 0