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

# --- Python 3.12 ---
if ! command -v python3.12 &>/dev/null; then
    echo "Installing Python 3.12..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install -y python3.12 python3.12-venv python3.12-dev python3-pip
    # Set as default
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
else
    echo "Python 3.12 already installed."
fi
python3 --version

# --- Node.js 20 LTS ---
if ! command -v node &>/dev/null; then
    echo "Installing Node.js 20 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js already installed."
fi
node --version

# --- Go ---
if ! command -v go &>/dev/null; then
    echo "Installing Go..."
    GO_VERSION="1.22.5"
    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    # Add to PATH (support both bash and zsh)
    GOPATH_LINE='export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin'
    grep -qxF "$GOPATH_LINE" ~/.bashrc 2>/dev/null || echo "$GOPATH_LINE" >>~/.bashrc
    grep -qxF "$GOPATH_LINE" ~/.zshrc 2>/dev/null || echo "$GOPATH_LINE" >>~/.zshrc
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
else
    echo "Go already installed."
fi
go version

# --- uv (fast Python package manager) ---
echo ""
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null || pip install uv

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
