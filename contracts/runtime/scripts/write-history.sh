#!/usr/bin/env bash

set -Eeuo pipefail

##############################################################################
# Deployment History
##############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
: "${REGISTRY_SERVER:?}"
: "${REPOSITORY_NAME:?}"
: "${IMAGE_TAG:?}"
: "${AWS_REGION:?}"
: "${RUNTIME_BUCKET_NAME:?}"

STATUS="${1:-SUCCESS}"
ROLLBACK="${2:-false}"

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

YEAR="$(date -u +"%Y")"
MONTH="$(date -u +"%m")"
DAY="$(date -u +"%d")"

INSTANCE_ID=$(
curl -s http://169.254.169.254/latest/meta-data/instance-id || echo "unknown"
)

mkdir -p "${RUNTIME_DIR}/history"

HISTORY_FILE="${RUNTIME_DIR}/history/${IMAGE_TAG}.json"

cat > "${HISTORY_FILE}" <<EOF
{
  "application":"${REPOSITORY_NAME}",
  "provider":"aws",
  "status":"${STATUS}",
  "rollback":${ROLLBACK},
  "image":"${REGISTRY_SERVER}/${REPOSITORY_NAME}:${IMAGE_TAG}",
  "tag":"${IMAGE_TAG}",
  "instance_id":"${INSTANCE_ID}",
  "runtime_version":"1.0.0",
  "timestamp":"${TIMESTAMP}"
}
EOF

aws s3 cp \
    "${HISTORY_FILE}" \
    "s3://${RUNTIME_BUCKET_NAME}/history/${YEAR}/${MONTH}/${DAY}/${IMAGE_TAG}.json"

echo "Deployment history uploaded."