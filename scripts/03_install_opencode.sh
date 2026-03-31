#!/usr/bin/env bash
# Installs OpenCode CLI coding agent

set -euo pipefail

echo "=== Installing OpenCode ==="

if command -v go &>/dev/null; then
    echo "Installing via go install..."
    go install github.com/opencode-ai/opencode@latest
elif command -v curl &>/dev/null; then
    echo "Downloading OpenCode binary..."
    echo "Visit: https://github.com/opencode-ai/opencode/releases/latest"
    echo "Download the Linux amd64 binary and place it in /usr/local/bin/"
else
    echo "Install Go first (script 07) or download manually."
    exit 1
fi

# Copy config
CONFIG_DIR="$HOME/.config/opencode"
mkdir -p "$CONFIG_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/../configs/opencode/opencode.json"

if [[ -f "$CONFIG_SRC" ]]; then
    cp "$CONFIG_SRC" "$CONFIG_DIR/opencode.json"
    echo "OpenCode config copied."
fi

echo ""
echo "OpenCode installed. Run 'opencode' in any project directory."
