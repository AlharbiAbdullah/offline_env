#!/usr/bin/env bash
# Installs OpenCode CLI coding agent on Ubuntu or Arch (Omarchy).

set -euo pipefail

echo "=== Installing OpenCode v1.3.17 ==="

# Ensure prerequisites
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

if ! command -v curl &>/dev/null || ! command -v unzip &>/dev/null; then
    if is_arch; then
        sudo pacman -S --needed --noconfirm curl unzip
    else
        sudo apt-get update && sudo apt-get install -y curl unzip
    fi
fi

# Install via the official installer
curl -fsSL https://opencode.ai/install | bash

# Make sure ~/.local/bin is in PATH for the current session (opencode installs there)
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
