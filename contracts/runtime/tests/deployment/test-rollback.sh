#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Rollback Configuration Validation
#
##############################################################################

set -Eeuo pipefail

RUNTIME_DIR="/opt/runtime"

ROLLBACK_SCRIPT="${RUNTIME_DIR}/scripts/rollback.sh"
LAST_GOOD_ENV="${RUNTIME_DIR}/last-good.env"
COMPOSE_FILE="${RUNTIME_DIR}/compose.yaml"
ENV_FILE="${RUNTIME_DIR}/.env"

echo
echo "=============================================="
echo "Rollback Configuration Validation"
echo "=============================================="

##############################################################################
# Validate Files
##############################################################################

[[ -f "${ROLLBACK_SCRIPT}" ]] || {
    echo "[FAIL] rollback.sh not found."
    exit 1
}

[[ -x "${ROLLBACK_SCRIPT}" ]] || {
    echo "[FAIL] rollback.sh is not executable."
    exit 1
}

[[ -f "${LAST_GOOD_ENV}" ]] || {
    echo "[FAIL] last-good.env not found."
    exit 1
}

[[ -f "${COMPOSE_FILE}" ]] || {
    echo "[FAIL] compose.yaml not found."
    exit 1
}

[[ -f "${ENV_FILE}" ]] || {
    echo "[FAIL] .env not found."
    exit 1
}

##############################################################################
# Validate last-good.env
##############################################################################

set -a
source "${LAST_GOOD_ENV}"
set +a

: "${REGISTRY_SERVER:?Missing REGISTRY_SERVER}"
: "${REPOSITORY_NAME:?Missing REPOSITORY_NAME}"
: "${IMAGE_TAG:?Missing IMAGE_TAG}"

echo "[PASS] last-good.env is valid."

##############################################################################
# Validate rollback script references
##############################################################################

grep -q "compose.yaml" "${ROLLBACK_SCRIPT}" || {
    echo "[FAIL] rollback.sh does not reference compose.yaml."
    exit 1
}

grep -q "last-good.env" "${ROLLBACK_SCRIPT}" || {
    echo "[FAIL] rollback.sh does not reference last-good.env."
    exit 1
}

echo "[PASS] rollback.sh references required runtime files."

##############################################################################
# Success
##############################################################################

echo "[PASS] Rollback Configuration Validation"

exit 0