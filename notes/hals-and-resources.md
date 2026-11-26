# HALs, porting resources & a reality check

## Straight answer to "vendor is already AOSP, shouldn't be a hassle?"

No — and this is the single most important thing before you invest weeks in this.

1. **The vendor partition is not AOSP.** It is almost entirely proprietary,
   SoC-specific binaries (HAL implementations, firmware, DSP blobs, gralloc,
   camera, audio, display, sensor hubs). AOSP only defines the *interfaces*
   (HIDL/AIDL `.hal` files). The implementations ship with the device.
2. **HALs are not interchangeable across OEMs/SoCs.** You can't download a
   "camera HAL" from GitHub and drop it in. The ColorOS system side calls
   OPPO-specific services (`vendor.oplus.*`, `oplus.*`) that a Motorola
   `eqe` vendor simply does not implement, and the Moto vendor calls Qualcomm
   HALs that an OPPO donor may not ship for that exact SoC.
3. **Motorola never published `eqe` sources.** Issues
   [#600](https://github.com/MotorolaMobilityLLC/kernel-msm/issues/600),
   [#608](https://github.com/MotorolaMobilityLLC/kernel-msm/issues/608) and
   [#665](https://github.com/MotorolaMobilityLLC/kernel-msm/issues/665) in
   `MotorolaMobilityLLC/kernel-msm` are still open requests for the kernel,
   DTS, techpacks, audio/video/display packages. So you cannot rebuild the
   device side from source; you must reuse the stock images.
4. **The realistic path is the one all successful ColorOS ports use:** keep
   the device side (firmware/vendor/odm/kernel) almost untouched, take the
   donor system side whole, then bridge the gaps with *shims*, patches,
   overlays and SELinux rules. See `reference/pipa-cos17-port/PORTING-GUIDE.md`.

A ColorOS 17 port that actually boots and is daily-usable has been done on the
Xiaomi Pad 6 (`pipa`, SD870) with an OPPO Pad Mini donor — a device of the
*same SoC family*. `eqe` is a different Qualcomm SoC (SM7550-AB) with no
public source, so expect substantially more work, not less.

## The two halves (model to follow)

| Half | Partitions | Your source |
|---|---|---|
| Device side | firmware, `vendor`, `odm`, `vendor_boot`, `dtbo`, `vbmeta*`, `boot`/kernel | stock `eqe` firmware (pin by md5) |
| System side | `system`, `system_ext`, `product`, plus OPPO `my_*` partitions | ColorOS 17 donor ROM |

Everything else = scripted edits on top (build steps), a root init service
with its own SELinux domain, a helper app, and sometimes a custom kernel.

## OPPO/ColorOS services that will be missing on `eqe` (the real "HAL" work)

Derived from the pipa port's step list — treat as a checklist of likely gaps,
not a guaranteed list for your donor:

- `vendor.oplus.hardware.charger.ICharger` (charging/bypass) → adapter or shim
- `oplusSensor`, `urcc`, `hummingbird` (sensor/extensions) → strip from VINTF
  and patch `waitForService` clients, or shim them
- `IOplusTouch` / `IOpenTouch` (game touch modes) → shim mapping to Moto nodes
- `IEngineer`, `ICryptoeng`, `IDisplayPanelFeature`, `IGameOpt`, `IMisc`
- `oplus.hardware.biometrics.face` / face HAL → shim or disable
- OPPO display HALs (VF/Game Filter), `oplus_vrr_config.json`, QDCM
- OPPO audio effects (AudioX/OReality, Dolby, Sound Trigger), Breeno voice wake
- OPPO `fingerprint` HAL and `oplus-services.jar` dependencies
- OPPO interconnect / virtual SIM / OShare stack
- OPPO kernel nodes `/proc/oplus_*`, `/sys/.../oplus_*`, scheduler `sched_assist`,
  frame boost, Hans freezer — Moto kernel won't have them; sometimes absent
  (or empty) is the correct answer, sometimes the feature must be disabled.

Common failure mode: `system_server` or SurfaceFlinger blocks forever in
`waitForService("...oplus...")` → boot watchdog reset. Fixes used in the pipa
port: binary-patch `waitForService` → `checkService`, or provide a shim service.

## Collected resources (local copies)

All under `/sdcard/port/reference/`:

| Local path | Source | Why |
|---|---|---|
| `reference/pipa-cos17-port/` | [Stefan-Atanasov/pipa-cos17-port](https://github.com/Stefan-Atanasov/pipa-cos17-port) | **Read this first.** Complete, documented ColorOS 17 port with build scripts, 100+ fix steps, SELinux/HAL shims, flash tooling |
| `reference/oppo_decrypt/` | [bkerler/oppo_decrypt](https://github.com/bkerler/oppo_decrypt) | Decrypt Oppo `.ofp` (QC + MTK) and OnePlus `.ops`; wired into `tools/scripts/ofp-extract.sh` |
| `reference/OppoDecrypt/` | [unix3dgforce/OppoDecrypt](https://github.com/unix3dgforce/OppoDecrypt) | Alternative `.ofp`/`.ops` decryptor with library extraction |
| `reference/android_device_motorola_eqe/` | [kinguser981/android_device_motorola_eqe](https://github.com/kinguser981/android_device_motorola_eqe) | `eqe` device-tree reference (TWRP-era), partition layout & fstab hints |
| `reference/chargehal-oplus/` | [LazyBonesLZY/chargehal-oplus](https://github.com/LazyBonesLZY/chargehal-oplus) | Rust/NDK adapter implementing `vendor.oplus.hardware.charger.ICharger` on non-Oppo hardware — exact class of shim this port needs |

Not cloned (too large, ~1 GB) but essential reference:

- [toraidl/coloros_port](https://github.com/toraidl/coloros_port) — automated
  ColorOS/OxygenOS porting for OnePlus 8/9 and Find X3; covers Android 14–17.
  Uses BypassSignCheck, TIK/contextpatch, fspatch, lpunpack, miui_port.
- [ColorOS_Port_Co-create](https://github.com/xwdy114514/ColorOS_Port_Co-create) —
  OnePlus 8/8T/9-series ColorOS 14–16 porting project.
- [daxiaamu/ColorOS-16-17-Port-for-8T](https://github.com/daxiaamu/ColorOS-16-17-Port-for-8T) —
  per-device port "skills" including camera HAL guard and in-place smali patches.
- [MotorolaMobilityLLC/kernel-msm](https://github.com/MotorolaMobilityLLC/kernel-msm) —
  official kernel; `eqe` source still missing (issues above).
- XDA guide: [porting OEM ROMs (ColorOS/OxygenOS/HyperOS)](https://xdaforums.com/t/how-to-port-hyperos-coloros-oxygenos-xperiaui-myui-pixel-and-more-on-linux-wsl-on-windows-11-android-12.4799692)

## Reading order in the pipa reference

1. `PORTING-GUIDE.md` — the model, workflow, order of work, gotchas
2. `ARCHITECTURE.md` — partition table, every fix step, shims, service, SELinux
3. `BUILD.md` — host tools, inputs, build/flash/rollback
4. `HANDOFF-FROM-ZERO.md` — rebuilding from scratch
5. `BLOBS.md` — which proprietary blobs are unavoidable and where they came from
6. `GOTCHAS.md`, `BUGS.md` — the expensive mistakes
7. `maintainer/halshims/`, `maintainer/sepolicy/`, `port-rom/pipa_port/` —
   the actual shim/service implementations

## What is still missing before real work can start

- **Which ColorOS 17 ROM exactly?** Device model, region, build number, and
  whether it is `.ofp`, `.ozip`, `payload.bin` or a ZIP. The donor SoC decides
  how much of the system side is reusable.
- **Working `eqe` base image set** with matching kernel/firmware (stock is
  safest; a known-good custom ROM vendor also works). Must be pinned by md5.
- **A Linux build host with 100+ GB** — the phone can *inspect* and *prepare*
  files, but building `super.img` (erofs + lpmake) and compiling shims really
  wants a proper Linux machine/WSL. This environment can still do a lot of
  the extraction, patching and analysis.

Tell me the donor ROM filename/model and I'll map the exact HAL gaps for that
build, extract it, and set up the first reproducible build steps.
