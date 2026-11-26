#!/usr/bin/env bash
# Collect device properties/partition layout from the connected phone via adb.
# Output goes to 06_backups/. Requires USB debugging authorised.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

OUT="$PORT_ROOT/backups/device-info-$(date +%Y%m%d-%H%M%S).txt"
mkdir -p "$(dirname "$OUT")"

if ! adb get-state >/dev/null 2>&1; then
  echo "[!] No adb device found. Connect the phone and authorise USB debugging."
  exit 1
fi

{
  echo "=== adb devices ==="
  adb devices -l
  echo "=== getprop ==="
  adb shell getprop
  echo "=== /proc/partitions ==="
  adb shell cat /proc/partitions 2>/dev/null || true
  echo "=== block devices ==="
  adb shell ls -l /dev/block/by-name 2>/dev/null || true
  echo "=== mounts ==="
  adb shell cat /proc/mounts 2>/dev/null || true
} > "$OUT" 2>&1

echo "[+] Saved: $OUT"
