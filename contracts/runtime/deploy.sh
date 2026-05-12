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
  CONTAINER_NAME
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "ERROR: Missing variable $var"
    exit 1
  fi
done

echo "Loading provider runtime..."

PROVIDER_SCRIPT=~/app/scripts/runtime/providers/${CLOUD_PROVIDER}.sh

if [ ! -f "$PROVIDER_SCRIPT" ]; then
  echo "ERROR: Provider runtime script not found"
  exit 1
fi

source $PROVIDER_SCRIPT

echo "Cleaning old docker cache..."

docker image prune -af || true

echo "Pulling image..."

docker pull ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}

echo "Stopping old container..."

docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true

echo "Starting container..."

docker run -d \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  -p 80:8080 \
  ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}

echo "Deployment completed"