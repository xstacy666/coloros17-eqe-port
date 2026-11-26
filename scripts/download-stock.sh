#!/usr/bin/env bash
# Re-download the Motorola eqe stock firmware with resume + retries.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

NAME='EQE_RETAIL_16_W1UMS36H.19-13-4-1_subsidy-DEFAULT_regulatory-DEFAULT_cid50_CFC.xml.zip'
OUT="$STOCK_ROOT/raw/$NAME"
URL='https://sourceforge.net/projects/eqe/files/Stock/EQE_RETAIL_16_W1UMS36H.19-13-4-1_subsidy-DEFAULT_regulatory-DEFAULT_cid50_CFC.xml.zip/download'
EXPECTED=5796928940
LOG="$PORT_ROOT/logs/download-stock-loop.log"

for i in $(seq 1 200); do
  size=$(stat -c%s "$OUT" 2>/dev/null || echo 0)
  echo "[$(date +%H:%M:%S)] attempt $i, size=$size / $EXPECTED" >> "$LOG"
  [ "$size" -ge "$EXPECTED" ] && break
  curl -fL -C - --retry 8 --retry-delay 3 -o "$OUT" "$URL" >> "$LOG" 2>&1 || true
done

size=$(stat -c%s "$OUT" 2>/dev/null || echo 0)
echo "[$(date +%H:%M:%S)] final size=$size" >> "$LOG"
if [ "$size" -eq "$EXPECTED" ]; then
  if unzip -t "$OUT" >/dev/null 2>&1; then echo "ZIP_OK" >> "$LOG"; else echo "ZIP_BAD" >> "$LOG"; fi
else
  echo "INCOMPLETE" >> "$LOG"
fi
tail -3 "$LOG"
