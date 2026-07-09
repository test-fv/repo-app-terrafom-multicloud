#!/usr/bin/env bash

##############################################################################
#
# Enterprise Runtime
# Runtime Status
#
##############################################################################

set -Eeuo pipefail

RUNTIME_DIR="/opt/runtime"

VERSION_FILE="${RUNTIME_DIR}/runtime.version"
DEPLOY_FILE="${RUNTIME_DIR}/version.json"

line() {
    echo "=================================================="
}

section() {
    echo
    line
    echo "$1"
    line
}

value() {
    printf "%-22s %s\n" "$1" "$2"
}

section "Enterprise Runtime Status"

##############################################################################
# Runtime Version
##############################################################################

if [[ -f "${VERSION_FILE}" ]]; then
    value "Runtime Version" "$(cat "${VERSION_FILE}")"
else
    value "Runtime Version" "unknown"
fi

##############################################################################
# Deployment Information
##############################################################################

section "Deployment"

if [[ -f "${DEPLOY_FILE}" ]]; then

    value "Application"  "$(jq -r '.application' "${DEPLOY_FILE}")"
    value "Provider"     "$(jq -r '.provider' "${DEPLOY_FILE}")"
    value "Image Tag"    "$(jq -r '.tag' "${DEPLOY_FILE}")"
    value "Image"        "$(jq -r '.image' "${DEPLOY_FILE}")"
    value "Deployed At"  "$(jq -r '.deployed_at' "${DEPLOY_FILE}")"

else

    value "Deployment" "No deployment metadata"

fi

##############################################################################
# Docker
##############################################################################

section "Docker"

if systemctl is-active --quiet docker; then
    value "Docker Service" "Running"
else
    value "Docker Service" "Stopped"
fi

if docker ps --format '{{.Names}}' | grep -q '^app$'; then

    value "Container" "Running"

    HEALTH=$(docker inspect \
        --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}N/A{{end}}' \
        app)

    STATUS=$(docker inspect \
        --format='{{.State.Status}}' \
        app)

    IMAGE=$(docker inspect \
        --format='{{.Config.Image}}' \
        app)

    STARTED=$(docker inspect \
        --format='{{.State.StartedAt}}' \
        app)

    value "Status" "${STATUS}"
    value "Health" "${HEALTH}"
    value "Image" "${IMAGE}"
    value "Started" "${STARTED}"

else

    value "Container" "Not Running"

fi

##############################################################################
# CloudWatch
##############################################################################

section "CloudWatch Agent"

if systemctl is-active --quiet amazon-cloudwatch-agent; then
    value "Agent" "Running"
else
    value "Agent" "Stopped"
fi

##############################################################################
# System
##############################################################################

section "System"

value "Hostname" "$(hostname)"

value "Disk Usage" \
"$(df -h / | awk 'NR==2 {print $5}')"

value "Memory Usage" \
"$(free -h | awk '/Mem:/ {print $3 "/" $2}')"

value "Load Average" \
"$(uptime | awk -F'load average:' '{print $2}')"

##############################################################################
# Finished
##############################################################################

line

exit 0