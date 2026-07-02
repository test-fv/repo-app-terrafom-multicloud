#!/usr/bin/env bash

##############################################################################
# AWS Runtime Provider
#
# Enterprise Runtime
#
# Responsibilities:
#
#   - Login to Amazon ECR
#   - Generate .env
#   - Pull latest image
#   - Deploy using Docker Compose
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
# Validate Dependencies
##############################################################################

command -v docker >/dev/null \
    || { echo "Docker is not installed."; exit 1; }

command -v aws >/dev/null \
    || { echo "AWS CLI is not installed."; exit 1; }

docker compose version >/dev/null \
    || { echo "Docker Compose V2 is not installed."; exit 1; }

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
# Pull Latest Image
##############################################################################

log "Pulling latest image"

docker compose \
    --env-file "${ENV_FILE}" \
    -f "${COMPOSE_FILE}" \
    pull

##############################################################################
# Deploy
##############################################################################

log "Deploying application"

docker compose \
    --env-file "${ENV_FILE}" \
    -f "${COMPOSE_FILE}" \
    up -d \
    --remove-orphans

##############################################################################
# Cleanup
##############################################################################

log "Cleaning unused images"

docker image prune -af || true

##############################################################################
# Finished
##############################################################################

log "Deployment completed successfully"