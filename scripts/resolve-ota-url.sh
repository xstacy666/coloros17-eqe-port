#!/usr/bin/env bash
# Print a fresh signed CDN URL for an OTA in the Daniel Springer catalog.
# Usage: resolve-ota-url.sh [device] [region] [version]
# Defaults: X9 Ultra ColorOS 17 (kept for reference).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../env.sh"

DEVICE="${1:-OPPO FIND X9 ULTRA}"
REGION="${2:-CN}"
VERSION="${3:-PMA120_17.0.1.200(CN01)}"

PYTHONPATH="$PYLIBS" python3 - "$DEVICE" "$REGION" "$VERSION" <<'PY'
import re,sys,json,requests
device,region,version=sys.argv[1],sys.argv[2],sys.argv[3]
s=requests.Session(); b='https://roms.danielspringer.at'
h=s.get(b+'/index.php?view=ota',timeout=30).text
m=re.search(r"data-devices='(\{.*?\})'",h,re.S)
vers=json.loads(m.group(1))[device][region]
try:
    idx=vers.index(version)
except ValueError:
    raise SystemExit(f'{version} not in {device}/{region}: {vers[:5]}')
r=s.post(b+'/index.php?view=ota',
         data={'device':device,'region':region,'version_index':str(idx)},timeout=60)
k=re.search(r'data-ota-key="([^"]*)"',r.text).group(1)
c=re.search(r'data-csrf="([^"]*)"',r.text).group(1)
p=s.post(b+'/index.php?view=ota&ota_action=resolve_json',
         data={'k':k,'csrf':c},timeout=90).json()
if not p.get('ok'): raise SystemExit('resolver failed: '+str(p))
print(p['url'])
PY
