#!/usr/bin/env bash
# Installs OpenCode CLI coding agent on Omarchy / Arch Linux.

set -euo pipefail

echo "=== Installing OpenCode v1.3.17 ==="

# Prerequisites
if ! command -v curl &>/dev/null || ! command -v unzip &>/dev/null; then
    sudo pacman -S --needed --noconfirm curl unzip
fi

# Install via the official installer (distro-agnostic)
curl -fsSL https://opencode.ai/install | bash

# Make sure ~/.local/bin is on PATH for the current session (opencode installs there)
if [[ -d "$HOME/.local/bin" ]]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) : ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
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
echo "If the command is not found, add this to your shell rc:"
echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
