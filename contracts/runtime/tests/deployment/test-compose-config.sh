#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Docker Compose Configuration
#
##############################################################################

set -Eeuo pipefail

RUNTIME_DIR="/opt/runtime"
COMPOSE_FILE="${RUNTIME_DIR}/compose.yaml"
ENV_FILE="${RUNTIME_DIR}/.env"

echo
echo "=============================================="
echo "Compose Configuration Validation"
echo "=============================================="

##############################################################################
# Validate Files
##############################################################################

[[ -f "${COMPOSE_FILE}" ]] || {

    echo "[FAIL] compose.yaml not found."

    exit 1

}

[[ -f "${ENV_FILE}" ]] || {

    echo "[FAIL] .env not found."

    exit 1

}

##############################################################################
# Validate Docker Compose Configuration
##############################################################################

if ! sudo docker compose \
        --env-file "${ENV_FILE}" \
        -f "${COMPOSE_FILE}" \
        config >/dev/null; then

    echo "[FAIL] Docker Compose configuration is invalid."

    exit 1

fi

##############################################################################
# Success
##############################################################################

echo "[PASS] Docker Compose Configuration Validation"

exit 0