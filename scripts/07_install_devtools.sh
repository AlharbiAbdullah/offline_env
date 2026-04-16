#!/usr/bin/env bash
# Installs core development tools on Omarchy / Arch Linux.

set -euo pipefail

echo "=== Installing Dev Tools ==="

# Refresh package DB (no full system upgrade — keep Omarchy base intact)
sudo pacman -Sy --noconfirm

echo "Installing build essentials..."
sudo pacman -S --needed --noconfirm base-devel curl wget git unzip

echo ""
echo "Git: $(git --version)"

# Python (Arch ships the latest stable)
if ! command -v python3 &>/dev/null; then
    echo "Installing Python..."
    sudo pacman -S --needed --noconfirm python python-pip python-pipx
else
    echo "Python already installed."
    sudo pacman -S --needed --noconfirm python-pip python-pipx
fi
python3 --version

# Node.js LTS
if ! command -v node &>/dev/null; then
    echo "Installing Node.js LTS..."
    sudo pacman -S --needed --noconfirm nodejs-lts-jod npm 2>/dev/null \
        || sudo pacman -S --needed --noconfirm nodejs npm
else
    echo "Node.js already installed."
fi
node --version

# uv (Astral)
if ! command -v uv &>/dev/null; then
    echo "Installing uv..."
    sudo pacman -S --needed --noconfirm uv 2>/dev/null || {
        # Fallback to upstream tarball if not in repos
        UV_VERSION=0.5.11
        wget -q "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz" -O /tmp/uv.tar.gz
        tar -xzf /tmp/uv.tar.gz -C /tmp
        sudo install -m 0755 /tmp/uv-x86_64-unknown-linux-gnu/uv /usr/local/bin/uv
        sudo install -m 0755 /tmp/uv-x86_64-unknown-linux-gnu/uvx /usr/local/bin/uvx
        rm -rf /tmp/uv.tar.gz /tmp/uv-x86_64-unknown-linux-gnu
    }
else
    echo "uv already installed."
fi
uv --version

# ripgrep, fd, jq
sudo pacman -S --needed --noconfirm ripgrep fd jq

echo ""
echo "Dev tools installed."
