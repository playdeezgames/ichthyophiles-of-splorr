#!/usr/bin/env bash
# Builds and serves the game at http://localhost:${PORT:-8000}/ (the wasm needs http, not file://).
set -euo pipefail
cd "$(dirname "$0")/.."
tools/build.sh
exec python3 -m http.server "${PORT:-8000}" -d build/web
