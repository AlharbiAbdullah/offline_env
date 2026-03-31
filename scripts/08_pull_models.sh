#!/usr/bin/env bash
# Downloads Ollama models while online. Run BEFORE going offline.
# Usage: ./08_pull_models.sh [small|medium|large]

set -euo pipefail

PROFILE="${1:-medium}"

echo "=== Pulling Ollama Models (Profile: $PROFILE) ==="

# Check Ollama is running
if ! curl -s http://localhost:11434/api/tags &>/dev/null; then
    echo "Ollama is not running. Start it first:"
    echo "  ollama serve"
    exit 1
fi

case "$PROFILE" in
    small)
        # 8-16 GB RAM/VRAM
        models=(
            "qwen3.5:9b"          # Coding + general (6.6 GB)
            "qwen3:8b"            # General reasoning (5.2 GB)
            "nomic-embed-text"    # Embeddings (274 MB)
        )
        ;;
    medium)
        # 16-24 GB RAM/VRAM
        models=(
            "qwen3.5:27b"         # Coding + reasoning (17 GB)
            "qwen3:14b"           # General reasoning (9.3 GB)
            "qwen3.5:9b"          # Fast fallback (6.6 GB)
            "nomic-embed-text"    # Embeddings (274 MB)
        )
        ;;
    large)
        # 32+ GB RAM/VRAM
        models=(
            "qwen3-coder:30b"     # Best agentic coding, MoE (19 GB)
            "qwen3.5:27b"         # Coding + reasoning (17 GB)
            "qwen3:30b"           # General reasoning (19 GB)
            "qwen3.5:9b"          # Fast fallback (6.6 GB)
            "nomic-embed-text"    # Embeddings (274 MB)
        )
        ;;
    *)
        echo "Unknown profile: $PROFILE"
        echo "Usage: $0 [small|medium|large]"
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
