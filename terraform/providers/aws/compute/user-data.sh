#!/bin/bash
set -e

apt-get update

apt-get install -y \
  docker.io \
  curl \
  unzip \
  git \
  awscli

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu

mkdir -p /home/ubuntu/app/scripts/runtime/providers

chown -R ubuntu:ubuntu /home/ubuntu/app