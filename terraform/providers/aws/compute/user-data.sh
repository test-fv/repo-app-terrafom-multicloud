#!/bin/bash

set -Eeuo pipefail

############################################################
# Constants
############################################################

readonly APP_HOME="/opt/runtime"
readonly CW_AGENT_DEB="/tmp/amazon-cloudwatch-agent.deb"
readonly CW_CONFIG="/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"

export DEBIAN_FRONTEND=noninteractive

############################################################
# Logging
############################################################

log() {

    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="

}

log "Provisioning AWS Runtime"

############################################################
# Update OS
############################################################

apt-get update -y

############################################################
# Install Packages
############################################################

log "Installing packages"

apt-get install -y \
    docker.io \
    docker-compose-v2 \
    curl \
    unzip \
    jq \
    awscli

############################################################
# Install CloudWatch Agent
############################################################

log "Installing CloudWatch Agent"

curl -fsSL \
https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb \
-o "$${CW_AGENT_DEB}"

dpkg -i "$${CW_AGENT_DEB}"

rm -f "$${CW_AGENT_DEB}"

############################################################
# CloudWatch Configuration
############################################################

log "Configuring CloudWatch Agent"

mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

cat > "$${CW_CONFIG}" <<'EOF'
${cloudwatch_config}
EOF

############################################################
# Docker
############################################################

log "Configuring Docker"

systemctl enable docker
systemctl restart docker

############################################################
# CloudWatch Service
############################################################

systemctl enable amazon-cloudwatch-agent || true

############################################################
# Docker Permissions
############################################################

if ! groups ubuntu | grep -q docker; then
    usermod -aG docker ubuntu
fi

############################################################
# Runtime Folder
############################################################

log "Preparing runtime folder"

mkdir -p "$${APP_HOME}"

mkdir -p /usr/local/bin

############################################################
# Deploy Launcher
############################################################

cat >/usr/local/bin/deploy.sh <<'EOF'
#!/bin/bash

set -Eeuo pipefail

export APP_HOME="/opt/runtime"

exec /opt/runtime/deploy.sh
EOF

chmod +x /usr/local/bin/deploy.sh

############################################################
# Validation
############################################################

log "Installed versions"

docker --version
docker compose version
aws --version

############################################################
# Ownership
############################################################

chown -R ubuntu:ubuntu "$${APP_HOME}"

############################################################
# Start CloudWatch Agent
############################################################

log "Starting CloudWatch Agent"

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:"$${CW_CONFIG}" \
    -s

############################################################
# Cleanup
############################################################

log "Cleaning system"

apt-get clean

############################################################
# Finished
############################################################

log "Provisioning completed successfully"