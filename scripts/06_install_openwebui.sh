#!/usr/bin/env bash
# Installs and starts Open WebUI (ChatGPT-like interface for Ollama)

set -euo pipefail

echo "=== Installing Open WebUI ==="

if ! command -v docker &>/dev/null; then
    echo "Docker not found. Run 05_install_docker.sh first."
    exit 1
fi

# Ensure Docker is running
sudo systemctl start docker

echo "Pulling Open WebUI image..."
docker pull ghcr.io/open-webui/open-webui:main

# Remove old container if exists
docker rm -f open-webui 2>/dev/null || true

# Start Open WebUI
echo "Starting Open WebUI..."
docker run -d \
    --name open-webui \
    --restart always \
    -p 3000:8080 \
    -e OLLAMA_BASE_URL=http://172.17.0.1:11434 \
    -v open-webui:/app/backend/data \
    ghcr.io/open-webui/open-webui:main

echo ""
echo "Open WebUI starting... (takes ~2 minutes on first run)"
echo "Access at http://localhost:3000"
