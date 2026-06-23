#!/bin/bash

set -euo pipefail

echo "Azure runtime authentication..."

: "${REGISTRY_URL:?REGISTRY_URL is required but not set}"
: "${REGISTRY_USERNAME:?REGISTRY_USERNAME is required but not set}"
: "${REGISTRY_PASSWORD:?REGISTRY_PASSWORD is required but not set}"

echo "Authenticating against: ${REGISTRY_URL}"

echo "${REGISTRY_PASSWORD}" | docker login \
  "${REGISTRY_URL}" \
  --username "${REGISTRY_USERNAME}" \
  --password-stdin

echo "Azure authentication completed."