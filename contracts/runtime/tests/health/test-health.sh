#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Health Test
#
##############################################################################

set -Eeuo pipefail

CONTAINER_NAME="app"
HEALTH_URL="http://localhost/health"

echo
echo "=============================================="
echo "Health Validation"
echo "=============================================="

##############################################################################
# Container Exists
##############################################################################

if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then

    echo "[FAIL] Container does not exist."

    exit 1

fi

##############################################################################
# Container Running
##############################################################################

RUNNING=$(
docker inspect \
    --format='{{.State.Running}}' \
    "${CONTAINER_NAME}"
)

if [[ "${RUNNING}" != "true" ]]; then

    echo "[FAIL] Container is not running."

    exit 1

fi

##############################################################################
# Docker Health
##############################################################################

STATUS=$(
docker inspect \
    --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
    "${CONTAINER_NAME}"
)

if [[ "${STATUS}" != "healthy" ]]; then

    echo "[FAIL] Docker Health = ${STATUS}"

    exit 1

fi

##############################################################################
# HTTP Health Endpoint
##############################################################################

HTTP_CODE=$(
curl \
    --silent \
    --output /dev/null \
    --write-out "%{http_code}" \
    "${HEALTH_URL}" || true
)

if [[ "${HTTP_CODE}" != "200" ]]; then

    echo "[FAIL] HTTP Health returned ${HTTP_CODE}"

    exit 1

fi

##############################################################################
# Success
##############################################################################

echo "[PASS] Runtime Health Validation"

exit 0