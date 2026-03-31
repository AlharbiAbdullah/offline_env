#!/usr/bin/env bash
# Install Python packages from local cache. No internet needed.

set -euo pipefail

CACHE_DIR="${1:-./python_cache}"
REQ_FILE="${2:-./requirements_offline.txt}"

echo "=== Installing Python Packages from Cache ==="

if [[ ! -d "$CACHE_DIR" ]]; then
    echo "Cache directory not found: $CACHE_DIR"
    exit 1
fi

if [[ ! -f "$REQ_FILE" ]]; then
    echo "Requirements file not found: $REQ_FILE"
    exit 1
fi

pip install \
    --no-index \
    --find-links="$CACHE_DIR" \
    -r "$REQ_FILE"

echo ""
echo "All packages installed from cache."
