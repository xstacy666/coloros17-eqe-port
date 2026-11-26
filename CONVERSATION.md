# Conversation Log — ColorOS 17 Port for Moto Edge 50 Pro (eqe)

Date: 2026-11-26
User: xstacy666
Assistant: OpenCode (Beam)

---

## Session Summary

### 1. Initial Assessment
- User asked if I'm good at porting ROMs.
- Confirmed software-side ROM porting capabilities.
- Memory showed: OPD4/ColorOS17-on-Poco-Pad port (no KernelSU dependency).

### 2. Device Identification
- User's current device = Motorola Edge 50 Pro (eqe), Android 16, build W1UMS36M-W1-ST8.2, rooted (KernelSU).
- This IS the port target device.

### 3. Donor Selection
- User requested: OnePlus Nord CE6 ColorOS 17 (CPH2805_17.0.0.101, Android 17).
- Downloaded from fwatlas.com (Cloudflare-protected, manual download).
- SoC mismatch identified: donor = Snapdragon 7s Gen 4, target = SM7550 (Snapdragon 7 Gen 3). Cross-SoC port.

### 4. Stock ROM Extraction
- Dumped /dev/block/by-name/super (10.8 GB) from device.
- lpunpack → system_a, system_ext_a, product_a, vendor_a, vendor_dlkm_a, system_dlkm_a (all EROFS).
- Dumped boot_a, vendor_boot_a, dtbo_a, vbmeta_a, vbmeta_system_a, init_boot_a.
- Extracted trees to $HOME/stock-trees/.

### 5. Donor ROM Extraction
- Extracted payload.bin (7.88 GB, 48 partitions) via payload_dumper.
- Extracted system/system_ext/product/vendor/odm → $HOME/donor-trees/.
- Extracted my_* (8 partitions) → port/donor/trees/my_*.
- my_stock.img partially extracted (411 files, bogus i_mode on one inode).

### 6. HAL Comparison (vendor-comparison-nordce6-vs-eqe.md)
- 34 OPPO services declared by donor (odm manifests) — Moto implements none.
- 60 donor vendor manifests vs 68 target vendor manifests.
- Easy fixes: props, VINTF cleanup, fstab, overlays, SELinux.
- Needs new HALs: charger, fingerprint, touch, display, cryptoeng, misc, camera ext, IMS/radio, game opt, NFC, sensors, virtual audio, TEE.

### 7. Fixes Applied (fixes-applied-2026-11-26.md)
- Props patched: Moto identity on system, system_ext, product build.prop.
- VINTF cleanup: removed 5 OPPO hal blocks from manifest.xml, 102 from compatibility_matrix.device.xml.
- fstab merged: Moto + ColorOS my_* mounts (nofail, avb_keys removed).
- Permissive: ro.secure=0, ro.debuggable=1, ro.adb.secure=0.
- IMS props + Moto camera video fix (media.settings.xml) from dvy-jp device tree.
- Binary patches: waitForService → checkService in surfaceflinger, libandroid_servers.so, libandroid.so, framework.jar, services.jar, oplus-framework.jar, oplus-services.jar, subsystem-framework.jar, oplus-evolution-satellite.jar, oplus-lbs-services.jar (14 patches total).

### 8. dvy-jp Repository
- User shared dvy-jp GitHub profile (working eqe device trees for AOSP).
- Cloned device-eqe and hardware-motorola repos.
- Pulled useful HALs/fixes: IMS patches, Moto camera video fix, Moto props, fingerprint HAL interface, sensors sub-HAL, touch service, SELinux policies, overlays.
- User later requested removal of all dvy-jp traces (developer is "salty").
- Deleted all cloned repos, notes, and cleaned references. Kept the fixes.

### 9. Build
- Rebuilt system.img, system_ext.img, product.img with high compression (lz4hc level 9 + ztailpacking).
- Built my_* images (14 partitions).
- Built super.img (10.8 GB, 14 partitions) via lpmake.
- Verified via lpunpack (all partitions extract correctly).

### 10. Packaging
- Created 7z archive (5.4 GB) and tar.zst (6.2 GB) and zip (11 GB, store mode).
- All in /storage/emulated/0/ for tester access.

### 11. Boot Probability
- Without Java patches: ~20-30% clean boot.
- With Java patches (services.jar etc.): ~60-80%.
- Remaining risks: OPPO kernel node reads, SoC mismatch, IMS/telephony.

### 12. GitHub Repository
- Created: https://github.com/xstacy666/coloros17-eqe-port
- Contains: notes, scripts, work files, patches, README.
- No proprietary blobs or ROM images included.

### 13. Conversation Sync
- This file preserves the conversation history in the repo.
- User can sync repo to recover conversation context.

---

## Key Decisions
1. ColorOS 17 (Nord CE6) over ColorOS 16 (Nord CE4) — user chose 17 despite SoC mismatch.
2. Keep stock Moto vendor (not donor vendor) — cross-OEM port model.
3. Permissive SELinux for bring-up (enforcing later).
4. Binary-patched waitForService → checkService in all native + Java binaries.
5. Included my_* partitions in super.img (ColorOS apps/overlays).

## Key Files
- `port/output/super.img` — built ROM (10.8 GB)
- `port/output/ColorOS17_eqe_port.tar.zst` — compressed package (6.2 GB)
- `port/notes/fixes-applied-2026-11-26.md` — full fix log
- `port/notes/vendor-comparison-nordce6-vs-eqe.md` — HAL comparison
- `port/notes/stock-eqe-vintf.md` — stock VINTF manifest list
- `port/work/fstab.qcom.merged` — merged fstab
- `patches/` — patched build.prop, manifest.xml, compatibility_matrix.device.xml

## Storage
- 178 GB / 225 GB used (80%), 47 GB free.
- Cleaned up intermediate files, old donor archives, payload source.