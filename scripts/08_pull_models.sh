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
        # 8-16 GB RAM, 6-8 GB VRAM
        models=(
            "qwen2.5-coder:7b"
            "llama3.1:8b"
            "nomic-embed-text"
        )
        ;;
    medium)
        # 16-32 GB RAM, 8-12 GB VRAM
        models=(
            "qwen2.5-coder:14b"
            "qwen2.5:14b"
            "nomic-embed-text"
            "llama3.1:8b"
        )
        ;;
    large)
        # 32+ GB RAM, 16+ GB VRAM
        models=(
            "qwen2.5-coder:32b"
            "qwen2.5:32b"
            "nomic-embed-text"
            "qwen2.5-coder:7b"
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
