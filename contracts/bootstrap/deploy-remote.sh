#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Bootstrap
#
# Purpose
#
#   Bootstrap executed remotely through AWS Systems Manager.
#
# Responsibilities
#
#   - Validate runtime configuration
#   - Download deployment artifact
#   - Verify SHA256 checksum
#   - Extract runtime
#   - Authenticate against registry
#   - Execute runtime deploy.sh
#   - Cleanup temporary files
#
##############################################################################

set -Eeuo pipefail

##############################################################################
# Load Runtime Environment
##############################################################################

if [[ -f /tmp/runtime.env ]]; then

    set -a
    source /tmp/runtime.env
    set +a

else

    echo "runtime.env not found."
    exit 1

fi

##############################################################################
# Global Configuration
##############################################################################

RUNTIME_HOME="/opt/runtime"

TMP_DIR="/tmp"

ARTIFACT="${TMP_DIR}/deployment-artifact.tar.gz"

CHECKSUM="${TMP_DIR}/deployment-artifact.tar.gz.sha256"

EXTRACT_DIR="${TMP_DIR}/runtime"

RUNTIME_ENV="${TMP_DIR}/runtime.env"

##############################################################################
# Colors
##############################################################################

RED="\033[31m"

GREEN="\033[32m"

YELLOW="\033[33m"

BLUE="\033[34m"

RESET="\033[0m"

##############################################################################
# Logging
##############################################################################

log() {

    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${RESET} $*"

}

success() {

    echo -e "${GREEN}[SUCCESS]${RESET} $*"

}

warning() {

    echo -e "${YELLOW}[WARNING]${RESET} $*"

}

error() {

    echo -e "${RED}[ERROR]${RESET} $*" >&2

}

##############################################################################
# Error Handler
##############################################################################

on_error() {

    local exit_code=$?

    error "Bootstrap failed."

    error "Exit Code: ${exit_code}"

    error "Line: ${BASH_LINENO[0]}"

    exit "${exit_code}"

}

trap on_error ERR

##############################################################################
# Required Environment Variables
##############################################################################

require_env() {

    local variable="$1"

    if [[ -z "${!variable:-}" ]]; then

        error "Missing environment variable: ${variable}"

        exit 1

    fi

}

log "Validating runtime configuration..."

require_env RUNTIME_BUCKET

require_env CLOUD_PROVIDER

require_env AWS_REGION

require_env REGISTRY_SERVER

require_env REPOSITORY_NAME

require_env IMAGE_TAG

success "Runtime configuration validated."

##############################################################################
# Runtime Information
##############################################################################

log "Cloud Provider : ${CLOUD_PROVIDER}"

log "Runtime Bucket : ${RUNTIME_BUCKET}"

log "Registry       : ${REGISTRY_SERVER}"

log "Repository     : ${REPOSITORY_NAME}"

log "Image Tag      : ${IMAGE_TAG}"

##############################################################################
# Prepare Directories
##############################################################################

log "Preparing runtime directories..."

rm -rf "${EXTRACT_DIR}"

mkdir -p "${EXTRACT_DIR}"

mkdir -p "${RUNTIME_HOME}"

success "Directories ready."

##############################################################################
# Download Runtime Artifact
##############################################################################

log "Downloading deployment artifact..."

aws s3 cp \
    "s3://${RUNTIME_BUCKET}/artifacts/latest.tar.gz" \
    "${ARTIFACT}"

log "Downloading checksum..."

aws s3 cp \
    "s3://${RUNTIME_BUCKET}/artifacts/latest.tar.gz.sha256" \
    "${CHECKSUM}"

success "Artifacts downloaded."

##############################################################################
# Validate Files
##############################################################################

[[ -f "${ARTIFACT}" ]] || {

    error "Artifact was not downloaded."

    exit 1

}

[[ -f "${CHECKSUM}" ]] || {

    error "Checksum file was not downloaded."

    exit 1

}

##############################################################################
# Verify SHA256
##############################################################################

log "Verifying SHA256 checksum..."

pushd "${TMP_DIR}" >/dev/null

sha256sum -c "$(basename "${CHECKSUM}")"

popd >/dev/null

success "Checksum verification passed."

##############################################################################
# Extract Runtime
##############################################################################

log "Extracting runtime artifact..."

tar -xzf "${ARTIFACT}" \
    -C "${EXTRACT_DIR}"

##############################################################################
# Validate Runtime Structure
##############################################################################

[[ -f "${EXTRACT_DIR}/artifact/runtime/deploy.sh" ]] || {

    error "deploy.sh not found."

    exit 1

}

[[ -f "${EXTRACT_DIR}/artifact/runtime/compose.yaml" ]] || {

    error "compose.yaml not found."

    exit 1

}

success "Runtime extracted successfully."

##############################################################################
# Install Runtime
##############################################################################

log "Installing runtime..."

rm -rf "${RUNTIME_HOME}"

mkdir -p "${RUNTIME_HOME}"

cp -R \
    "${EXTRACT_DIR}/artifact/runtime/"* \
    "${RUNTIME_HOME}/"

chmod +x "${RUNTIME_HOME}/deploy.sh"

success "Runtime installed."

##############################################################################
# Runtime Layout
##############################################################################

log "Runtime contents:"

find "${RUNTIME_HOME}" -maxdepth 2 -type f



##############################################################################
# Verify Docker
##############################################################################

log "Checking Docker installation..."

if ! command -v docker >/dev/null 2>&1; then

    error "Docker is not installed."

    exit 1

fi

success "Docker found."

##############################################################################
# Ensure Docker Service
##############################################################################

log "Checking Docker service..."

if ! systemctl is-active --quiet docker; then

    warning "Docker service is stopped."

    log "Starting Docker..."

    sudo systemctl start docker

fi

success "Docker service is running."

##############################################################################
# Verify Docker Compose
##############################################################################

log "Checking Docker Compose..."

if docker compose version >/dev/null 2>&1; then

    COMPOSE_CMD="docker compose"

elif command -v docker-compose >/dev/null 2>&1; then

    COMPOSE_CMD="docker-compose"

else

    error "Docker Compose is not installed."

    exit 1

fi

success "Docker Compose detected."

##############################################################################
# Registry Authentication
##############################################################################

case "${CLOUD_PROVIDER}" in

aws)

    log "Authenticating against Amazon ECR..."

    aws ecr get-login-password \
        --region "${AWS_REGION}" \
    | docker login \
        --username AWS \
        --password-stdin \
        "${REGISTRY_SERVER}"

    success "Authenticated against ECR."

    ;;

azure)

    warning "Azure login is not implemented yet."

    ;;

*)

    error "Unsupported cloud provider: ${CLOUD_PROVIDER}"

    exit 1

    ;;

esac

##############################################################################
# Runtime Directory
##############################################################################

cd "${RUNTIME_HOME}"

success "Runtime ready."


##############################################################################
# Execute Runtime Deployment
##############################################################################

log "Executing runtime deployment..."

export COMPOSE_CMD

export RUNTIME_ENV

export REGISTRY_SERVER

export REPOSITORY_NAME

export IMAGE_TAG

bash "${RUNTIME_HOME}/deploy.sh"

success "Runtime deployment finished."

##############################################################################
# Verify Containers
##############################################################################

log "Checking running containers..."

docker ps

##############################################################################
# Cleanup
##############################################################################

log "Cleaning temporary files..."

rm -rf "${EXTRACT_DIR}"

rm -f "${ARTIFACT}"

rm -f "${CHECKSUM}"



success "Temporary files removed."

##############################################################################
# Deployment Summary
##############################################################################

echo

echo "============================================================"

success "Enterprise Deployment Completed Successfully"

echo "============================================================"

echo "Cloud Provider : ${CLOUD_PROVIDER}"

echo "Registry       : ${REGISTRY_SERVER}"

echo "Repository     : ${REPOSITORY_NAME}"

echo "Image Tag      : ${IMAGE_TAG}"

echo "Runtime Home   : ${RUNTIME_HOME}"

echo "============================================================"

##############################################################################
# Exit
##############################################################################

exit 0