#!/usr/bin/env bash
# TEMPLATE — build super.img from partition image files.
# Fill in the sizes/layout from the stock eqe super partition before running.
# Usage: bash build-super.sh <config.sh>
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

if [ $# -lt 1 ]; then
  echo "Usage: bash $(basename "$0") <config.sh>"
  echo "  config.sh should define: SUPER_SIZE GROUP_SIZE and PART_<name>='size|image'"
  exit 1
fi
. "$1"

: "${SUPER_SIZE:?set SUPER_SIZE}"
: "${GROUP_SIZE:?set GROUP_SIZE}"

CMDS=(
  --metadata-size 65536
  --super-name super
  --metadata-slots 2
  --device "super:$SUPER_SIZE"
  --group "qti_dynamic_partitions_a:$GROUP_SIZE"
  --group "qti_dynamic_partitions_b:$GROUP_SIZE"
)

for spec in "${!PART_@}"; do
  [ "$spec" = "PART_" ] && continue
  name="${spec#PART_}"
  value="${!spec}"
  size="${value%%|*}"
  image="${value#*|}"
  slot="${SLOT:-b}"
  [ -f "$image" ] || { echo "[!] Missing $image"; exit 1; }
  echo "[*] $name -> slot $slot, size $size"
  CMDS+=(--partition "$name:readonly:$size:qti_dynamic_partitions_$slot" --image "$name=$image")
done

CMDS+=(--output "$PORT_ROOT/output/super.img")
mkdir -p "$PORT_ROOT/output"
echo "[*] lpmake ${CMDS[*]}"
lpmake "${CMDS[@]}"
echo "[+] Wrote $PORT_ROOT/output/super.img"
