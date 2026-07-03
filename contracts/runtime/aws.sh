#!/usr/bin/env bash

##############################################################################
# AWS Runtime Provider
#
# Enterprise Runtime
#
##############################################################################

set -Eeuo pipefail

##############################################################################
# Required Variables
##############################################################################

: "${AWS_REGION:?AWS_REGION is required}"
: "${REGISTRY_SERVER:?REGISTRY_SERVER is required}"
: "${REPOSITORY_NAME:?REPOSITORY_NAME is required}"
: "${IMAGE_TAG:=latest}"

##############################################################################
# Runtime Location
##############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RUNTIME_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

COMPOSE_FILE="${RUNTIME_DIR}/compose.yaml"

ENV_FILE="${RUNTIME_DIR}/.env"

##############################################################################
# Logging
##############################################################################

log() {

    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="

}

##############################################################################
# Validate Runtime
##############################################################################

[[ -f "${COMPOSE_FILE}" ]] || {

    echo "compose.yaml not found."

    exit 1

}

##############################################################################
# Validate Dependencies
##############################################################################

command -v docker >/dev/null \
    || { echo "Docker is not installed."; exit 1; }

command -v aws >/dev/null \
    || { echo "AWS CLI is not installed."; exit 1; }

docker compose version >/dev/null \
    || { echo "Docker Compose V2 is not installed."; exit 1; }

##############################################################################
# Ensure Docker
##############################################################################

if ! systemctl is-active --quiet docker; then

    log "Starting Docker"

    sudo systemctl start docker

fi

##############################################################################
# Login to Amazon ECR
##############################################################################

log "Authenticating with Amazon ECR"

aws ecr get-login-password \
    --region "${AWS_REGION}" \
| docker login \
    --username AWS \
    --password-stdin "${REGISTRY_SERVER}"

##############################################################################
# Generate Runtime Environment
##############################################################################

log "Generating runtime environment"

cat > "${ENV_FILE}" <<EOF
REGISTRY_SERVER=${REGISTRY_SERVER}
REPOSITORY_NAME=${REPOSITORY_NAME}
IMAGE_TAG=${IMAGE_TAG}
EOF

##############################################################################
# Pull Images
##############################################################################

log "Pulling latest images"

docker compose \
    --env-file "${ENV_FILE}" \
    -f "${COMPOSE_FILE}" \
    pull

##############################################################################
# Stop Previous Containers
##############################################################################

log "Stopping previous containers"

docker compose \
    --env-file "${ENV_FILE}" \
    -f "${COMPOSE_FILE}" \
    down \
    --remove-orphans || true

##############################################################################
# Deploy
##############################################################################

log "Deploying application"

docker compose \
    --env-file "${ENV_FILE}" \
    -f "${COMPOSE_FILE}" \
    up -d

##############################################################################
# Show Status
##############################################################################

log "Running containers"

docker compose \
    --env-file "${ENV_FILE}" \
    -f "${COMPOSE_FILE}" \
    ps

##############################################################################
# Cleanup
##############################################################################

log "Cleaning Docker"

docker image prune -af || true

##############################################################################
# Finished
##############################################################################

log "Deployment completed successfully"