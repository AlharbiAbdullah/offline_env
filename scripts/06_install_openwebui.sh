#!/usr/bin/env bash
# Installs Open WebUI (ChatGPT-like interface for Ollama)

set -euo pipefail

echo "=== Installing Open WebUI ==="

if ! command -v docker &>/dev/null; then
    echo "Docker not found. Run 05_install_docker.sh first."
    exit 1
fi

echo "Pulling Open WebUI image..."
docker pull ghcr.io/open-webui/open-webui:main

# Create start script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat >"$SCRIPT_DIR/start_openwebui.sh" <<'EOF'
#!/usr/bin/env bash
# Start Open WebUI (connects to Ollama on host)
docker run -d \
    --name open-webui \
    --restart always \
    --network host \
    -v open-webui:/app/backend/data \
    -e OLLAMA_BASE_URL=http://localhost:11434 \
    ghcr.io/open-webui/open-webui:main

echo "Open WebUI running at http://localhost:8080"
EOF
chmod +x "$SCRIPT_DIR/start_openwebui.sh"

echo ""
echo "Open WebUI image pulled."
echo "Run './scripts/start_openwebui.sh' to start it."
echo "Access at http://localhost:8080"
