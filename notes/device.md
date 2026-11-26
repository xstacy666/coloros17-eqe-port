# Target device — Motorola Edge 50 Pro (stock side)

- Codename: **eqe** (verify: `adb shell getprop ro.product.device`)
- Model: XT2403-1 (variants differ by region; firmware must match your exact variant)
- SoC: Qualcomm Snapdragon 7 Gen 3, SM7550-AB
- Android at launch: 14; A/B (seamless) updates, dynamic partitions, erofs on recent builds
- Display: 6.7" pOLED 144 Hz, FHD+

## Keep these from the Moto `stock/` side (do NOT take from ColorOS `donor/`)

- `boot`, `vendor_boot`, `dtbo`, `vbmeta*`, `init_boot`
- `vendor`, `vendor_dlkm`, `system_dlkm`, `modem`, `bluetooth`, `dsp`
- `persist`, `misc`, `metadata`, `frp`, `logo`, device calibration partitions

## Generally take these from the ColorOS `donor/` side

- `system`, `system_ext`, `product`, `product_ext` (if present)

## Likely fix points

- `fstab` / dynamic-partition layout and mount points
- props: brand, model, device, fingerprint, API level
- SELinux policy (cross-OEM HAL mismatches are the usual bootloop cause)
- VINTF/manifest compatibility between ColorOS framework and Moto vendor
- Camera, fingerprint, display, audio HALs are tied to the Moto vendor

## Useful checks

```sh
adb shell getprop | grep -E 'ro.product|ro.build|first_api|vendor'
adb shell ls /dev/block/by-name
adb shell cat /proc/partitions
fastboot getvar all
```
