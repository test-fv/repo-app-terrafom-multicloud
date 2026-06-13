#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo "AWS REMOTE DEPLOY"
echo "========================================"

echo "REGISTRY_URL=${REGISTRY_URL}"
echo "IMAGE_NAME=${IMAGE_NAME}"
echo "IMAGE_TAG=${IMAGE_TAG}"
echo ""

IMAGE="${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "Image:"
echo "${IMAGE}"
echo ""

echo "Logging into ECR..."

aws ecr get-login-password \
    --region "${AWS_REGION}" \
| docker login \
    --username AWS \
    --password-stdin \
    "${REGISTRY_URL}"

echo ""
echo "Pulling latest image..."

docker pull "${IMAGE}"

echo ""
echo "Stopping previous container..."

docker stop "${CONTAINER_NAME}" || true

docker rm "${CONTAINER_NAME}" || true

echo ""
echo "Starting container..."

docker run \
    -d \
    --restart unless-stopped \
    --name "${CONTAINER_NAME}" \
    -p 80:8080 \
    "${IMAGE}"

echo ""
echo "========================================"
echo "DEPLOY FINISHED"
echo "========================================"
