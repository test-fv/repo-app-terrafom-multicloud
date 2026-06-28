#!/usr/bin/env bash

set -Eeuo pipefail

#########################################
# Logging
#########################################

log() {
    echo ""
    echo "=================================================="
    echo "[DEPLOY] $1"
    echo "=================================================="
}

#########################################
# Required variables
#########################################

required_vars=(
    CLOUD_PROVIDER
    REGISTRY_URL
    IMAGE_NAME
    IMAGE_TAG
    CONTAINER_NAME
)

for var in "${required_vars[@]}"; do

    if [[ -z "${!var:-}" ]]; then
        echo "ERROR -> Missing environment variable: ${var}"
        exit 1
    fi

done

#########################################
# Runtime location
#########################################

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROJECT_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"

PROVIDER_SCRIPT="${PROJECT_ROOT}/scripts/runtime/providers/${CLOUD_PROVIDER}.sh"

#########################################
# Load Provider
#########################################

if [[ ! -f "${PROVIDER_SCRIPT}" ]]; then

    echo "Provider runtime not found."

    echo "${PROVIDER_SCRIPT}"

    exit 1

fi

source "${PROVIDER_SCRIPT}"

#########################################
# Authenticate
#########################################

log "Provider Authentication"

provider_login

#########################################
# Image
#########################################

IMAGE="${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}"

#########################################
# Pull
#########################################

log "Pulling latest image"

docker pull "${IMAGE}"

#########################################
# Stop previous container
#########################################

log "Removing previous container"

docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true

docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true

#########################################
# Cleanup
#########################################

log "Cleaning Docker cache"

docker image prune -af || true

#########################################
# Run container
#########################################

log "Starting container"

docker run \
    -d \
    --restart unless-stopped \
    --name "${CONTAINER_NAME}" \
    -p 80:8080 \
    "${IMAGE}"

#########################################
# Health
#########################################

sleep 5

docker ps

#########################################
# Finish
#########################################

log "Deployment completed"

echo "Container : ${CONTAINER_NAME}"

echo "Image     : ${IMAGE}"