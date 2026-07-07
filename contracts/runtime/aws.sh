#!/usr/bin/env bash

##############################################################################
# AWS Runtime Provider
#
# Enterprise Runtime
#
##############################################################################

set -Eeuo pipefail

##############################################################################
# Runtime Version
##############################################################################

RUNTIME_VERSION_FILE="/opt/runtime/runtime.version"

PROVIDER_VERSION="1.0.0"

if [[ -f "${RUNTIME_VERSION_FILE}" ]]; then

    RUNTIME_VERSION="$(cat "${RUNTIME_VERSION_FILE}")"

else

    RUNTIME_VERSION="unknown"

fi

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

LAST_GOOD_ENV="${RUNTIME_DIR}/last-good.env"

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

log "Runtime Information"

echo "Runtime Version : ${RUNTIME_VERSION}"
echo "Provider        : AWS"
echo "Provider Ver.   : ${PROVIDER_VERSION}"
echo "Docker Host     : $(hostname)"

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
# Wait Docker Health
##############################################################################

log "Waiting Docker Health"

DEPLOY_FAILED=false

MAX_HEALTH_ATTEMPTS=30
HEALTH_ATTEMPT=1

while [[ ${HEALTH_ATTEMPT} -le ${MAX_HEALTH_ATTEMPTS} ]]; do

    STATUS=$(
        docker inspect \
            --format='{{.State.Health.Status}}' \
            app 2>/dev/null || echo "starting"
    )

    echo "Docker Health ${HEALTH_ATTEMPT}/${MAX_HEALTH_ATTEMPTS} -> ${STATUS}"

    case "${STATUS}" in

        healthy)

            log "Container is healthy."

            break
            ;;

        unhealthy)

            log "Container became unhealthy."

            DEPLOY_FAILED=true

            break
            ;;

    esac

    sleep 5

    ((HEALTH_ATTEMPT++))

done

if [[ ${HEALTH_ATTEMPT} -gt ${MAX_HEALTH_ATTEMPTS} ]]; then

    log "Container never became healthy."


    echo
    echo "========== docker ps =========="
    docker ps -a
    echo

    echo "========== docker inspect =========="
    docker inspect app || true
    echo

    echo "========== docker logs =========="
    docker logs app || true
    echo

    DEPLOY_FAILED=true

fi

##############################################################################
# Rollback
##############################################################################

if [[ "${DEPLOY_FAILED:-false}" == "true" ]]; then

    log "Deployment failed"

    log "Writing failed deployment history"

    bash "${RUNTIME_DIR}/scripts/write-history.sh" \
        FAILED \
        true || true

    bash "${RUNTIME_DIR}/scripts/rollback.sh"

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
# Deployment Metadata
##############################################################################

log "Writing deployment metadata"

cat > "${RUNTIME_DIR}/version.json" <<EOF
{
  "application": "${REPOSITORY_NAME}",
  "provider": "aws",
  "registry": "${REGISTRY_SERVER}",
  "image": "${REGISTRY_SERVER}/${REPOSITORY_NAME}:${IMAGE_TAG}",
  "tag": "${IMAGE_TAG}",
  "runtime_version": "1.0.0",
  "deployed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

##############################################################################
# Save Last Good Deployment
##############################################################################

log "Saving last successful deployment"

cp "${ENV_FILE}" "${LAST_GOOD_ENV}"

##############################################################################
# Deployment History
##############################################################################

log "Writing deployment history"

echo "Bucket desde aws.sh = ${RUNTIME_BUCKET_NAME:-VACIO}"

bash "${RUNTIME_DIR}/scripts/write-history.sh" \
    SUCCESS \
    false


##############################################################################
# Cleanup
##############################################################################

log "Cleaning Docker"

docker image prune -af || true

##############################################################################
# Finished
##############################################################################

log "Deployment completed successfully"