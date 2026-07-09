#!/usr/bin/env bash

set -Eeuo pipefail

LOCK_FILE="/opt/runtime/deploy.lock"

echo "========================================="
echo "Recovery Test : Deployment Lock"
echo "========================================="

cat > "${LOCK_FILE}" <<EOF
Test Lock
EOF

OUTPUT=$(
bash /opt/runtime/deploy.sh 2>&1 || true
)

rm -f "${LOCK_FILE}"

if echo "${OUTPUT}" | grep -q "Another deployment is already running"; then

    echo "[PASS] Deployment Lock"

    exit 0

fi

echo "[FAIL] Deployment Lock"

exit 1