# Porting checklist

## Phase 0 — preparation
- [ ] ColorOS 17 files added to `donor/raw/`
- [ ] Moto Edge 50 Pro firmware added to `stock/raw/`
- [ ] Confirm exact device variant (XT2403-1 / region / build number)
- [ ] Confirm bootloader unlock status; back up current firmware into `backups/`
- [ ] Working custom recovery for `eqe`

## Phase 1 — extraction
- [ ] Extract donor (`bash tools/scripts/extract.sh donor/raw/<file> donor`)
- [ ] Extract stock (`bash tools/scripts/extract.sh stock/raw/<file> stock`)
- [ ] Identify sparse vs raw and filesystem (`bash tools/scripts/img-info.sh ...`)
- [ ] Convert sparse images with `simg2img`

## Phase 2 — assemble
- [ ] Keep Moto: boot/vendor_boot/dtbo/vbmeta/vendor/modem/dsp/bluetooth
- [ ] Bring ColorOS: system/system_ext/product/product_ext
- [ ] Unpack images into `work/`
- [ ] Patch fstab/mount points for the Moto dynamic-partition layout
- [ ] Patch props (brand/model/device/fingerprint/API level)
- [ ] Merge/fix SELinux policy and VINTF manifests
- [ ] Repack images (mkfs.erofs or mke2fs) and build ZIP in `output/`

## Phase 3 — test
- [ ] Flash, keep a path back to stock
- [ ] Save boot logs into `logs/`
- [ ] Fix in order: bootloop → recovery → framework → app crashes
- [ ] Verify camera, fingerprint, display, audio, RIL/modem

## Recovery reminders
- Never flash `persist`, `modem`, or `misc` without a matching backup
- Anti-rollback: match or exceed current Moto bootloader/firmware revision
- Keep every original image in `backups/`
