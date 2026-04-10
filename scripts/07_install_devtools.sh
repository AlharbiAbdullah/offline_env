#!/usr/bin/env bash
# Installs core development tools on Ubuntu

set -euo pipefail

echo "=== Installing Dev Tools ==="

sudo apt-get update

# --- Build essentials ---
echo "Installing build essentials..."
sudo apt-get install -y build-essential curl wget git unzip software-properties-common

# --- Git ---
echo ""
echo "Git: $(git --version)"

# --- Python 3.12 (stock on Ubuntu 24.04 noble, no PPA needed) ---
if ! command -v python3.12 &>/dev/null; then
    echo "Installing Python 3.12..."
    sudo apt-get install -y python3.12 python3.12-venv python3.12-dev python3-pip
    # Set as default
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
else
    echo "Python 3.12 already installed."
fi
python3 --version

# --- Node.js 22.22.2 LTS (exact pin) ---
if ! command -v node &>/dev/null; then
    echo "Installing Node.js 22.22.2 LTS..."
    # Manual NodeSource apt repo setup (no curl|bash bootstrap).
    # node_22.x is the literal NodeSource family directory; exact patch pinned below.
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | \
        sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | \
        sudo tee /etc/apt/sources.list.d/nodesource.list
    sudo apt-get update
    sudo apt-get install -y nodejs=22.22.2-1nodesource1
    sudo apt-mark hold nodejs
else
    echo "Node.js already installed."
fi
node --version

# --- uv 0.5.11 (Astral, exact pin) ---
if ! command -v uv &>/dev/null; then
    echo "Installing uv 0.5.11..."
    UV_VERSION=0.5.11
    wget -q "https://github.com/astral-sh/uv/releases/download/${UV_VERSION}/uv-x86_64-unknown-linux-gnu.tar.gz" -O /tmp/uv.tar.gz
    tar -xzf /tmp/uv.tar.gz -C /tmp
    sudo install -m 0755 /tmp/uv-x86_64-unknown-linux-gnu/uv /usr/local/bin/uv
    sudo install -m 0755 /tmp/uv-x86_64-unknown-linux-gnu/uvx /usr/local/bin/uvx
    rm -rf /tmp/uv.tar.gz /tmp/uv-x86_64-unknown-linux-gnu
else
    echo "uv already installed."
fi
uv --version

# --- ripgrep ---
if ! command -v rg &>/dev/null; then
    sudo apt-get install -y ripgrep
fi

# --- fd (better find) ---
if ! command -v fd &>/dev/null; then
    sudo apt-get install -y fd-find
    # Ubuntu names it fdfind, alias it
    mkdir -p ~/.local/bin
    ln -sf "$(which fdfind)" ~/.local/bin/fd 2>/dev/null || true
fi

# --- jq ---
sudo apt-get install -y jq

echo ""
echo "Dev tools installed."
