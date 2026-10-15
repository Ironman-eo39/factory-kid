#!/bin/bash
# Run a Godot command under Xvfb for headless rendering on jarvish.
# Xvfb binary: ~/tools/xvfb-env/bin/Xvfb (extracted from the Arch
# xorg-server-xvfb package — no sudo needed). Godot renders with
# llvmpipe software GL (LIBGL_ALWAYS_SOFTWARE=1).
# Usage: xvfb-run-godot.sh [godot args...]
set -euo pipefail
XVFB="$HOME/tools/xvfb-env/bin/Xvfb"
GODOT="$HOME/tools/godot-4.6/Godot_v4.6-stable_linux.x86_64"
DISP=":99"
"$XVFB" "$DISP" -screen 0 1280x1024x24 > /tmp/xvfb-99.log 2>&1 &
XVFB_PID=$!
trap 'kill $XVFB_PID 2>/dev/null || true' EXIT
sleep 2
DISPLAY="$DISP" LIBGL_ALWAYS_SOFTWARE=1 "$GODOT" "$@"
