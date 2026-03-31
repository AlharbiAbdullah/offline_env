#!/usr/bin/env bash
# Installs Ollama for local LLM inference on Ubuntu

set -euo pipefail

echo "=== Installing Ollama ==="

if command -v ollama &>/dev/null; then
    echo "Ollama already installed: $(ollama --version)"
    exit 0
fi

curl -fsSL https://ollama.com/install.sh | sh

echo ""
ollama --version
echo ""
echo "Ollama installed. It serves models on http://localhost:11434"
echo "Run './08_pull_models.sh' to download models while online."
