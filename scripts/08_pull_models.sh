#!/usr/bin/env bash
# Downloads Ollama models while online. Run BEFORE going offline.
# Usage: ./08_pull_models.sh [default]

set -euo pipefail

PROFILE="${1:-default}"

echo "=== Pulling Ollama Models (Profile: $PROFILE) ==="

# Check Ollama is running
if ! curl -s http://localhost:11434/api/tags &>/dev/null; then
    echo "Ollama is not running. Start it first:"
    echo "  ollama serve"
    exit 1
fi

case "$PROFILE" in
    default)
        # ASUS ROG Strix G16: 32 GB RAM, RTX 4070 8 GB VRAM
        # Qwen 3.5 only. ~34 GB disk.
        models=(
            "qwen3.5:4b"          # Fast reasoning (3.4 GB)
            "qwen3.5:9b"          # Fast coding (6.6 GB, fits GPU)
            "qwen3.5:35b"         # Best coding + reasoning (24 GB)
            "nomic-embed-text"    # Embeddings (274 MB)
        )
        ;;
    *)
        echo "Unknown profile: $PROFILE"
        echo "Usage: $0 [default]"
        exit 1
        ;;
esac

echo ""
echo "Models to download:"
for model in "${models[@]}"; do
    echo "  - $model"
done
echo ""

for model in "${models[@]}"; do
    echo "Pulling $model..."
    ollama pull "$model"
    echo "  Done."
    echo ""
done

echo "=== Models Downloaded ==="
ollama list
