#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Recovery Test
#
##############################################################################

set -Eeuo pipefail

CONTAINER_NAME="app"
HEALTH_URL="http://localhost/health"

MAX_ATTEMPTS=30
SLEEP_SECONDS=5

echo
echo "=============================================="
echo "Recovery Validation"
echo "=============================================="

##############################################################################
# Validate Container Exists
##############################################################################

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then

    echo "[FAIL] Container is not running."

    exit 1

fi

##############################################################################
# Validate Initial Health
##############################################################################

STATUS=$(
docker inspect \
    --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
    "${CONTAINER_NAME}"
)

if [[ "${STATUS}" != "healthy" ]]; then

    echo "[FAIL] Initial Health = ${STATUS}"

    exit 1

fi

##############################################################################
# Simulate Runtime Crash
##############################################################################

echo "[INFO] Simulating application crash..."

docker exec "${CONTAINER_NAME}" kill -9 1

##############################################################################
# Wait Recovery
##############################################################################

ATTEMPT=1

while [[ ${ATTEMPT} -le ${MAX_ATTEMPTS} ]]; do

    RUNNING=$(
        docker inspect \
            --format='{{.State.Running}}' \
            "${CONTAINER_NAME}" 2>/dev/null || echo "false"
    )

    STATUS=$(
        docker inspect \
            --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
            "${CONTAINER_NAME}" 2>/dev/null || echo "none"
    )

    echo "Attempt ${ATTEMPT}/${MAX_ATTEMPTS} -> Running=${RUNNING} Health=${STATUS}"

    if [[ "${RUNNING}" == "true" && "${STATUS}" == "healthy" ]]; then

        break

    fi

    sleep "${SLEEP_SECONDS}"

    ((ATTEMPT++))

done

##############################################################################
# Validate Recovery
##############################################################################

if [[ "${RUNNING}" != "true" ]]; then

    echo "[FAIL] Container never restarted."

    exit 1

fi

if [[ "${STATUS}" != "healthy" ]]; then

    echo "[FAIL] Container never became healthy."

    exit 1

fi

##############################################################################
# Validate Endpoint
##############################################################################

HTTP_CODE=$(
curl \
    --silent \
    --output /dev/null \
    --write-out "%{http_code}" \
    "${HEALTH_URL}" || true
)

if [[ "${HTTP_CODE}" != "200" ]]; then

    echo "[FAIL] Health endpoint returned ${HTTP_CODE}"

    exit 1

fi

##############################################################################
# Success
##############################################################################

echo "[PASS] Runtime recovered successfully."

exit 0