#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Image Validation
#
##############################################################################

set -Eeuo pipefail

DOCKER="sudo docker"

CONTAINER_NAME="app"
RUNTIME_DIR="/opt/runtime"
ENV_FILE="${RUNTIME_DIR}/.env"

echo
echo "=============================================="
echo "Image Validation"
echo "=============================================="

##############################################################################
# Validate Runtime Environment
##############################################################################

if [[ ! -f "${ENV_FILE}" ]]; then

    echo "[FAIL] Runtime environment file not found."

    exit 1

fi

source "${ENV_FILE}"

##############################################################################
# Validate Required Variables
##############################################################################

: "${REGISTRY_SERVER:?Missing REGISTRY_SERVER}"
: "${REPOSITORY_NAME:?Missing REPOSITORY_NAME}"
: "${IMAGE_TAG:?Missing IMAGE_TAG}"

EXPECTED_IMAGE="${REGISTRY_SERVER}/${REPOSITORY_NAME}:${IMAGE_TAG}"

##############################################################################
# Validate Container Exists
##############################################################################

if ! ${DOCKER} ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then

    echo "[FAIL] Application container is not running."

    exit 1

fi

##############################################################################
# Validate Running Image
##############################################################################

CURRENT_IMAGE=$(
${DOCKER} inspect \
    --format='{{.Config.Image}}' \
    "${CONTAINER_NAME}"
)

echo "Expected : ${EXPECTED_IMAGE}"
echo "Running  : ${CURRENT_IMAGE}"

if [[ "${CURRENT_IMAGE}" != "${EXPECTED_IMAGE}" ]]; then

    echo "[FAIL] Incorrect image deployed."

    exit 1

fi

##############################################################################
# Success
##############################################################################

echo "[PASS] Runtime Image Validation"

exit 0