#!/usr/bin/env bash
# Run this on ANY online machine to prepare a USB drive for the air-gapped laptop.
# Usage:
#   ./usb_prepare.sh /media/usb python requests httpx
#   ./usb_prepare.sh /media/usb ollama qwen3.5:9b
#   ./usb_prepare.sh /media/usb docker postgres:16-alpine
#   ./usb_prepare.sh /media/usb all              # refreshes everything

set -euo pipefail

USB_PATH="${1:?Usage: $0 /path/to/usb <type> <packages...>}"
TYPE="${2:?Specify type: python, ollama, docker, vscode, all}"
shift 2
PACKAGES=("$@")

# Create USB directory structure
mkdir -p "$USB_PATH/offline_env"/{python,ollama,docker,vscode}

# ─── Python packages ───
prepare_python() {
    local dest="$USB_PATH/offline_env/python"
    if [[ ${#PACKAGES[@]} -eq 0 ]]; then
        echo "Specify packages: $0 /path/to/usb python requests httpx pandas"
        exit 1
    fi

    echo "=== Downloading Python packages ==="
    for pkg in "${PACKAGES[@]}"; do
        echo "  Downloading $pkg and dependencies..."
        pip download "$pkg" \
            --dest "$dest" \
            --platform manylinux2014_x86_64 \
            --platform linux_x86_64 \
            --python-version 3.12 \
            --only-binary=:all: 2>&1 || \
        pip download "$pkg" --dest "$dest" 2>&1 || true
    done

    count=$(find "$dest" -name "*.whl" -o -name "*.tar.gz" 2>/dev/null | wc -l)
    echo "  $count package files in $dest"
}

# ─── Ollama models ───
prepare_ollama() {
    local dest="$USB_PATH/offline_env/ollama"
    if [[ ${#PACKAGES[@]} -eq 0 ]]; then
        echo "Specify models: $0 /path/to/usb ollama qwen3.5:9b qwen3-coder:30b"
        exit 1
    fi

    if ! command -v ollama &>/dev/null; then
        echo "Ollama not installed on this machine."
        echo "Install it first: curl -fsSL https://ollama.com/install.sh | sh"
        exit 1
    fi

    echo "=== Downloading Ollama models ==="
    for model in "${PACKAGES[@]}"; do
        echo "  Pulling $model..."
        ollama pull "$model"
    done

    # Copy the entire models directory
    echo "  Copying model files to USB..."
    OLLAMA_DIR="${OLLAMA_MODELS:-$HOME/.ollama/models}"
    if [[ -d "$OLLAMA_DIR" ]]; then
        cp -r "$OLLAMA_DIR" "$dest/models"
        size=$(du -sh "$dest/models" | cut -f1)
        echo "  Copied $size to $dest/models"
    else
        echo "  ERROR: Ollama models directory not found at $OLLAMA_DIR"
        exit 1
    fi
}

# ─── Docker images ───
prepare_docker() {
    local dest="$USB_PATH/offline_env/docker"
    if [[ ${#PACKAGES[@]} -eq 0 ]]; then
        echo "Specify images: $0 /path/to/usb docker postgres:16-alpine redis:7-alpine"
        exit 1
    fi

    echo "=== Downloading Docker images ==="
    for image in "${PACKAGES[@]}"; do
        echo "  Pulling $image..."
        docker pull "$image"

        safe_name=$(echo "$image" | tr '/:' '__')
        tar_file="$dest/${safe_name}.tar"

        echo "  Saving to $tar_file..."
        docker save -o "$tar_file" "$image"

        size=$(du -sh "$tar_file" | cut -f1)
        echo "  Saved: $size"
    done
}

# ─── VS Code extensions ───
prepare_vscode() {
    local dest="$USB_PATH/offline_env/vscode"
    if [[ ${#PACKAGES[@]} -eq 0 ]]; then
        echo "Specify extensions: $0 /path/to/usb vscode ms-python.python charliermarsh.ruff"
        exit 1
    fi

    echo "=== Downloading VS Code extensions ==="
    for ext in "${PACKAGES[@]}"; do
        echo "  Downloading $ext..."
        # Download .vsix from marketplace
        publisher="${ext%%.*}"
        name="${ext#*.}"
        url="https://${publisher}.gallery.vsassets.io/_apis/public/gallery/publisher/${publisher}/extension/${name}/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
        curl -fsSL "$url" -o "$dest/${ext}.vsix" 2>/dev/null && \
            echo "  Saved ${ext}.vsix" || \
            echo "  Failed. Try: code --install-extension $ext on an online machine, then copy from ~/.vscode/extensions/"
    done
}

# ─── Run ───
case "$TYPE" in
    python) prepare_python ;;
    ollama) prepare_ollama ;;
    docker) prepare_docker ;;
    vscode) prepare_vscode ;;
    all)
        echo "=== Preparing full USB refresh ==="
        echo "Use specific commands for each type."
        echo ""
        echo "Examples:"
        echo "  $0 /media/usb python requests pandas numpy"
        echo "  $0 /media/usb ollama qwen3.5:9b qwen3-coder:30b"
        echo "  $0 /media/usb docker postgres:16-alpine"
        echo "  $0 /media/usb vscode ms-python.python"
        ;;
    *)
        echo "Unknown type: $TYPE"
        echo "Valid types: python, ollama, docker, vscode, all"
        exit 1
        ;;
esac

echo ""
echo "=== USB ready at $USB_PATH/offline_env ==="
echo "Plug into the air-gapped laptop and run: ./usb_install.sh /media/usb"
