#!/usr/bin/env bash
# Extract a partition image into a directory, keeping SELinux labels/xattrs.
# Usage: bash extract-images.sh <image.img> <outdir>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

if [ $# -lt 2 ]; then
  echo "Usage: bash $(basename "$0") <image.img> <outdir>"
  exit 1
fi
IMG="$1"
OUT="$2"
[ -f "$IMG" ] || { echo "[!] Missing image: $IMG"; exit 1; }
mkdir -p "$OUT"

if /system/bin/dump.erofs --path=/ "$IMG" >/dev/null 2>&1 || /system/bin/fsck.erofs "$IMG" >/dev/null 2>&1; then
  # On Android neither /sdcard nor /data lets us write security.selinux xattrs,
  # so extract contents only. Restore labels at rebuild time with
  # mkfs.erofs --file-contexts=<file_contexts> (see notes/hals-and-resources.md).
  echo "[*] EROFS image -> $OUT (contents; SELinux labels restored at rebuild)"
  /system/bin/fsck.erofs --extract="$OUT" --overwrite --no-xattrs "$IMG"
elif tune2fs -l "$IMG" >/dev/null 2>&1; then
  echo "[*] EXT4 image -> $OUT (debugfs rdump)"
  echo "[!] Run as root if you need exact owner preservation."
  debugfs -R "rdump / $OUT" "$IMG"
else
  echo "[!] Unknown filesystem (boot/vbmeta/dtbo or unsupported) — nothing extracted"
  exit 1
fi
echo "[+] Done: $OUT"
