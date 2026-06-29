#!/usr/bin/env bash

##############################################################################
# Enterprise Runtime Launcher
#
# This script is the only entry point executed by AWS Systems Manager.
#
# It must remain completely independent from:
#
#   - Git
#   - SSH
#   - Repository layout
#
##############################################################################

set -Eeuo pipefail

##############################################################################
# Locate Runtime
##############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RUNTIME_ROOT="${SCRIPT_DIR}"

PROVIDERS_DIR="${RUNTIME_ROOT}/providers"

##############################################################################
# Validate Environment
##############################################################################

: "${CLOUD_PROVIDER:?CLOUD_PROVIDER not defined}"

: "${REGISTRY_SERVER:?REGISTRY_SERVER not defined}"

: "${REPOSITORY_NAME:?REPOSITORY_NAME not defined}"

: "${IMAGE_TAG:=latest}"

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

if [[ ! -f "${PROVIDER_SCRIPT}" ]]; then

    echo "Provider script not found"

    echo "${PROVIDER_SCRIPT}"

    exit 1

fi

chmod +x "${PROVIDER_SCRIPT}"

##############################################################################
# Export Runtime Variables
##############################################################################

export REGISTRY_SERVER

export REPOSITORY_NAME

export IMAGE_TAG

##############################################################################
# Execute Provider
##############################################################################

log "Executing ${CLOUD_PROVIDER} deployment..."

exec "${PROVIDER_SCRIPT}"