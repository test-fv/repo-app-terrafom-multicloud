#!/bin/bash

set -euo pipefail

echo "AWS runtime authentication..."

: "${AWS_REGION:?AWS_REGION is required but not set}"
: "${REGISTRY_URL:?REGISTRY_URL is required but not set}"

echo "Authenticating against: ${REGISTRY_URL}"

aws ecr get-login-password \
  --region "${AWS_REGION}" \
  | docker login \
      --username AWS \
      --password-stdin "${REGISTRY_URL}"

echo "AWS authentication completed."