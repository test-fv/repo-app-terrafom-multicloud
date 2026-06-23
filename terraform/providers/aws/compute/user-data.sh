#!/bin/bash

set -euo pipefail

readonly APP_HOME="/home/ubuntu/app"

echo "==================================="
echo "Provisioning AWS Runtime"
echo "==================================="

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

apt-get install -y \
  docker.io \
  curl \
  unzip \
  git \
  awscli

systemctl enable docker
systemctl start docker

if ! groups ubuntu | grep -q docker; then
  usermod -aG docker ubuntu
fi

mkdir -p "${APP_HOME}"

chown -R ubuntu:ubuntu "${APP_HOME}"

apt-get clean

echo "==================================="
echo "Provisioning completed"
echo "==================================="