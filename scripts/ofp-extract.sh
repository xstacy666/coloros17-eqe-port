#!/usr/bin/env bash
# Extract Oppo .ofp / OnePlus .ops firmware using the collected bkerler/oppo_decrypt.
# Usage: bash ofp-extract.sh <file.ofp|.ops> [dest] [qc|mtk]
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

if [ $# -lt 1 ]; then
  echo "Usage: bash $(basename "$0") <file.ofp|.ops> [dest] [qc|mtk]"
  exit 1
fi

OFP="$1"
CPU="${3:-qc}"
DEST="${2:-$PORT_ROOT/work/ofp-out}"
mkdir -p "$DEST"

DECRYPT="$PORT_ROOT/reference/oppo_decrypt"
case "${OFP,,}" in
  *.ops)
    SCRIPT="$DECRYPT/opscrypto.py"
    echo "[*] OnePlus .ops → decrypt"
    PYTHONPATH="$PYLIBS" python3 "$SCRIPT" decrypt "$OFP"
    ;;
  *.ofp)
    case "$CPU" in
      qc) SCRIPT="$DECRYPT/ofp_qc_decrypt.py" ;;
      mtk) SCRIPT="$DECRYPT/ofp_mtk_decrypt.py" ;;
      *) echo "[!] CPU must be qc or mtk"; exit 1 ;;
    esac
    echo "[*] Oppo .ofp ($CPU) → $DEST"
    PYTHONPATH="$PYLIBS" python3 "$SCRIPT" "$OFP" "$DEST"
    ;;
  *)
    echo "[!] Expected .ofp or .ops"
    exit 1
    ;;
esac

echo "[+] Done. Check: $DEST"
