#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime Validation
# Disk Space Validation
#
##############################################################################

set -Eeuo pipefail

##############################################################################
# Thresholds
##############################################################################

MAX_DISK_USAGE=90
MAX_INODES_USAGE=90

echo
echo "=============================================="
echo "Disk Space Validation"
echo "=============================================="

##############################################################################
# Root Filesystem
##############################################################################

DISK_USAGE=$(
df -P / | awk 'NR==2 {gsub("%",""); print $5}'
)

echo "Disk Usage : ${DISK_USAGE}%"

if (( DISK_USAGE >= MAX_DISK_USAGE )); then

    echo "[FAIL] Disk usage exceeds ${MAX_DISK_USAGE}%."

    exit 1

fi

echo "[PASS] Disk usage."

##############################################################################
# Inodes
##############################################################################

INODES_USAGE=$(
df -Pi / | awk 'NR==2 {gsub("%",""); print $5}'
)

echo "Inodes Usage : ${INODES_USAGE}%"

if (( INODES_USAGE >= MAX_INODES_USAGE )); then

    echo "[FAIL] Inodes usage exceeds ${MAX_INODES_USAGE}%."

    exit 1

fi

echo "[PASS] Inodes usage."

##############################################################################
# Docker Disk Usage
##############################################################################

echo
echo "Docker Disk Usage"

sudo docker system df

##############################################################################
# Dangling Images
##############################################################################

DANGLING_IMAGES=$(
sudo docker images -f dangling=true -q | wc -l
)

echo "Dangling Images : ${DANGLING_IMAGES}"

##############################################################################
# Stopped Containers
##############################################################################

STOPPED_CONTAINERS=$(
sudo docker ps -aq -f status=exited | wc -l
)

echo "Stopped Containers : ${STOPPED_CONTAINERS}"

##############################################################################
# Dangling Volumes
##############################################################################

DANGLING_VOLUMES=$(
sudo docker volume ls -qf dangling=true | wc -l
)

echo "Dangling Volumes : ${DANGLING_VOLUMES}"

##############################################################################
# Docker Root Directory
##############################################################################

DOCKER_ROOT=$(
sudo docker info --format '{{.DockerRootDir}}'
)

echo "Docker Root : ${DOCKER_ROOT}"

##############################################################################
# Filesystem Available
##############################################################################

AVAILABLE=$(
df -h / | awk 'NR==2 {print $4}'
)

echo "Available Space : ${AVAILABLE}"

##############################################################################
# Success
##############################################################################

echo "[PASS] Runtime Disk Validation"

exit 0