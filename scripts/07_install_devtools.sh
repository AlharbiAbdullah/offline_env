#!/usr/bin/env bash
# Installs core development tools on Ubuntu or Arch (Omarchy).

set -euo pipefail

echo "=== Installing Dev Tools ==="

# --- OS detection ---
if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_ID_LIKE="${ID_LIKE:-}"
else
    OS_ID="unknown"
    OS_ID_LIKE=""
fi

is_arch() {
    [[ "$OS_ID" == "arch" ]] || [[ "$OS_ID_LIKE" == *"arch"* ]] || [[ "$OS_ID" == "omarchy" ]]
}
is_ubuntu() {
    [[ "$OS_ID" == "ubuntu" ]] || [[ "$OS_ID" == "debian" ]] || [[ "$OS_ID_LIKE" == *"debian"* ]]
}

if is_arch; then
    echo "Detected Arch-based system ($OS_ID). Using pacman."
elif is_ubuntu; then
    echo "Detected Debian-based system ($OS_ID). Using apt."
else
    echo "Unsupported OS: $OS_ID. Edit this script for your distro."
    exit 1
fi

# ============================================================
# Arch / Omarchy branch
# ============================================================
if is_arch; then
    # Refresh package DB (no full system upgrade — keep Omarchy base intact)
    sudo pacman -Sy --noconfirm

    echo "Installing build essentials..."
    sudo pacman -S --needed --noconfirm base-devel curl wget git unzip

    echo ""
    echo "Git: $(git --version)"

    # Python (Arch ships the latest stable — 3.12+)
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
    echo "Dev tools installed (Arch)."
    exit 0
fi

# ============================================================
# Ubuntu / Debian branch
# ============================================================
sudo apt-get update

echo "Installing build essentials..."
sudo apt-get install -y build-essential curl wget git unzip software-properties-common

echo ""
echo "Git: $(git --version)"

# Python 3.12 (stock on Ubuntu 24.04 noble, no PPA needed)
if ! command -v python3.12 &>/dev/null; then
    echo "Installing Python 3.12..."
    sudo apt-get install -y python3.12 python3.12-venv python3.12-dev python3-pip
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1
else
    echo "Python 3.12 already installed."
fi
python3 --version

# Node.js 22.22.2 LTS (exact pin)
if ! command -v node &>/dev/null; then
    echo "Installing Node.js 22.22.2 LTS..."
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

# uv 0.5.11 (Astral, exact pin)
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

if ! command -v rg &>/dev/null; then
    sudo apt-get install -y ripgrep
fi

if ! command -v fd &>/dev/null; then
    sudo apt-get install -y fd-find
    mkdir -p ~/.local/bin
    ln -sf "$(which fdfind)" ~/.local/bin/fd 2>/dev/null || true
fi

sudo apt-get install -y jq

echo ""
echo "Dev tools installed (Ubuntu)."
