#!/usr/bin/env bash
# Installs Ollama for local LLM inference on Ubuntu or Arch (Omarchy).

set -euo pipefail

echo "=== Installing Ollama ==="

if command -v ollama &>/dev/null; then
    echo "Ollama already installed: $(ollama --version)"
    exit 0
fi

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

if is_arch; then
    echo "Arch detected. Installing ollama via pacman..."
    # Prefer CUDA build if NVIDIA GPU is present, otherwise ROCm/CPU
    if lspci 2>/dev/null | grep -qi nvidia; then
        sudo pacman -S --needed --noconfirm ollama-cuda || sudo pacman -S --needed --noconfirm ollama
    else
        sudo pacman -S --needed --noconfirm ollama
    fi

    echo "Enabling ollama.service..."
    sudo systemctl enable --now ollama.service || true
else
    # Ubuntu / other: use the official installer
    curl -fsSL https://ollama.com/install.sh | sh
fi

echo ""
ollama --version
echo ""
echo "Ollama installed. It serves models on http://localhost:11434"
echo "Run './08_pull_models.sh' to download models while online."
