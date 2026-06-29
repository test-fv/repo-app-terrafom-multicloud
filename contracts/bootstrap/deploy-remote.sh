#!/usr/bin/env bash

##############################################################################
#
# Enterprise Remote Bootstrap
#
# Installed once by Terraform / cloud-init.
#
# Responsibilities
#
#   • Download deployment artifact
#   • Verify checksum
#   • Extract runtime
#   • Generate runtime environment
#   • Execute runtime deploy.sh
#
##############################################################################

set -Eeuo pipefail

##############################################################################
# Required Environment
##############################################################################

: "${RUNTIME_BUCKET:?RUNTIME_BUCKET is required}"
: "${CLOUD_PROVIDER:?CLOUD_PROVIDER is required}"
: "${AWS_REGION:?AWS_REGION is required}"
: "${REGISTRY_SERVER:?REGISTRY_SERVER is required}"
: "${REPOSITORY_NAME:?REPOSITORY_NAME is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"

##############################################################################
# Directories
##############################################################################

RUNTIME_HOME="/opt/runtime"

ARTIFACT="/tmp/deployment-artifact.tar.gz"
CHECKSUM