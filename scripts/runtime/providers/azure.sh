#!/bin/bash
set -e

echo "Azure runtime authentication..."

echo "$REGISTRY_PASSWORD" | docker login \
  "$REGISTRY_URL" \
  -u "$REGISTRY_USERNAME" \
  --password-stdin