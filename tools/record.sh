#!/bin/bash
# record.sh — one-click scenario preset -> verified 1080x1920 MP4.
# Usage: record.sh [--dry-run] [--keep-avi] [--out DIR] preset.json|preset-name
# Steps: validate preset -> Movie Maker render (Xvfb) -> ffprobe verify
#        (1080x1920, 30fps, audio) -> to_mp4.sh -> verify MP4.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

usage() {
  echo "Usage: record.sh [--dry-run] [--keep-avi] [--out DIR] preset.json|preset-name"
  echo "  Offline-render one scenario preset -> verified 1080x1920 MP4."
  echo "  Default output: <repo>/renders/<name>.final.mp4"
  exit 0
}

DRY=0; KEEP=0; OUTDIR="$ROOT/renders"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage ;;
    --dry-run) DRY=1; shift ;;
    --keep-avi) KEEP=1; shift ;;
    --out) OUTDIR="$2"; shift 2 ;;
    *) break ;;
  esac
done
[[ $# -lt 1 ]] && usage
ARG="$1"

# resolve preset -> res:// path + short name
if [[ -f "$ARG" ]]; then
  PRESET_FILE="$ARG"
else
  PRESET_FILE="$ROOT/game/presets/$ARG.json"
  [[ -f "$PRESET_FILE" ]] || PRESET_FILE="$ROOT/game/presets/$ARG"
fi
[[ -f "$PRESET_FILE" ]] || { echo "ERROR: preset not found: $ARG" >&2; exit 1; }
NAME="$(basename "$PRESET_FILE" .json)"
RES_PATH="res://presets/$(basename "$PRESET_FILE")"

# preset must be valid JSON with a duration
DUR="$(python3 -c "import json;print(json.load(open('$PRESET_FILE')).get('duration','?'))")"
[[ "$DUR" == "?" ]] && { echo "ERROR: preset has no duration: $PRESET_FILE" >&2; exit 1; }

mkdir -p "$OUTDIR"
AVI="$OUTDIR/$NAME.avi"
MP4="$OUTDIR/$NAME.final.mp4"

echo "preset : $PRESET_FILE (duration ${DUR}s)"
echo "avi    : $AVI"
echo "mp4    : $MP4"
if [[ $DRY -eq 1 ]]; then
  echo "[dry-run] would: render -> ffprobe verify -> to_mp4.sh -> verify MP4"
  exit 0
fi

echo "--- render ---"
"$HERE/xvfb-run-godot.sh" --path "$ROOT/game" \
  --write-movie "$AVI" --fixed-fps 30 -- --preset="$RES_PATH"

echo "--- verify capture ---"
probe() { ffprobe -v error "$@" "$AVI"; }
W="$(probe -select_streams v:0 -show_entries stream=width -of csv=p=0)"
H="$(probe -select_streams v:0 -show_entries stream=height -of csv=p=0)"
FPS="$(probe -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0)"
AC="$(probe -select_streams a -show_entries stream=codec_type -of csv=p=0 | head -1)"
ADUR="$(probe -show_entries format=duration -of csv=p=0)"
echo "video=${W}x${H} fps=${FPS} audio=${AC:-NONE} duration=${ADUR}s"
[[ "$W" == "1080" && "$H" == "1920" ]] || { echo "ERROR: expected 1080x1920, got ${W}x${H}" >&2; exit 1; }
[[ "$FPS" == "30/1" ]] || { echo "ERROR: expected 30fps, got $FPS" >&2; exit 1; }
[[ "$AC" == "audio" ]] || { echo "ERROR: no audio stream" >&2; exit 1; }
python3 -c "import sys; d=float('$ADUR'); e=float('$DUR'); sys.exit(0 if abs(d-e)<1.0 else 1)" \
  || { echo "ERROR: duration $ADUR != preset $DUR" >&2; exit 1; }

echo "--- transcode ---"
"$HERE/to_mp4.sh" "$AVI" "$MP4"

echo "--- verify mp4 ---"
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,codec_name,r_frame_rate -of default=noprint_wrappers=1 "$MP4"
ffprobe -v error -select_streams a:0 \
  -show_entries stream=codec_name -of default=noprint_wrappers=1 "$MP4"

if [[ $KEEP -eq 0 ]]; then rm -f "$AVI"; echo "(intermediate avi removed; --keep-avi to retain)"; fi
echo "DONE: $MP4"
