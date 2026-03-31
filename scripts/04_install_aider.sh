#!/usr/bin/env bash
# Installs Aider CLI coding agent

set -euo pipefail

echo "=== Installing Aider ==="

if ! command -v python3 &>/dev/null; then
    echo "Python3 not found. Run 07_install_devtools.sh first."
    exit 1
fi

pip install aider-chat

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
echo "  aider --model ollama/qwen2.5-coder:32b"
