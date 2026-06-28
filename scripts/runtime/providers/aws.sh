#!/usr/bin/env bash

set -Eeuo pipefail

##########################################################
# AWS Provider Runtime
##########################################################

provider_login() {

    echo ""
    echo "========================================"
    echo "AWS Provider Authentication"
    echo "========================================"

    : "${AWS_REGION:?AWS_REGION environment variable is required}"
    : "${REGISTRY_URL:?REGISTRY_URL environment variable is required}"

    aws ecr get-login-password \
        --region "${AWS_REGION}" \
    | docker login \
        --username AWS \
        --password-stdin \
        "${REGISTRY_URL}"

    echo ""
    echo "ECR authentication completed."

}