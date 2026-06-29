#!/bin/bash

set -euo pipefail

##########################################################
# AWS Runtime Authentication
##########################################################

log() {
    echo "[AWS] $*"
}

##########################################################
# Validate Environment
##########################################################

: "${AWS_REGION:?AWS_REGION is required}"
: "${REGISTRY_URL:?REGISTRY_URL is required}"

##########################################################
# Login Amazon ECR
##########################################################

log "Authenticating against Amazon ECR..."

aws ecr get-login-password \
    --region "${AWS_REGION}" \
    | docker login \
        --username AWS \
        --password-stdin "${REGISTRY_URL}"

log "Authentication completed successfully."