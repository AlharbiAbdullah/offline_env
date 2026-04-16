#!/usr/bin/env bash
# Installs VS Code and Continue.dev extension on Omarchy / Arch Linux.

set -euo pipefail

echo "=== Installing VS Code + Continue.dev ==="

# Install VS Code from the AUR (visual-studio-code-bin) via yay.
# Omarchy ships with yay; fall back to paru, then to the OSS `code` package.
if ! command -v code &>/dev/null; then
    if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm visual-studio-code-bin
    elif command -v paru &>/dev/null; then
        paru -S --needed --noconfirm visual-studio-code-bin
    else
        echo "No AUR helper found. Installing OSS 'code' from extra repo instead."
        echo "(Note: the OSS build can't install Microsoft marketplace extensions)"
        sudo pacman -S --needed --noconfirm code
    fi
else
    echo "VS Code already installed."
fi

# Install extensions
echo ""
echo "Installing extensions..."
extensions=(
    "Continue.continue"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "eamodio.gitlens"
    "charliermarsh.ruff"
)

for ext in "${extensions[@]}"; do
    echo "  $ext"
    code --install-extension "$ext" --force 2>/dev/null || true
done

# Copy Continue.dev config
CONTINUE_DIR="$HOME/.continue"
mkdir -p "$CONTINUE_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SRC="$SCRIPT_DIR/../configs/continue/config.json"

if [[ -f "$CONFIG_SRC" ]]; then
    cp "$CONFIG_SRC" "$CONTINUE_DIR/config.json"
    echo ""
    echo "Continue.dev config copied to $CONTINUE_DIR/config.json"
fi

echo ""
echo "VS Code + Continue.dev installed."
echo "Continue.dev connects to Ollama at localhost:11434"
