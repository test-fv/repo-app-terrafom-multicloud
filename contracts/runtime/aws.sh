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
# Backup Current Image
##############################################################################

CURRENT_IMAGE=""

if docker ps -a --format '{{.Names}}' | grep -q '^app$'; then

    CURRENT_IMAGE=$(docker inspect \
        --format='{{.Config.Image}}' \
        app)

    log "Current deployed image"

    echo "${CURRENT_IMAGE}"

fi

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
# Wait Application
##############################################################################

log "Waiting application startup"

sleep 20

##############################################################################
# Health Check
##############################################################################

log "Running Health Check"

HEALTH_URL="http://localhost/health"

HTTP_STATUS=$(
    curl \
        -s \
        -o /dev/null \
        -w "%{http_code}" \
        "${HEALTH_URL}" \
    || true
)

echo "HTTP Status: ${HTTP_STATUS}"

if [[ "${HTTP_STATUS}" == "200" ]]; then

    log "Health Check passed."

else

    log "Health Check FAILED."

    DEPLOY_FAILED=true

fi

##############################################################################
# Rollback
##############################################################################

if [[ "${DEPLOY_FAILED:-false}" == "true" ]]; then

    log "Deployment failed"

    if [[ -n "${CURRENT_IMAGE}" ]]; then

        log "Rolling back previous version"

        PREVIOUS_TAG="${CURRENT_IMAGE##*:}"

        cat > "${ENV_FILE}" <<EOF
REGISTRY_SERVER=${REGISTRY_SERVER}
REPOSITORY_NAME=${REPOSITORY_NAME}
IMAGE_TAG=${PREVIOUS_TAG}
EOF

        docker compose \
            --env-file "${ENV_FILE}" \
            -f "${COMPOSE_FILE}" \
            up -d

        log "Rollback completed."

    else

        log "No previous image available."

    fi

    exit 1

fi

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



##############################################################################
# Cleanup
##############################################################################

log "Cleaning Docker"

docker image prune -af || true

##############################################################################
# Finished
##############################################################################

log "Deployment completed successfully"