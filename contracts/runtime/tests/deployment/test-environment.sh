#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Environment Validation
#
##############################################################################

set -Eeuo pipefail

RUNTIME_DIR="/opt/runtime"
ENV_FILE="${RUNTIME_DIR}/.env"

echo
echo "=============================================="
echo "Environment Validation"
echo "=============================================="

##############################################################################
# Validate .env exists
##############################################################################

if [[ ! -f "${ENV_FILE}" ]]; then

    echo "[FAIL] .env file not found."

    exit 1

fi

##############################################################################
# Load Environment
##############################################################################

set -a
source "${ENV_FILE}"
set +a

##############################################################################
# Required Variables
##############################################################################

REQUIRED_VARIABLES=(
    REGISTRY_SERVER
    REPOSITORY_NAME
    IMAGE_TAG
)

##############################################################################
# Validate Variables
##############################################################################

FAILED=0

for VAR in "${REQUIRED_VARIABLES[@]}"; do

    VALUE="${!VAR:-}"

    if [[ -z "${VALUE}" ]]; then

        echo "[FAIL] ${VAR} is empty or undefined."

        FAILED=1

    else

        echo "[PASS] ${VAR}=${VALUE}"

    fi

done

##############################################################################
# Final Result
##############################################################################

if [[ ${FAILED} -ne 0 ]]; then

    exit 1

fi

echo "[PASS] Runtime Environment Validation"

exit 0