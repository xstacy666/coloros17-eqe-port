# ColorOS 17 Port for Motorola Edge 50 Pro (eqe)

Cross-OEM port of ColorOS 17 (Android 17) from OnePlus Nord CE6 (CPH2805) to Motorola Edge 50 Pro (eqe, SM7550-AB).

## Target Device
- **Device:** Motorola Edge 50 Pro (eqe)
- **SoC:** Qualcomm Snapdragon 7 Gen 3 (SM7550-AB)
- **Android:** 16 (stock), porting to 17
- **Bootloader:** Unlocked, rooted (KernelSU)

## Donor Device
- **Device:** OnePlus Nord CE6 (CPH2805)
- **Build:** CPH2805_17.0.0.101(EX01)
- **Android:** 17 (ColorOS 17.0.0)
- **SoC:** Qualcomm Snapdragon 7s Gen 4

## ⚠️ SoC Mismatch
Donor and target use different SoCs (Snapdragon 7s Gen 4 vs 7 Gen 3). This is a cross-SoC port requiring HAL shims and VINTF cleanup.

## Port Model
- **Keep from Moto (target):** boot, vendor_boot, dtbo, vbmeta*, vendor, vendor_dlkm, system_dlkm, modem, bluetooth, dsp, persist, firmware
- **Take from ColorOS (donor):** system, system_ext, product, my_* partitions
- **Bridge gaps:** shims, VINTF cleanup, props, SELinux

## Repository Contents
- `notes/` — Porting notes, HAL comparison, fix logs
- `scripts/` — Build and extraction scripts
- `work/` — Merged fstab and other work files

## Build
See `notes/` for detailed build instructions and porting phases.

## Status
- [x] Stock ROM extracted from device
- [x] Donor ROM extracted (ColorOS 17)
- [x] VINTF cleanup (OPPO service declarations removed)
- [x] Props patched (Moto identity)
- [x] Binary patches (waitForService → checkService)
- [x] fstab merged (Moto + ColorOS my_* mounts)
- [x] Permissive SELinux for bring-up
- [ ] First boot test
- [ ] HAL shims (charger, fingerprint, touch, etc.)
- [ ] Telephony/IMS fixes
- [ ] Camera/audio/display tuning

## License
This repository contains porting notes and scripts. Proprietary vendor blobs are not included.
