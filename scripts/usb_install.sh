#!/usr/bin/env bash
# Run this on the AIR-GAPPED laptop to install from USB.
# Usage:
#   ./usb_install.sh /media/usb python
#   ./usb_install.sh /media/usb ollama
#   ./usb_install.sh /media/usb docker
#   ./usb_install.sh /media/usb vscode
#   ./usb_install.sh /media/usb all

set -euo pipefail

USB_PATH="${1:?Usage: $0 /path/to/usb <type>}"
TYPE="${2:-all}"

USB_ENV="$USB_PATH/offline_env"

if [[ ! -d "$USB_ENV" ]]; then
    echo "No offline_env directory found on USB at $USB_ENV"
    exit 1
fi

# ─── Python packages ───
install_python() {
    local src="$USB_ENV/python"
    if [[ ! -d "$src" ]] || ! ls "$src"/*.whl &>/dev/null 2>&1; then
        echo "No Python packages found on USB."
        return
    fi

    count=$(find "$src" -name "*.whl" -o -name "*.tar.gz" | wc -l)
    echo "=== Installing $count Python packages from USB ==="

    pip install --no-index --find-links="$src" "$src"/*.whl 2>&1 || \
    pip install --no-index --find-links="$src" "$src"/*.tar.gz 2>&1 || true

    # Also copy to local cache for future use
    LOCAL_CACHE="./python_cache"
    if [[ -d "$LOCAL_CACHE" ]]; then
        echo "  Copying to local cache..."
        cp -n "$src"/* "$LOCAL_CACHE/" 2>/dev/null || true
    fi

    echo "  Done."
}

# ─── Ollama models ───
install_ollama() {
    local src="$USB_ENV/ollama/models"
    if [[ ! -d "$src" ]]; then
        echo "No Ollama models found on USB."
        return
    fi

    echo "=== Installing Ollama models from USB ==="

    OLLAMA_DIR="${OLLAMA_MODELS:-$HOME/.ollama/models}"
    mkdir -p "$OLLAMA_DIR"

    echo "  Copying models to $OLLAMA_DIR..."
    cp -r "$src"/* "$OLLAMA_DIR/" 2>/dev/null || \
    rsync -a "$src/" "$OLLAMA_DIR/"

    size=$(du -sh "$OLLAMA_DIR" | cut -f1)
    echo "  Total models directory: $size"

    # Verify
    if command -v ollama &>/dev/null; then
        echo "  Available models:"
        ollama list
    fi

    echo "  Done."
}

# ─── Docker images ───
install_docker() {
    local src="$USB_ENV/docker"
    if [[ ! -d "$src" ]] || ! ls "$src"/*.tar &>/dev/null 2>&1; then
        echo "No Docker images found on USB."
        return
    fi

    echo "=== Loading Docker images from USB ==="
    for tar_file in "$src"/*.tar; do
        [[ -f "$tar_file" ]] || continue
        echo "  Loading $(basename "$tar_file")..."
        docker load -i "$tar_file"
    done

    echo "  Done."
    docker images
}

# ─── VS Code extensions ───
install_vscode() {
    local src="$USB_ENV/vscode"
    if [[ ! -d "$src" ]] || ! ls "$src"/*.vsix &>/dev/null 2>&1; then
        echo "No VS Code extensions found on USB."
        return
    fi

    echo "=== Installing VS Code extensions from USB ==="
    for vsix in "$src"/*.vsix; do
        [[ -f "$vsix" ]] || continue
        echo "  Installing $(basename "$vsix")..."
        code --install-extension "$vsix" --force 2>/dev/null || true
    done
    echo "  Done."
}

# ─── Run ───
case "$TYPE" in
    python) install_python ;;
    ollama) install_ollama ;;
    docker) install_docker ;;
    vscode) install_vscode ;;
    all)
        install_python
        echo ""
        install_ollama
        echo ""
        install_docker
        echo ""
        install_vscode
        ;;
    *)
        echo "Unknown type: $TYPE"
        echo "Valid types: python, ollama, docker, vscode, all"
        exit 1
        ;;
esac

echo ""
echo "=== USB install complete ==="
