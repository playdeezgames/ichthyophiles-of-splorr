#!/usr/bin/env bash
# Builds the game and remakes assets/screenshots/ (headless Chrome on seeded saves).
set -euo pipefail
cd "$(dirname "$0")/.."
tools/build.sh >/dev/null
python3 tools/make_shots.py
