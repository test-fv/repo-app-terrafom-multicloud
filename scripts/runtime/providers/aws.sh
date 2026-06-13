#!/bin/bash
set -e

echo "AWS runtime authentication..."

: "${AWS_REGION:?AWS_REGION is required but not set}"

: "${REGISTRY_URL:?REGISTRY_URL is required but not set}"

aws ecr get-login-password --region "$AWS_REGION" | docker login \
  --username AWS \
  --password-stdin "$REGISTRY_URL"