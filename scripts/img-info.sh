#!/usr/bin/env bash
# Inspect partition images: size, sparse/raw, filesystem type.
# Usage: img-info.sh <image.img> [more.img ...]
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <image.img> [more.img ...]"
  exit 1
fi

for img in "$@"; do
  [ -f "$img" ] || { echo "[!] Missing: $img"; continue; }
  echo "================= $img ================="
  du -h "$img"
  (command -v file >/dev/null 2>&1 && file "$img") || true

  if simg2img "$img" /dev/null >/dev/null 2>&1; then
    echo "sparse    : YES  (run 'simg2img in.img out.img' to make raw)"
  else
    echo "sparse    : no / already raw"
  fi

  if /system/bin/dump.erofs --path=/ "$img" >/dev/null 2>&1 || /system/bin/fsck.erofs "$img" >/dev/null 2>&1; then
    echo "filesystem: EROFS  (system/bin/dump.erofs & mkfs.erofs available)"
  elif tune2fs -l "$img" >/dev/null 2>&1; then
    echo "filesystem: EXT4   (e2fsck/tune2fs/resize2fs available)"
  else
    echo "filesystem: unknown (could be boot/dtbo/vbmeta or unsupported)"
  fi
  echo
done
