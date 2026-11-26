#!/usr/bin/env bash
# Extract a Motorola fastboot XML firmware zip: unzip, join sparse chunks,
# convert to raw images and unpack super.img into logical partitions.
# Usage: bash extract-moto.sh <firmware.zip>
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

if [ $# -lt 1 ]; then
  echo "Usage: bash $(basename "$0") <firmware.zip>"
  exit 1
fi
FW="$1"
case "$FW" in /*) ;; *) FW="$(pwd)/$FW" ;; esac
[ -f "$FW" ] || { echo "[!] Not a file: $FW"; exit 1; }

DEST="$STOCK_ROOT/extracted"
RAW="$DEST/raw"
mkdir -p "$RAW" "$DEST/super"

echo "[*] Unzipping firmware -> $RAW"
unzip -o -q "$FW" -d "$RAW"

echo "[*] Sparse chunk sets found:"
python3 - "$RAW" <<'PY'
import os,re,sys
raw=sys.argv[1]
groups={}
for f in os.listdir(raw):
    m=re.match(r'(.+?\.img)\.sparsechunk\.(\d+)$', f, re.I)
    if m: groups.setdefault(m.group(1),[]).append((int(m.group(2)),f))
for name,items in sorted(groups.items()):
    print(f'  {name}: {len(items)} chunks')
PY

# Join and de-sparse every sparsechunk set
for pattern in "$RAW"/*.img.sparsechunk.*; do
  [ -e "$pattern" ] || continue
  base="${pattern%%.sparsechunk.*}"
  name="$(basename "$base")"
  echo "[*] Joining $name chunks"
  python3 - "$RAW" "$name" > "$RAW/.chunklist" <<'PY'
import os,re,sys
raw,name=sys.argv[1],sys.argv[2]
items=[(int(m.group(1)),f) for f in os.listdir(raw)
       if (m:=re.match(re.escape(name)+r'\.sparsechunk\.(\d+)$',f,re.I))]
for _,f in sorted(items): print(os.path.join(raw,f))
PY
  cat $(cat "$RAW/.chunklist") > "$RAW/${name}.sparse"
  if simg2img "$RAW/${name}.sparse" "$RAW/${name}" 2>/dev/null; then
    echo "    -> $name (raw)"
  else
    echo "    -> $name already raw / simg2img not needed"
    cp "$RAW/${name}.sparse" "$RAW/${name}"
  fi
  rm -f "$RAW/${name}.sparse" "$RAW/.chunklist"
done

# Unpack super.img into logical partitions
SUPER=""
for c in "$RAW/super.img" "$RAW/super" ; do [ -f "$c" ] && SUPER="$c" && break; done
if [ -n "$SUPER" ]; then
  echo "[*] lpdump $SUPER"; lpdump "$SUPER" > "$DEST/lpdump.txt" 2>&1
  echo "[*] lpunpack -> $DEST/super"
  lpunpack "$SUPER" "$DEST/super" || echo "[!] lpunpack failed"
else
  echo "[!] No super.img found — check $RAW"
fi

echo "[+] Done. Device images: $RAW"
ls -lh "$RAW" | head -40
