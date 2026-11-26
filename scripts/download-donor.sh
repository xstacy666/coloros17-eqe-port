#!/usr/bin/env bash
# Download the donor OTA with automatic resume + fresh CDN links until MD5 matches.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

OUT="$DONOR_ROOT/raw/PMA120_17.0.1.200.zip"
EXPECTED_SIZE=10590301666
EXPECTED_MD5=253c41ac4d02bdebc3d1270c2b2a2667
LOG="$PORT_ROOT/logs/download-donor-loop.log"

for i in $(seq 1 60); do
  size=$(stat -c%s "$OUT" 2>/dev/null || echo 0)
  echo "[$(date +%H:%M:%S)] attempt $i, size=$size / $EXPECTED_SIZE" >> "$LOG"
  [ "$size" -ge "$EXPECTED_SIZE" ] && break
  URL=$(bash "$SCRIPT_DIR/resolve-ota-url.sh") || { echo "resolve failed" >> "$LOG"; continue; }
  curl -fL -C - --retry 5 --retry-delay 3 -o "$OUT" "$URL" >> "$LOG" 2>&1 || true
done

size=$(stat -c%s "$OUT" 2>/dev/null || echo 0)
echo "[$(date +%H:%M:%S)] final size=$size" >> "$LOG"
if [ "$size" -eq "$EXPECTED_SIZE" ]; then
  actual=$(md5sum "$OUT" | cut -d' ' -f1)
  echo "md5=$actual expected=$EXPECTED_MD5" >> "$LOG"
  [ "$actual" = "$EXPECTED_MD5" ] && echo "VERIFY_OK" >> "$LOG" || echo "VERIFY_FAIL" >> "$LOG"
else
  echo "INCOMPLETE" >> "$LOG"
fi
tail -5 "$LOG"
