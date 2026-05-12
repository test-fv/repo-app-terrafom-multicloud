#!/bin/bash
set -e

echo "AWS runtime authentication..."

aws ecr get-login-password --region $AWS_REGION | docker login \
  --username AWS \
  --password-stdin $REGISTRY_URL