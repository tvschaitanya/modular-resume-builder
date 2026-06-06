#!/usr/bin/env bash
set -e

# ── Check uv ──────────────────────────────────────────────────────────────
if ! command -v uv &> /dev/null; then
    echo "uv not found. Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# ── Sync dependencies ─────────────────────────────────────────────────────
echo "Syncing dependencies..."
uv sync --quiet

# ── Explicitly Activate the Environment ───────────────────────────────────
# This ensures everything downstream runs in the exact same active context
source .venv/bin/activate

# ── Playwright Chromium ───────────────────────────────────────────────────
# We use the active python environment directly here to avoid nested 'uv run' calls
if ! python -c "from playwright.sync_api import sync_playwright; p = sync_playwright().start(); p.stop()" &> /dev/null; then
    echo "Installing Playwright Chromium..."
    playwright install chromium
fi

# ── Build ─────────────────────────────────────────────────────────────────
echo "Building resume..."
python src/build.py

# ── Clean up ──────────────────────────────────────────────────────────────
deactivate
