#!/usr/bin/env bash
# Native tests of the rules, screens and save, then the real wasm build (int is 32 bits there).
# One thread: the tests share package globals.
set -euo pipefail
cd "$(dirname "$0")/.."
ODIN="${ODIN:-odin}"
"$ODIN" test odin -define:ODIN_TEST_THREADS=1 -vet-unused -vet-shadowing
tools/build.sh
