#!/usr/bin/env bash
# Load cached Docker images from .tar files. No internet needed.

set -euo pipefail

CACHE_DIR="${1:-./docker_cache}"

echo "=== Loading Docker Images from Cache ==="

if [[ ! -d "$CACHE_DIR" ]]; then
    echo "Cache directory not found: $CACHE_DIR"
    echo "Copy the docker_cache folder from the online machine first."
    exit 1
fi

for tar_file in "$CACHE_DIR"/*.tar; do
    [[ -f "$tar_file" ]] || continue
    echo "Loading $(basename "$tar_file")..."
    docker load -i "$tar_file"
    echo "  Done."
done

echo ""
echo "=== Loaded Images ==="
docker images
