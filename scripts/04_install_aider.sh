#!/usr/bin/env bash
# Installs Aider CLI coding agent on Ubuntu or Arch (Omarchy).

set -euo pipefail

echo "=== Installing Aider ==="

if ! command -v python3 &>/dev/null; then
    echo "Python3 not found. Run 07_install_devtools.sh first."
    exit 1
fi

# Detect OS
OS_ID="unknown"
OS_ID_LIKE=""
if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_ID_LIKE="${ID_LIKE:-}"
fi

is_arch() {
    [[ "$OS_ID" == "arch" ]] || [[ "$OS_ID_LIKE" == *"arch"* ]] || [[ "$OS_ID" == "omarchy" ]]
}

# Ensure pipx is available (PEP 668 externally-managed-environment on both distros)
if ! command -v pipx &>/dev/null; then
    if is_arch; then
        sudo pacman -S --needed --noconfirm python-pipx
    else
        sudo apt install -y pipx
    fi
    pipx ensurepath
fi

# Install aider
pipx install aider-chat --force

# Make sure ~/.local/bin is on PATH for the current session
if [[ -d "$HOME/.local/bin" ]]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) : ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
fi

echo ""
aider --version 2>/dev/null || echo "Restart terminal if 'aider' command not found (pipx ensurepath needs a new shell)."

# Copy config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/../configs/aider/.aider.conf.yml"

if [[ -f "$CONFIG_SRC" ]]; then
    cp "$CONFIG_SRC" "$HOME/.aider.conf.yml"
    echo "Aider config copied to ~/.aider.conf.yml"
fi

echo ""
echo "Usage: cd into a project, then run:"
echo "  aider --model ollama/qwen3.5:27b"
