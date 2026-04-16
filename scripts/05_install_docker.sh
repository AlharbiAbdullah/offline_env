#!/usr/bin/env bash
# Installs Docker Engine on Omarchy / Arch Linux.

set -euo pipefail

echo "=== Installing Docker ==="

if command -v docker &>/dev/null; then
    echo "Docker already installed: $(docker --version)"
    echo "Ensuring current user is in docker group..."
    sudo usermod -aG docker "$USER" 2>/dev/null || true
    exit 0
fi

# Install from the extra repo (official Arch package)
sudo pacman -S --needed --noconfirm docker docker-buildx docker-compose

# Enable and start the daemon
sudo systemctl enable --now docker.service

# Add user to docker group (no sudo needed for docker commands)
sudo usermod -aG docker "$USER"

echo ""
docker --version
echo ""
echo "Docker installed. Log out and back in for group changes to take effect."
echo "Pre-pull any images you need before going offline."
