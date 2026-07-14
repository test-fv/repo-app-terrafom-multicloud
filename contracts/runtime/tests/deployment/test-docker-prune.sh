#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Docker Cleanup Validation
#
##############################################################################

set -Eeuo pipefail

echo
echo "=============================================="
echo "Docker Cleanup Validation"
echo "=============================================="

##############################################################################
# Validate Docker
##############################################################################

if ! command -v docker >/dev/null; then

    echo "[FAIL] Docker is not installed."

    exit 1

fi

##############################################################################
# Docker Disk Usage
##############################################################################

echo
echo "Docker Disk Usage"
echo "----------------------------------------------"

sudo docker system df

##############################################################################
# Dangling Images
##############################################################################

DANGLING_IMAGES=$(
sudo docker images \
    -f dangling=true \
    -q | wc -l
)

echo
echo "Dangling Images : ${DANGLING_IMAGES}"

##############################################################################
# Stopped Containers
##############################################################################

STOPPED_CONTAINERS=$(
sudo docker ps \
    -aq \
    -f status=exited | wc -l
)

echo "Stopped Containers : ${STOPPED_CONTAINERS}"

##############################################################################
# Dangling Volumes
##############################################################################

DANGLING_VOLUMES=$(
sudo docker volume ls \
    -qf dangling=true | wc -l
)

echo "Dangling Volumes : ${DANGLING_VOLUMES}"

##############################################################################
# Dangling Networks
##############################################################################

DANGLING_NETWORKS=$(
sudo docker network ls \
    --filter dangling=true \
    -q | wc -l
)

echo "Dangling Networks : ${DANGLING_NETWORKS}"

##############################################################################
# Docker Root Directory
##############################################################################

DOCKER_ROOT=$(
sudo docker info \
    --format '{{.DockerRootDir}}'
)

echo "Docker Root : ${DOCKER_ROOT}"

##############################################################################
# Available Disk Space
##############################################################################

AVAILABLE_SPACE=$(
df -h / | awk 'NR==2 {print $4}'
)

echo "Available Space : ${AVAILABLE_SPACE}"

##############################################################################
# Cleanup Summary
##############################################################################

TOTAL=$(
(
echo "${DANGLING_IMAGES}"
echo "${STOPPED_CONTAINERS}"
echo "${DANGLING_VOLUMES}"
echo "${DANGLING_NETWORKS}"
) | awk '{s+=$1} END{print s}'
)

echo
echo "Potential Cleanup Objects : ${TOTAL}"

##############################################################################
# Recommendations
##############################################################################

if (( DANGLING_IMAGES > 20 )); then
    echo "[WARN] Large number of dangling images (${DANGLING_IMAGES})."
fi

if (( STOPPED_CONTAINERS > 20 )); then
    echo "[WARN] Large number of stopped containers (${STOPPED_CONTAINERS})."
fi

if (( DANGLING_VOLUMES > 10 )); then
    echo "[WARN] Large number of dangling volumes (${DANGLING_VOLUMES})."
fi

if (( DANGLING_NETWORKS > 5 )); then
    echo "[WARN] Large number of dangling networks (${DANGLING_NETWORKS})."
fi

##############################################################################
# Final Status
##############################################################################

if (( TOTAL == 0 )); then

    echo "[PASS] Docker runtime is clean."

else

    echo "[INFO] Docker cleanup is recommended."

fi

##############################################################################
# Success
##############################################################################

echo "[PASS] Docker Cleanup Validation"

exit 0