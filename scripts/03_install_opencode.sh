#!/usr/bin/env bash
# Installs OpenCode CLI coding agent

set -euo pipefail

echo "=== Installing OpenCode ==="

# Remove old version if installed via go
rm -f "$HOME/go/bin/opencode" 2>/dev/null

# Install via official installer
curl -fsSL https://opencode.ai/install | bash

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
