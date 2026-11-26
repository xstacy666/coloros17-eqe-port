# Fixes applied — 2026-11-26 (Nord CE6 ColorOS 17 donor)

## Donor extraction
- Extracted payload.bin (7.88 GB, 48 partitions) → donor/extracted/*.img
- Extracted system/system_ext/product/vendor/odm → $HOME/donor-trees/ (symlink-capable)
- Extracted my_* (8 partitions) → port/donor/trees/my_*
- my_stock.img partially extracted (411 files) — bogus i_mode on one inode; structure intact.

## Props patched (Moto identity)
- system/system/build.prop: ro.product.system.{brand,device,manufacturer,model,name} → motorola/eqe/motorola/motorola edge 50 pro/eqe_g
- system_ext/etc/build.prop: ro.product.system_ext.{brand,device,manufacturer,model,name} → same
- product/etc/build.prop: ro.product.product.{brand,device,manufacturer,model,name} → same
- Permissive build: ro.secure=0, ro.adb.secure=0, ro.debuggable=1 (system/system/build.prop)

## VINTF cleanup (pipa step 4q)
- Removed 5 OPPO <hal> blocks from system/system/etc/vintf/manifest.xml (commondcs, hummingbird, oplusSensor, osense.client, urcc)
- Removed 102 OPPO <hal> blocks from system/system/etc/vintf/compatibility_matrix.device.xml
- Both files verified well-formed XML.
- Backups: *.bak in same dir.

## fstab
- Merged donor my_* mount block + overlay block into Moto fstab → port/work/fstab.qcom.merged
- avb_keys removed from my_* entries (permissive: nofail retained).
- To ship: copy merged fstab to vendor/etc/fstab.qcom at build time.

## SELinux
- Permissive mode recommended for bring-up: kernel cmdline `androidboot.selinux=permissive` in boot image, OR keep enforcing with secilc-compiled policy (notes/hals-and-resources.md).
- Do NOT keep enforcing until shims are validated.

## Still TODO (needs build host / more work)
- Binary-patch waitForService → checkService in surfaceflinger/system_server (pipa step 2x).
- Add charger shim (chargehal-oplus), fingerprint shim, touch shim, misc shim.
- Telephony (IMS/radio) shim — highest risk.
- Build super.img with lpmake + mkfs.erofs.
- SELinux policy compilation (secilc).
- Camera/audio/display tuning.