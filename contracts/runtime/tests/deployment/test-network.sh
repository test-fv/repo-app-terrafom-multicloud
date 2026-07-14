#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Network Validation
#
##############################################################################

set -Eeuo pipefail

NETWORK_NAME="application-network"
CONTAINER_NAME="app"

echo
echo "=============================================="
echo "Network Validation"
echo "=============================================="

##############################################################################
# Validate Network Exists
##############################################################################

if ! sudo docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then

    echo "[FAIL] Docker network '${NETWORK_NAME}' does not exist."

    exit 1

fi

echo "[PASS] Network exists."

##############################################################################
# Validate Driver
##############################################################################

DRIVER=$(
sudo docker network inspect \
    --format='{{.Driver}}' \
    "${NETWORK_NAME}"
)

echo "Driver : ${DRIVER}"

if [[ "${DRIVER}" != "bridge" ]]; then

    echo "[FAIL] Network driver is '${DRIVER}'. Expected 'bridge'."

    exit 1

fi

echo "[PASS] Bridge driver."

##############################################################################
# Validate Container Attached
##############################################################################

if ! sudo docker network inspect "${NETWORK_NAME}" \
    --format '{{json .Containers}}' \
    | grep -q "${CONTAINER_NAME}"; then

    echo "[FAIL] Container '${CONTAINER_NAME}' is not attached to '${NETWORK_NAME}'."

    exit 1

fi

echo "[PASS] Container attached."

##############################################################################
# Validate IP Address
##############################################################################

IP=$(
sudo docker inspect \
    --format="{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}" \
    "${CONTAINER_NAME}"
)

echo "Container IP : ${IP}"

if [[ -z "${IP}" ]]; then

    echo "[FAIL] Container has no IP address."

    exit 1

fi

echo "[PASS] Container IP assigned."


##############################################################################
# Validate Internet Connectivity
##############################################################################

if sudo docker exec "${CONTAINER_NAME}" \
    wget -q --spider http://example.com >/dev/null 2>&1; then

    echo "[PASS] Outbound connectivity."

else

    echo "[WARN] Outbound connectivity unavailable."

fi

##############################################################################
# Success
##############################################################################

echo "[PASS] Runtime Network Validation"

exit 0