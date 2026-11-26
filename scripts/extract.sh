#!/usr/bin/env bash
# Extract a ROM archive into the workspace.
# Usage: extract.sh <archive> [donor|stock]   (default target: donor)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

usage() {
  echo "Usage: bash $(basename "$0") <archive> [donor|stock]"
  echo "  donor = ColorOS 17 ROM, stock = Moto Edge 50 Pro firmware"
  echo "  Handles: ZIP (with/without payload.bin), payload.bin, .ofp, .tar(.md5), .img"
  echo "  Output:  \$PORT_ROOT/<target>/extracted"
}

[ $# -ge 1 ] || { usage; exit 1; }
ARCHIVE="$1"
TARGET="${2:-donor}"
case "$TARGET" in
  donor|stock) ;;
  *) echo "[!] Target must be 'donor' or 'stock'"; usage; exit 1 ;;
esac

case "$ARCHIVE" in
  /*) ;;
  *) ARCHIVE="$(pwd)/$ARCHIVE" ;;
esac

[ -f "$ARCHIVE" ] || { echo "[!] Not a file: $ARCHIVE"; exit 1; }

DEST="$PORT_ROOT/$TARGET/extracted"
mkdir -p "$DEST"
TMP="$PORT_ROOT/work/extract-$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT

name="$(basename "$ARCHIVE")"
lower="${name,,}"
echo "[*] Input : $name"
echo "[*] Target: $DEST"

case "$lower" in
  *.zip)
    echo "[*] ZIP archive detected"
    if unzip -l "$ARCHIVE" 2>/dev/null | grep -q 'payload\.bin'; then
      echo "[*] Found payload.bin inside — extracting it first"
      unzip -o -q "$ARCHIVE" 'payload.bin' -d "$TMP"
      payload_dumper --out "$DEST" "$TMP/payload.bin"
    else
      echo "[*] No payload.bin — extracting full ZIP"
      unzip -o -q "$ARCHIVE" -d "$DEST"
    fi
    ;;
  *payload*.bin|payload.bin|*.bin)
    echo "[*] payload.bin detected — dumping partitions"
    payload_dumper --out "$DEST" "$ARCHIVE"
    ;;
  *.ofp)
    echo "[*] Oppo .ofp detected — using oppo_decrypt (QC first, then MTK)"
    if ! bash "$SCRIPT_DIR/ofp-extract.sh" "$ARCHIVE" "$DEST" qc; then
      echo "[*] QC decrypt failed — trying MTK"
      bash "$SCRIPT_DIR/ofp-extract.sh" "$ARCHIVE" "$DEST" mtk
    fi
    ;;
  *.ops)
    echo "[*] OnePlus .ops detected — using oppo_decrypt"
    bash "$SCRIPT_DIR/ofp-extract.sh" "$ARCHIVE" "$DEST"
    ;;
  *.tar|*.tar.md5|*.tar.gz|*.tgz)
    echo "[*] TAR archive detected"
    tar -xf "$ARCHIVE" -C "$DEST"
    ;;
  *.img)
    echo "[*] Single image — copying"
    cp -v "$ARCHIVE" "$DEST/"
    ;;
  *)
    echo "[!] Unknown file type — copying as-is"
    cp -v "$ARCHIVE" "$DEST/"
    ;;
esac

echo "[+] Done. Output: $DEST"
ls -lh "$DEST" | head -40
