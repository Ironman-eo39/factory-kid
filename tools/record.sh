#!/bin/bash
# record.sh — SKELETON (full wiring in TASK-109).
# Records one scenario preset via Godot Movie Maker under Xvfb, then
# transcodes to a finished MP4.
# Usage: record.sh [--dry-run] [--help] preset.json
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

usage() {
  echo "Usage: record.sh [--dry-run] preset.json"
  echo "  Offline-render one scenario preset -> verified 1080x1920 MP4."
  exit 0
}
DRY=0
[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && usage
if [[ "${1:-}" == "--dry-run" ]]; then DRY=1; shift; fi
[[ $# -lt 1 ]] && usage
PRESET="$1"

echo "preset: $PRESET"
echo "movie : ${PRESET%.json}.avi  (via xvfb-run-godot.sh --write-movie)"
echo "final : ${PRESET%.json}.final.mp4 (via to_mp4.sh)"
if [[ $DRY -eq 1 ]]; then
  echo "[dry-run] would: validate preset -> Movie Maker render -> ffprobe verify (1080x1920, 30fps, audio) -> to_mp4.sh"
  exit 0
fi
echo "ERROR: record.sh is a skeleton until TASK-109 (needs ScenarioRunner + preset schema)." >&2
exit 2
