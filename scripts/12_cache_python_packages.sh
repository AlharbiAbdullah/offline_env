#!/usr/bin/env bash
# Downloads Python packages as wheel files for offline installation.
# Run on a machine WITH internet.

set -euo pipefail

OUTPUT_DIR="${1:-./python_cache}"
REQ_FILE="${2:-./requirements_offline.txt}"

echo "=== Caching Python Packages ==="

mkdir -p "$OUTPUT_DIR"

if [[ ! -f "$REQ_FILE" ]]; then
    echo "Requirements file not found: $REQ_FILE"
    echo "Edit requirements_offline.txt with your packages first."
    exit 1
fi

# Download wheels for Linux x86_64
echo "Downloading packages for Linux (x86_64)..."
pip download \
    -r "$REQ_FILE" \
    --dest "$OUTPUT_DIR" \
    --platform manylinux2014_x86_64 \
    --platform linux_x86_64 \
    --python-version 3.12 \
    --only-binary=:all: \
    2>&1 || true

# Fallback: grab source for anything that didn't have a wheel
echo ""
echo "Downloading any remaining packages (source fallback)..."
pip download \
    -r "$REQ_FILE" \
    --dest "$OUTPUT_DIR" \
    2>&1 || true

count=$(find "$OUTPUT_DIR" -name "*.whl" -o -name "*.tar.gz" | wc -l)
size=$(du -sh "$OUTPUT_DIR" | cut -f1)

echo ""
echo "=== Cached $count packages ($size) in $OUTPUT_DIR ==="
echo "Transfer this folder to the offline machine."
echo "Then run: ./13_install_from_cache.sh"
