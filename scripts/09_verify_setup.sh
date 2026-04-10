#!/usr/bin/env bash
# Verifies all offline environment components are installed and working.
# Run BEFORE going offline.

set -uo pipefail

PASSED=0
FAILED=0
WARNINGS=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

check() {
    local name="$1"
    local cmd="$2"
    printf "  %-20s" "$name"
    if output=$(eval "$cmd" 2>&1 | head -1); then
        echo -e "${GREEN}OK${NC} ($output)"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}MISSING${NC}"
        ((FAILED++))
        return 1
    fi
}

echo -e "${CYAN}=== Offline Environment Verification ===${NC}"
echo ""

# Core Tools
echo -e "${YELLOW}Core Tools:${NC}"
check "Git" "git --version"
check "Python" "python3 --version"
check "Node.js" "node --version"
check "Docker" "docker --version"
check "ripgrep" "rg --version"
check "jq" "jq --version"

# AI Tools
echo ""
echo -e "${YELLOW}AI Tools:${NC}"
check "Ollama" "ollama --version"

# Ollama server
printf "  %-20s" "Ollama Server"
if response=$(curl -s http://localhost:11434/api/tags 2>/dev/null); then
    model_count=$(echo "$response" | jq '.models | length' 2>/dev/null || echo 0)
    echo -e "${GREEN}RUNNING${NC} ($model_count models)"
    ((PASSED++))

    if [[ "$model_count" -gt 0 ]]; then
        echo -e "${GRAY}  Models:${NC}"
        echo "$response" | jq -r '.models[] | "    - \(.name) (\(.size / 1073741824 | . * 10 | floor / 10) GB)"' 2>/dev/null
    else
        echo -e "  ${YELLOW}WARNING: No models downloaded. Run 08_pull_models.sh${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}NOT RUNNING${NC} (start with: ollama serve)"
    ((FAILED++))
fi

# Aider
printf "  %-20s" "Aider"
if command -v aider &>/dev/null; then
    ver=$(aider --version 2>&1 | head -1)
    echo -e "${GREEN}OK${NC} ($ver)"
    ((PASSED++))
else
    echo -e "${RED}MISSING${NC} (pip install aider-chat)"
    ((FAILED++))
fi

# OpenCode
printf "  %-20s" "OpenCode"
if command -v opencode &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
    ((PASSED++))
else
    echo -e "${RED}MISSING${NC}"
    ((FAILED++))
fi

# VS Code Extensions
echo ""
echo -e "${YELLOW}VS Code Extensions:${NC}"
if command -v code &>/dev/null; then
    extensions=$(code --list-extensions 2>/dev/null)
    for ext_check in "Continue.continue:Continue.dev" "ms-python.python:Python"; do
        ext_id="${ext_check%%:*}"
        ext_name="${ext_check##*:}"
        printf "  %-20s" "$ext_name"
        if echo "$extensions" | grep -qi "$ext_id"; then
            echo -e "${GREEN}OK${NC}"
            ((PASSED++))
        else
            echo -e "${RED}MISSING${NC}"
            ((FAILED++))
        fi
    done
else
    printf "  %-20s" "VS Code"
    echo -e "${RED}NOT FOUND${NC}"
    ((FAILED++))
fi

# Cache dirs
echo ""
echo -e "${YELLOW}Offline Caches:${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

printf "  %-20s" "Python cache"
if [[ -d "$BASE_DIR/python_cache" ]] && ls "$BASE_DIR/python_cache"/*.whl &>/dev/null 2>&1; then
    count=$(ls "$BASE_DIR/python_cache"/*.whl 2>/dev/null | wc -l)
    echo -e "${GREEN}OK${NC} ($count packages)"
    ((PASSED++))
else
    echo -e "${YELLOW}EMPTY${NC} (run 12_cache_python_packages.sh)"
    ((WARNINGS++))
fi

printf "  %-20s" "Docker cache"
if [[ -d "$BASE_DIR/docker_cache" ]] && ls "$BASE_DIR/docker_cache"/*.tar &>/dev/null 2>&1; then
    count=$(ls "$BASE_DIR/docker_cache"/*.tar 2>/dev/null | wc -l)
    echo -e "${GREEN}OK${NC} ($count images)"
    ((PASSED++))
else
    echo -e "${YELLOW}EMPTY${NC} (run 10_cache_docker_images.sh)"
    ((WARNINGS++))
fi

# Summary
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "  Passed:   ${GREEN}$PASSED${NC}"
FAIL_COLOR="${GREEN}"
[[ $FAILED -gt 0 ]] && FAIL_COLOR="${RED}"
echo -e "  Failed:   ${FAIL_COLOR}$FAILED${NC}"
WARN_COLOR="${GREEN}"
[[ $WARNINGS -gt 0 ]] && WARN_COLOR="${YELLOW}"
echo -e "  Warnings: ${WARN_COLOR}$WARNINGS${NC}"
echo -e "${CYAN}========================================${NC}"

if [[ $FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}You are ready to go offline.${NC}"
else
    echo -e "\n${RED}Fix the failed items before going offline.${NC}"
fi
