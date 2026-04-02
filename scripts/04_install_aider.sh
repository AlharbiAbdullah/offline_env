#!/usr/bin/env bash
# Installs Aider CLI coding agent

set -euo pipefail

echo "=== Installing Aider ==="

if ! command -v python3 &>/dev/null; then
    echo "Python3 not found. Run 07_install_devtools.sh first."
    exit 1
fi

# Use pipx on Ubuntu 24.04+ (PEP 668 externally-managed-environment)
if command -v pipx &>/dev/null; then
    pipx install aider-chat
else
    sudo apt install -y pipx
    pipx ensurepath
    pipx install aider-chat
fi

echo ""
aider --version 2>/dev/null || echo "Restart terminal if aider command not found."

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
