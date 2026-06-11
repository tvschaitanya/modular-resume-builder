#!/usr/bin/env bash
set -e

# --- Parse Arguments ---
CLEAN_FIRST=false
CLEAN_ONLY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--clean)
            CLEAN_FIRST=true
            shift
            ;;
        --clean-only)
            CLEAN_FIRST=true
            CLEAN_ONLY=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-c|--clean] [--clean-only]"
            exit 1
            ;;
    esac
done

# --- Clean Operations ---
if [ "$CLEAN_FIRST" = true ]; then
    if [[ -d output ]]; then
        echo "Cleaning 'output' directory..."
        rm -rf output
        echo "'output' removed."
    else
        echo "'output' does not exist."
    fi
    echo "----------------------------------------"
    
    if [ "$CLEAN_ONLY" = true ]; then
        exit 0
    fi
fi

# --- Check uv ---
if ! command -v uv &> /dev/null; then
    echo "uv not found. Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# --- Sync dependencies ---
echo "Syncing dependencies..."
uv sync --quiet

# --- Wait for venv to be ready ---
echo "Waiting for venv to be ready..."
TIMEOUT=10
ELAPSED=0
until uv run python --version &> /dev/null; do
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Error: venv did not become ready within ${TIMEOUT}s. Aborting."
        exit 1
    fi
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done
echo "venv is ready."

# --- Playwright Chromium ---
if ! uv run python -c "
from playwright.sync_api import sync_playwright
p = sync_playwright().start()
p.stop()
" &> /dev/null; then
    echo "Installing Playwright Chromium..."
    uv run playwright install chromium
fi

# --- Build ---
echo "Building resume..."
uv run python src/build.py