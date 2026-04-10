#!/usr/bin/env bash
# Export Docker images to .tar files for offline use.
# Run on a machine WITH internet.

set -euo pipefail

OUTPUT_DIR="${1:-./docker_cache}"
mkdir -p "$OUTPUT_DIR"

echo "=== Caching Docker Images ==="

images=(
    "python:3.12.13-slim"
    "node:22.22.2-slim"
    "postgres:16.6-alpine"
)

for image in "${images[@]}"; do
    echo ""
    echo "Pulling $image..."
    docker pull "$image"

    safe_name=$(echo "$image" | tr '/:' '__')
    tar_file="$OUTPUT_DIR/${safe_name}.tar"

    echo "Exporting to $tar_file..."
    docker save -o "$tar_file" "$image"

    size=$(du -sh "$tar_file" | cut -f1)
    echo "  Saved: $tar_file ($size)"
done

echo ""
echo "=== All images cached in $OUTPUT_DIR ==="
echo "Transfer this folder to the offline machine."
echo "Then run: ./11_load_docker_images.sh"
