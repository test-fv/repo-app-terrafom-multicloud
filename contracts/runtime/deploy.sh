#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Launcher
#
# Entry point executed by deploy-remote.sh
#
##############################################################################

set -Eeuo pipefail

##############################################################################
# Deployment Lock
##############################################################################

LOCK_FILE="/opt/runtime/deploy.lock"

cleanup() {

    rm -f "${LOCK_FILE}"

}

trap cleanup EXIT

if [[ -f "${LOCK_FILE}" ]]; then

    echo
    echo "=================================================="
    echo "Another deployment is already running."
    echo "=================================================="

    exit 1

fi

cat > "${LOCK_FILE}" <<EOF
Started At : $(date -u +"%Y-%m-%dT%H:%M:%SZ")
User       : $(whoami)
PID        : $$
Image Tag  : ${IMAGE_TAG:-unknown}
Host        : $(hostname)
EOF

##############################################################################
# Runtime Layout
##############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RUNTIME_ROOT="${SCRIPT_DIR}"

PROVIDERS_DIR="${RUNTIME_ROOT}/providers"

COMPOSE_FILE="${RUNTIME_ROOT}/compose.yaml"

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
# Validate Environment
##############################################################################

: "${CLOUD_PROVIDER:?CLOUD_PROVIDER not defined}"

: "${REGISTRY_SERVER:?REGISTRY_SERVER not defined}"

: "${REPOSITORY_NAME:?REPOSITORY_NAME not defined}"

: "${IMAGE_TAG:=latest}"

##############################################################################
# Validate Runtime
##############################################################################

log "Validating runtime..."

[[ -f "${COMPOSE_FILE}" ]] || {

    echo "compose.yaml not found."

    exit 1

}

success() {

    echo "[SUCCESS] $1"

}

success "Runtime validated."

##############################################################################
# Select Provider
##############################################################################

case "${CLOUD_PROVIDER}" in

    aws)

        PROVIDER_SCRIPT="${PROVIDERS_DIR}/aws.sh"

        ;;

    azure)

        PROVIDER_SCRIPT="${PROVIDERS_DIR}/azure.sh"

        ;;

    *)

        echo "Unsupported provider: ${CLOUD_PROVIDER}"

        exit 1

        ;;

esac

##############################################################################
# Validate Provider
##############################################################################

[[ -f "${PROVIDER_SCRIPT}" ]] || {

    echo "Provider script not found."

    echo "${PROVIDER_SCRIPT}"

    exit 1

}

chmod +x "${PROVIDER_SCRIPT}"

##############################################################################
# Export Runtime Variables
##############################################################################

export REGISTRY_SERVER

export REPOSITORY_NAME

export IMAGE_TAG

export COMPOSE_FILE

export RUNTIME_BUCKET_NAME

export AWS_REGION

##############################################################################
# Summary
##############################################################################

log "Deployment Configuration"

echo "Cloud Provider : ${CLOUD_PROVIDER}"

echo "Registry       : ${REGISTRY_SERVER}"

echo "Repository     : ${REPOSITORY_NAME}"

echo "Image Tag      : ${IMAGE_TAG}"

echo "Provider       : ${PROVIDER_SCRIPT}"

##############################################################################
# Execute Provider
##############################################################################

log "Executing provider..."

exec "${PROVIDER_SCRIPT}"