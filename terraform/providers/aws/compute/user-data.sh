#!/bin/bash

set -Eeuo pipefail

#########################################
# Constants
#########################################

readonly APP_HOME="/opt/app-runtime"

echo "==================================="
echo "Provisioning AWS Runtime"
echo "==================================="

export DEBIAN_FRONTEND=noninteractive

#########################################
# Update OS
#########################################

apt-get update -y

#########################################
# Install Packages
#########################################

apt-get install -y \
    docker.io \
    docker-compose-v2 \
    curl \
    unzip \
    jq \
    awscli

#########################################
# Docker
#########################################

systemctl enable docker
systemctl restart docker

#########################################
# Add Ubuntu User
#########################################

if ! groups ubuntu | grep -q docker; then
    usermod -aG docker ubuntu
fi

#########################################
# Runtime folders
#########################################

mkdir -p "${APP_HOME}"

mkdir -p /usr/local/bin

#########################################
# Runtime launcher
#########################################

cat >/usr/local/bin/deploy.sh <<'EOF'
#!/bin/bash

set -Eeuo pipefail

export APP_HOME="/opt/app-runtime"

exec /opt/app-runtime/deploy.sh
EOF

chmod +x /usr/local/bin/deploy.sh

#########################################
# Validate Installation
#########################################

echo "==================================="
echo "Installed versions"
echo "==================================="

docker --version

docker compose version

aws --version

#########################################
# Ownership
#########################################

chown -R ubuntu:ubuntu "${APP_HOME}"

#########################################
# Cleanup
#########################################

apt-get clean

#########################################
# Finished
#########################################

echo "==================================="
echo "Provisioning completed successfully"
echo "==================================="