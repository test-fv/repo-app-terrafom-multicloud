#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Registry Validation
#
##############################################################################

set -Eeuo pipefail

RUNTIME_DIR="/opt/runtime"
ENV_FILE="${RUNTIME_DIR}/.env"

echo
echo "=============================================="
echo "Registry Validation"
echo "=============================================="

##############################################################################
# Validate Dependencies
##############################################################################

if ! command -v aws >/dev/null; then

    echo "[FAIL] AWS CLI is not installed."

    exit 1

fi

##############################################################################
# Validate Environment
##############################################################################

if [[ ! -f "${ENV_FILE}" ]]; then

    echo "[FAIL] Runtime .env not found."

    exit 1

fi

set -a
source "${ENV_FILE}"
set +a

: "${AWS_REGION:?AWS_REGION is required}"
: "${REPOSITORY_NAME:?REPOSITORY_NAME is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"

##############################################################################
# Validate AWS Credentials
##############################################################################

if ! aws sts get-caller-identity >/dev/null 2>&1; then

    echo "[FAIL] Invalid AWS credentials."

    exit 1

fi

echo "[PASS] AWS credentials."

##############################################################################
# Validate Repository
##############################################################################

if ! aws ecr describe-repositories \
    --region "${AWS_REGION}" \
    --repository-names "${REPOSITORY_NAME}" \
    >/dev/null 2>&1; then

    echo "[FAIL] Repository '${REPOSITORY_NAME}' does not exist."

    exit 1

fi

echo "[PASS] Repository exists."

##############################################################################
# Validate Image Tag
##############################################################################

if ! aws ecr describe-images \
    --region "${AWS_REGION}" \
    --repository-name "${REPOSITORY_NAME}" \
    --image-ids imageTag="${IMAGE_TAG}" \
    >/dev/null 2>&1; then

    echo "[FAIL] Image tag '${IMAGE_TAG}' does not exist."

    exit 1

fi

echo "[PASS] Image tag exists."

##############################################################################
# Show Image Information
##############################################################################

DIGEST=$(
aws ecr describe-images \
    --region "${AWS_REGION}" \
    --repository-name "${REPOSITORY_NAME}" \
    --image-ids imageTag="${IMAGE_TAG}" \
    --query 'imageDetails[0].imageDigest' \
    --output text
)

PUSHED_AT=$(
aws ecr describe-images \
    --region "${AWS_REGION}" \
    --repository-name "${REPOSITORY_NAME}" \
    --image-ids imageTag="${IMAGE_TAG}" \
    --query 'imageDetails[0].imagePushedAt' \
    --output text
)

echo "Digest   : ${DIGEST}"
echo "PushedAt : ${PUSHED_AT}"

##############################################################################
# Success
##############################################################################

echo "[PASS] Runtime Registry Validation"

exit 0