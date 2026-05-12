#!/bin/bash
set -e

echo "==================================="
echo "Enterprise Multi-Cloud Deployment"
echo "==================================="

required_vars=(
  CLOUD_PROVIDER
  REGISTRY_URL
  IMAGE_NAME
  IMAGE_TAG
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "ERROR: Missing variable $var"
    exit 1
  fi
done

echo "Loading provider runtime..."

source ~/app/scripts/runtime/providers/${CLOUD_PROVIDER}.sh

echo "Pulling image..."

docker pull ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}

echo "Stopping old container..."

docker stop myapp || true
docker rm myapp || true

echo "Starting container..."

docker run -d \
  --name myapp \
  --restart unless-stopped \
  -p 80:8080 \
  ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}

echo "Deployment completed"