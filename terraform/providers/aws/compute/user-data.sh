#!/usr/bin/env bash

set -Eeuo pipefail

exec > >(tee /var/log/user-data.log)
exec 2>&1

readonly APP_HOME="/home/ubuntu/app"

echo "========================================"
echo "Provisioning AWS Runtime"
echo "========================================"

export DEBIAN_FRONTEND=noninteractive

##########################################################
# OS
##########################################################

apt-get update -y

apt-get upgrade -y

##########################################################
# Packages
##########################################################

apt-get install -y \
    docker.io \
    curl \
    unzip \
    git \
    jq \
    awscli

##########################################################
# Docker
##########################################################

systemctl enable docker

systemctl restart docker

if ! groups ubuntu | grep -q docker; then
    usermod -aG docker ubuntu
fi

##########################################################
# AWS Systems Manager Agent
##########################################################

if ! snap list amazon-ssm-agent >/dev/null 2>&1; then

    snap install amazon-ssm-agent --classic

fi

systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service

systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service

##########################################################
# Runtime folders
##########################################################

mkdir -p "${APP_HOME}"

mkdir -p "${APP_HOME}/contracts/runtime"

mkdir -p "${APP_HOME}/scripts/runtime/providers"

chown -R ubuntu:ubuntu "${APP_HOME}"

##########################################################
# Diagnostics
##########################################################

echo ""
echo "Docker Version"

docker --version

echo ""
echo "AWS CLI Version"

aws --version

echo ""
echo "SSM Agent"

systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service --no-pager || true

##########################################################
# Cleanup
##########################################################

apt-get clean

##########################################################
# Finish
##########################################################

echo ""
echo "========================================"
echo "Provisioning completed"
echo "========================================"