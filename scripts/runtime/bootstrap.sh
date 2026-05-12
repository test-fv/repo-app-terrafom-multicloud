#!/bin/bash
set -e

echo "Bootstrapping runtime..."

sudo apt-get update

sudo apt-get install -y \
  docker.io \
  curl \
  unzip \
  git

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER

echo "Runtime bootstrap completed"