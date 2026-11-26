#!/usr/bin/env bash
# Download ColorOS 16 (OnePlus Nord CE4) OTA with resume + fresh CDN links.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

OUT="$DONOR_ROOT/raw/CPH2613_16.0.5.1302.zip"
EXPECTED=8024655568
EXPECTED_MD5=525d9f03a8d02938f06fb61d9cd3fe0c
DEVICE='OP NORD CE4'
REGION='IN'
VERSION='CPH2613_16.0.5.1302(EX01)'
LOG="$PORT_ROOT/logs/download-donor16.log"

for i in $(seq 1 60); do
  size=$(stat -c%s "$OUT" 2>/dev/null || echo 0)
  echo "[$(date +%H:%M:%S)] attempt $i, size=$size / $EXPECTED" >> "$LOG"
  [ "$size" -ge "$EXPECTED" ] && break
  URL=$(bash "$SCRIPT_DIR/resolve-ota-url.sh" "$DEVICE" "$REGION" "$VERSION") || { echo "resolve failed" >> "$LOG"; continue; }
  curl -fL -C - --retry 5 --retry-delay 3 -o "$OUT" "$URL" >> "$LOG" 2>&1 || true
done

size=$(stat -c%s "$OUT" 2>/dev/null || echo 0)
echo "[$(date +%H:%M:%S)] final size=$size" >> "$LOG"
if [ "$size" -eq "$EXPECTED" ]; then
  actual=$(md5sum "$OUT" | cut -d' ' -f1)
  echo "md5=$actual expected=$EXPECTED_MD5" >> "$LOG"
  [ "$actual" = "$EXPECTED_MD5" ] && echo "VERIFY_OK" >> "$LOG" || echo "VERIFY_FAIL" >> "$LOG"
else
  echo "INCOMPLETE" >> "$LOG"
fi
tail -3 "$LOG"
