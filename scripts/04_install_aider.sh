#!/usr/bin/env bash
# Installs Aider CLI coding agent on Omarchy / Arch Linux.

set -euo pipefail

echo "=== Installing Aider ==="

if ! command -v python3 &>/dev/null; then
    echo "Python3 not found. Run 07_install_devtools.sh first."
    exit 1
fi

# Ensure pipx is available (PEP 668 externally-managed-environment)
if ! command -v pipx &>/dev/null; then
    sudo pacman -S --needed --noconfirm python-pipx
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
