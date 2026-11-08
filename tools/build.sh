#!/usr/bin/env bash
# Builds the browser game into build/web. Pass --size for the shipping build.
set -euo pipefail
cd "$(dirname "$0")/.."
ODIN="${ODIN:-odin}"
opt=speed
[[ "${1:-}" == "--size" ]] && opt=size
rm -rf build/web
mkdir -p build/web
"$ODIN" build odin -target:js_wasm32 -out:build/web/game.wasm -o:$opt -vet-unused -vet-shadowing
cp "$("$ODIN" root)/core/sys/wasm/js/odin.js" build/web/
cp web/index.html web/lootlocker.js build/web/
echo "built build/web ($opt)"
