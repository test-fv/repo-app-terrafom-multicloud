#!/bin/bash

set -euo pipefail

#########################################
# Constants
#########################################

APP_HOME="${APP_HOME:-/home/ubuntu/app}"

#########################################
# Logging
#########################################

log() {
  echo "[DEPLOY] $*"
}

#########################################
# Validate environment
#########################################

validate_environment() {

  local required_vars=(
    CLOUD_PROVIDER
    REGISTRY_URL
    IMAGE_NAME
    IMAGE_TAG
    CONTAINER_NAME
  )

  for var in "${required_vars[@]}"; do

    if [[ -z "${!var:-}" ]]; then
      echo "ERROR: Environment variable '${var}' is required."
      exit 1
    fi

  done

}

#########################################
# Load provider runtime
#########################################

load_provider() {

  PROVIDER_SCRIPT="${APP_HOME}/scripts/runtime/providers/${CLOUD_PROVIDER}.sh"

  if [[ ! -f "${PROVIDER_SCRIPT}" ]]; then

    echo "ERROR: Provider runtime not found:"
    echo "       ${PROVIDER_SCRIPT}"
    exit 1

  fi

  log "Loading provider runtime..."

  source "${PROVIDER_SCRIPT}"

}

#########################################
# Cleanup docker cache
#########################################

cleanup_images() {

  log "Cleaning Docker cache..."

  docker image prune -af || true

}

#########################################
# Pull latest image
#########################################

pull_image() {

  FULL_IMAGE="${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}"

  log "Pulling image: ${FULL_IMAGE}"

  docker pull "${FULL_IMAGE}"

}

#########################################
# Replace container
#########################################

replace_container() {

  log "Stopping previous container..."

  docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true

  docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true

  log "Starting new container..."

  docker run \
    -d \
    --name "${CONTAINER_NAME}" \
    --restart unless-stopped \
    -p 80:8080 \
    "${FULL_IMAGE}"

}

#########################################
# Finish
#########################################

finish() {

  echo ""
  echo "==================================="
  echo "Deployment completed successfully"
  echo "Container : ${CONTAINER_NAME}"
  echo "Image     : ${FULL_IMAGE}"
  echo "==================================="

}

#########################################
# Main
#########################################

main() {

  echo "==================================="
  echo "Enterprise Multi-Cloud Deployment"
  echo "==================================="

  validate_environment

  load_provider

  cleanup_images

  pull_image

  replace_container

  finish

}

main "$@"