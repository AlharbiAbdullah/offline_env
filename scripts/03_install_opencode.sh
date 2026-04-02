#!/usr/bin/env bash
# Installs OpenCode CLI coding agent

set -euo pipefail

echo "=== Installing OpenCode ==="

# Ensure go/bin is in PATH
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

if command -v go &>/dev/null; then
    echo "Installing via go install..."
    go install github.com/opencode-ai/opencode@latest
    # Ensure go/bin is in shell PATH
    GOPATH_LINE='export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin'
    grep -qxF "$GOPATH_LINE" ~/.zshrc 2>/dev/null || echo "$GOPATH_LINE" >>~/.zshrc
    grep -qxF "$GOPATH_LINE" ~/.bashrc 2>/dev/null || echo "$GOPATH_LINE" >>~/.bashrc
else
    echo "Go not found. Installing OpenCode via install script..."
    curl -fsSL https://raw.githubusercontent.com/opencode-ai/opencode/main/install.sh | bash
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
