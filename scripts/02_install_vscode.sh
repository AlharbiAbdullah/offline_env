#!/usr/bin/env bash
# Installs VS Code and Continue.dev extension on Ubuntu or Arch (Omarchy).

set -euo pipefail

echo "=== Installing VS Code + Continue.dev ==="

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

# ---------------------------------------------------------------
# Install VS Code
# ---------------------------------------------------------------
if ! command -v code &>/dev/null; then
    if is_arch; then
        echo "Installing VS Code on Arch..."
        # Prefer an AUR helper (Omarchy ships yay). Fall back to the OSS code package.
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
        echo "Installing VS Code on Ubuntu..."
        sudo apt-get update
        sudo apt-get install -y wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
        rm -f packages.microsoft.gpg
        sudo apt-get update
        sudo apt-get install -y code
    fi
else
    echo "VS Code already installed."
fi

# ---------------------------------------------------------------
# Install extensions
# ---------------------------------------------------------------
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

# ---------------------------------------------------------------
# Copy Continue.dev config
# ---------------------------------------------------------------
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
