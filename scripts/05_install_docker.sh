#!/usr/bin/env bash
# Installs Docker Engine on Ubuntu (not Docker Desktop)

set -euo pipefail

echo "=== Installing Docker ==="

if command -v docker &>/dev/null; then
    echo "Docker already installed: $(docker --version)"
    echo "Ensuring current user is in docker group..."
    sudo usermod -aG docker "$USER" 2>/dev/null || true
    exit 0
fi

# Remove old versions
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Install prerequisites
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group (no sudo needed for docker commands)
sudo usermod -aG docker "$USER"

echo ""
docker --version
echo ""
echo "Docker installed. Log out and back in for group changes to take effect."
echo "Pre-pull any images you need before going offline."
