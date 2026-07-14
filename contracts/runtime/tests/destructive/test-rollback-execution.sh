#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Rollback Execution Validation
#
##############################################################################

set -Eeuo pipefail

RUNTIME_DIR="/opt/runtime"

ROLLBACK_SCRIPT="${RUNTIME_DIR}/scripts/rollback.sh"
LAST_GOOD_ENV="${RUNTIME_DIR}/last-good.env"

CONTAINER_NAME="app"
HEALTH_URL="http://localhost/health"

MAX_ATTEMPTS=30
SLEEP_SECONDS=5

echo
echo "=============================================="
echo "Rollback Execution Validation"
echo "=============================================="

##############################################################################
# Validate Files
##############################################################################

[[ -f "${LAST_GOOD_ENV}" ]] || {
    echo "[FAIL] last-good.env not found."
    exit 1
}

[[ -x "${ROLLBACK_SCRIPT}" ]] || {
    echo "[FAIL] rollback.sh not found or not executable."
    exit 1
}

##############################################################################
# Read Expected Image
##############################################################################

set -a
source "${LAST_GOOD_ENV}"
set +a

EXPECTED_IMAGE="${REGISTRY_SERVER}/${REPOSITORY_NAME}:${IMAGE_TAG}"

echo "[INFO] Expected Image : ${EXPECTED_IMAGE}"

##############################################################################
# Execute Rollback
##############################################################################

echo "[INFO] Executing rollback..."

bash "${ROLLBACK_SCRIPT}"

##############################################################################
# Wait Recovery
##############################################################################

ATTEMPT=1

while [[ ${ATTEMPT} -le ${MAX_ATTEMPTS} ]]; do

    RUNNING=$(
        sudo docker inspect \
            --format='{{.State.Running}}' \
            "${CONTAINER_NAME}" 2>/dev/null || echo "false"
    )

    HEALTH=$(
        sudo docker inspect \
            --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
            "${CONTAINER_NAME}" 2>/dev/null || echo "none"
    )

    echo "Attempt ${ATTEMPT}/${MAX_ATTEMPTS} -> Running=${RUNNING} Health=${HEALTH}"

    if [[ "${RUNNING}" == "true" && "${HEALTH}" == "healthy" ]]; then
        break
    fi

    sleep "${SLEEP_SECONDS}"

    ((ATTEMPT++))

done

##############################################################################
# Validate Runtime
##############################################################################

[[ "${RUNNING}" == "true" ]] || {
    echo "[FAIL] Container is not running after rollback."
    exit 1
}

[[ "${HEALTH}" == "healthy" ]] || {
    echo "[FAIL] Container is unhealthy after rollback."
    exit 1
}

##############################################################################
# Validate Image
##############################################################################

CURRENT_IMAGE=$(
sudo docker inspect \
    --format='{{.Config.Image}}' \
    "${CONTAINER_NAME}"
)

echo "[INFO] Current Image : ${CURRENT_IMAGE}"

[[ "${CURRENT_IMAGE}" == "${EXPECTED_IMAGE}" ]] || {
    echo "[FAIL] Rolled back image does not match last-good.env."
    exit 1
}

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

[[ "${HTTP_CODE}" == "200" ]] || {
    echo "[FAIL] Health endpoint returned ${HTTP_CODE}"
    exit 1
}

##############################################################################
# Success
##############################################################################

echo "[PASS] Rollback Execution Validation"

exit 0