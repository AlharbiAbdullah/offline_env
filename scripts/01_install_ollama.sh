#!/usr/bin/env bash
# Installs Ollama for local LLM inference on Omarchy / Arch Linux.

set -euo pipefail

echo "=== Installing Ollama ==="

if command -v ollama &>/dev/null; then
    echo "Ollama already installed: $(ollama --version)"
    exit 0
fi

# Prefer the CUDA build when an NVIDIA GPU is present.
if lspci 2>/dev/null | grep -qi nvidia; then
    sudo pacman -S --needed --noconfirm ollama-cuda || sudo pacman -S --needed --noconfirm ollama
else
    sudo pacman -S --needed --noconfirm ollama
fi

echo "Enabling ollama.service..."
sudo systemctl enable --now ollama.service || true

echo ""
ollama --version
echo ""
echo "Ollama installed. It serves models on http://localhost:11434"
echo "Run './08_pull_models.sh' to download models while online."
