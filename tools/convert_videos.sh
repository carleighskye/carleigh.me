#!/usr/bin/env bash
# Helper script to convert pet-care MP4 walkthroughs to WebM (VP9) with alpha
# Usage: run from repo root: ./tools/convert_videos.sh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$ROOT_DIR/img/student-work/pet-care"
OUT_DIR="$SRC_DIR"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg not found. Install ffmpeg and rerun this script."
  exit 2
fi

FILES=(
  "catinfouserflowcomp.mp4"
  "dogquizuserflowcomp.mp4"
  "turtleinfouserflowcomp.mp4"
)

echo "Converting files in: $SRC_DIR"
cd "$SRC_DIR"

for f in "${FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "Skipping missing file: $f"
    continue
  fi

  base="${f%.*}"
  out_webm="$OUT_DIR/${base}.webm"

  # First try a direct conversion preserving alpha if present (pix_fmt -> yuva*)
  echo "Checking pixel format for $f..."
  pixfmt=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt -of default=nw=1:nk=1 "$f" || echo "unknown")
  echo "  pix_fmt=$pixfmt"

  if [[ "$pixfmt" == yuva* || "$pixfmt" == rgba* || "$pixfmt" == argb* ]]; then
    echo "  Source appears to have alpha; converting to WebM (VP9) preserving alpha..."
    ffmpeg -y -i "$f" -c:v libvpx-vp9 -pix_fmt yuva420p -b:v 0 -crf 30 "$out_webm"
  else
    echo "  Source has no alpha. Attempting simple chroma/colorkey removal (white default)."
    # This will try to remove near-white backgrounds; adjust colorkey value if needed.
    # NOTE: This is heuristic and may require tuning for your footage.
    ffmpeg -y -i "$f" -vf "colorkey=0xFFFFFF:0.2:0.1,format=yuva420p" -c:v libvpx-vp9 -b:v 0 -crf 30 "$out_webm"
  fi

  echo "Converted -> $out_webm"
done

echo "Done. If results need tuning, adjust the colorkey parameters in tools/convert_videos.sh"
