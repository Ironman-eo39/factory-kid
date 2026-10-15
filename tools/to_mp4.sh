#!/bin/bash
# to_mp4.sh — transcode a Movie Maker capture to a finished vertical MP4.
# Input:  AVI/MJPEG (or PNG sequence dir) from --write-movie
# Output: 1080x1920, 30fps, H.264 + AAC, yuv420p, faststart — ready for CapCut.
# Usage: to_mp4.sh INPUT.(avi|mp4) [OUTPUT.mp4]   |   to_mp4.sh --help
set -euo pipefail

usage() {
  echo "Usage: to_mp4.sh INPUT.(avi|mp4|png-dir) [OUTPUT.mp4]"
  echo "  Transcodes a Movie Maker capture to 1080x1920 H.264 + AAC."
  exit 0
}
[[ "${1:-}" == "--help" || "${1:-}" == "-h" ]] && usage
[[ $# -lt 1 ]] && usage

IN="$1"
OUT="${2:-${IN%.*}.final.mp4}"

if [[ -d "$IN" ]]; then
  # PNG sequence dir: frame_%05d.png + audio.wav expected
  ffmpeg -y -framerate 30 -i "$IN/frame_%05d.png" -i "$IN/audio.wav" \
    -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 30 \
    -vf "scale=1080:1920" -c:a aac -b:a 160k -movflags +faststart -shortest "$OUT"
else
  ffmpeg -y -i "$IN" \
    -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r 30 \
    -vf "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2" \
    -c:a aac -b:a 160k -movflags +faststart "$OUT"
fi
echo "wrote $OUT"
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,r_frame_rate,codec_name \
  -of default=noprint_wrappers=1 "$OUT"
