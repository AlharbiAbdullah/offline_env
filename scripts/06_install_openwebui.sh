#!/usr/bin/env bash
# Installs Open WebUI (ChatGPT-like interface for Ollama)

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

# Create start script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat >"$SCRIPT_DIR/start_openwebui.sh" <<'EOF'
#!/usr/bin/env bash
# Start Open WebUI (connects to Ollama on host)

# Remove old container if exists
docker rm -f open-webui 2>/dev/null || true

docker run -d \
    --name open-webui \
    --restart always \
    -p 3000:8080 \
    -e OLLAMA_BASE_URL=http://172.17.0.1:11434 \
    -v open-webui:/app/backend/data \
    ghcr.io/open-webui/open-webui:main

echo "Open WebUI starting... (takes ~2 minutes on first run)"
echo "Access at http://localhost:3000"
EOF
chmod +x "$SCRIPT_DIR/start_openwebui.sh"

echo ""
echo "Open WebUI image pulled."
echo "Run './scripts/start_openwebui.sh' to start it."
echo "Access at http://localhost:3000 (wait ~2 minutes on first run)"
