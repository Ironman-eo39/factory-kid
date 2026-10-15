#!/bin/bash
# run_render_test.sh — render smoke test runner (TEST_PLAN.md Level 3).
# Runs a Godot render-test script under Xvfb and verifies screenshot output.
# Usage: run_render_test.sh PROJECT_DIR SCRIPT OUT_PNG [--godot-args...]
# Muse then READS the PNG and verifies visuals (not just file existence).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
if [[ $# -lt 3 ]]; then echo "Usage: run_render_test.sh PROJECT_DIR SCRIPT OUT_PNG [--godot-args...]"; exit 2; fi
PROJ="$1"; SCRIPT="$2"; OUT="$3"; shift 3
rm -f "$OUT"
export RENDER_OUT_PNG="$OUT"
"$REPO/tools/xvfb-run-godot.sh" --path "$PROJ" -s "$SCRIPT" --rendering-driver opengl3 "$@" > /tmp/render_test.log 2>&1
if [[ ! -f "$OUT" ]]; then echo "FAIL: no screenshot at $OUT"; tail -20 /tmp/render_test.log; exit 1; fi
echo "PASS: screenshot $OUT ($(stat -c%s "$OUT") bytes)"
