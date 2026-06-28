#!/usr/bin/env bash

set -Eeuo pipefail

##########################################################
# Azure Provider Runtime
##########################################################

provider_login() {

    echo ""
    echo "========================================"
    echo "Azure Provider Authentication"
    echo "========================================"

    : "${REGISTRY_URL:?REGISTRY_URL environment variable is required}"
    : "${REGISTRY_USERNAME:?REGISTRY_USERNAME environment variable is required}"
    : "${REGISTRY_PASSWORD:?REGISTRY_PASSWORD environment variable is required}"

    echo "${REGISTRY_PASSWORD}" | docker login \
        "${REGISTRY_URL}" \
        --username "${REGISTRY_USERNAME}" \
        --password-stdin

    echo ""
    echo "ACR authentication completed."

}