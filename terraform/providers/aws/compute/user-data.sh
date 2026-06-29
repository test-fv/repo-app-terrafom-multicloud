#!/bin/bash

set -euo pipefail

#########################################
# Constants
#########################################

readonly APP_HOME="/opt/app-runtime"

echo "==================================="
echo "Provisioning AWS Runtime"
echo "==================================="

export DEBIAN_FRONTEND=noninteractive

#########################################
# Packages
#########################################

apt-get update -y

apt-get install -y \
    docker.io \
    curl \
    unzip \
    awscli

#########################################
# Docker
#########################################

systemctl enable docker
systemctl start docker

if ! groups ubuntu | grep -q docker; then
    usermod -aG docker ubuntu
fi

#########################################
# Runtime folders
#########################################

mkdir -p "$${APP_HOME}"
mkdir -p /usr/local/bin

#########################################
# Deploy Runtime
#########################################

cat > /usr/local/bin/deploy.sh <<'EOF'
#!/bin/bash

export APP_HOME="/opt/app-runtime"

/opt/app-runtime/deploy.sh
EOF

chmod +x /usr/local/bin/deploy.sh

#########################################
# Ownership
#########################################

chown -R ubuntu:ubuntu "$${APP_HOME}"

#########################################
# Cleanup
#########################################

apt-get clean

echo "==================================="
echo "Provisioning completed"
echo "==================================="