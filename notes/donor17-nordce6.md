# New donor — OnePlus Nord CE6, ColorOS 17 (Android 17)

Status: 2026-11-26 — port restarted with ColorOS 17 donor.

## Donor identity
- Device: OnePlus Nord CE6 (IN)
- Model: CPH2805 (region IN) / CPH2807 (GLO)
- Build: CPH2805_17.0.0.101(EX01)
- OTA id: CPH2805_11.A.11_1110_202611041134
- Android: 17 (SDK 37)
- ColorOS: 17.0.0
- Security patch: 2026-11-01
- SoC: Qualcomm Snapdragon 7s Gen 4 (SM7635-class)
- Size: 7.34 GB
- MD5: d9e86a1905fb1eff1d5da9a9555f6418
- Source: https://fwatlas.com/oneplus/oneplus-nord-ce6/cph2805-17-0-0-101-ex01-cph2805-11-a-11-1110-202611041134-in (Cloudflare-protected; download in a real browser)
- Package type: Full package (local install OTA), payload.bin inside

## ⚠️ SoC mismatch warning
Target (Moto Edge 50 Pro / eqe) is Snapdragon 7 Gen 3 (SM7550-AB).
Donor (Nord CE6) is Snapdragon 7s Gen 4.
These are DIFFERENT SoCs. The previous plan (ColorOS 16 / Nord CE4) was chosen
specifically because Nord CE4 shares SM7550 with the target. By moving to
ColorOS 17 (Nord CE6) we lose same-SoC compatibility: vendor blobs, kernel
nodes, VINTF and HALs will need cross-platform bridging (shims), same class of
are worth this before investing weeks.

## Target (stock) — pulled from device 2026-11-26
- Device: Motorola Edge 50 Pro (eqe), Android 16, build W1UMS36M-W1-ST8.2
- Security patch: 2026-09-01
- Partitions dumped to /storage/emulated/0/port/stock/extracted/moto-lpunpack/ (from /dev/block/by-name/super, slot _a)
  - system_a.img, system_ext_a.img, product_a.img, vendor_a.img, vendor_dlkm_a.img, system_dlkm_a.img (all EROFS)
- Plus /storage/emulated/0/port/stock/dumped/: boot_a.img, vendor_boot_a.img, dtbo_a.img, vbmeta_a.img, vbmeta_system_a.img, init_boot_a.img, super_eqe_stock.img (10.8 GB)
- Active slot: _a

## Next steps
1. Download donor ROM (7.34 GB) from fwatlas in a real browser → donor/raw/CPH2805_17.0.0.101.zip
   Verify MD5 d9e86a1905fb1eff1d5da9a9555f6418
2. Extract: bash tools/scripts/extract.sh donor/raw/CPH2805_17.0.0.101.zip donor
   (payload.bin → payload_dumper → *.img)
3. Extract trees: bash tools/scripts/extract-donor-trees.sh
4. Run VINTF/prop analysis; compare HAL set with archived X9 Ultra notes.
5. Build first super.img in output/.

## Old donor (kept, not deleted)
- /storage/emulated/0/port/donor/raw/CPH2613_16.0.5.1302.zip (Nord CE4 ColorOS 16)
