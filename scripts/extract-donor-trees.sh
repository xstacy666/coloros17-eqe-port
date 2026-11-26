#!/usr/bin/env bash
# Extract the donor system-side partitions into editable trees.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

IMG="$DONOR_ROOT/extracted"
TREES="$DONOR_ROOT/trees"
mkdir -p "$TREES"

PARTS="system system_ext product my_product my_stock my_manifest my_heytap my_region my_bigball my_carrier my_engineering odm vendor"

for p in $PARTS; do
  if [ ! -f "$IMG/$p.img" ]; then echo "[!] missing $p.img"; continue; fi
  echo "[*] extracting $p.img -> $TREES/$p"
  bash "$SCRIPT_DIR/extract-images.sh" "$IMG/$p.img" "$TREES/$p" || echo "[!] failed $p"
done

echo "[+] Done. Trees in $TREES"
du -sh "$TREES"/*
