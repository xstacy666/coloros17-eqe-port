# Vendor / HAL comparison — Donor (Nord CE6 ColorOS 17) vs Target (Moto Edge 50 Pro eqe)

Generated 2026-11-26. Donor extracted from `Nord ce 6/payload.bin` (ColorOS 17, CPH2805_17.0.0.101, Android 17). Target extracted from device (Android 16, SM7550-AB).

## SoC reality check
- Donor: Qualcomm Snapdragon 7s Gen 4 (SM7635-class) — `ro.board.platform` = `pineapple`-ish mid-range
- Target: Snapdragon 7 Gen 3 (SM7550-AB) — `pineapple`-ish

## Port model (unchanged)
- Keep TARGET (Moto) side: `boot`, `vendor_boot`, `dtbo`, `vbmeta*`, `vendor`, `vendor_dlkm`, `system_dlkm`, `modem`, `bluetooth`, `dsp`, `persist`, firmware.
- Take DONOR (ColorOS) side: `system`, `system_ext`, `product`, plus OPPO `my_*` partitions (`my_product`, `my_heytap`, `my_stock`, `my_carrier`, `my_region`, `my_bigball`, `my_engineering`, `my_manifest`).
- Bridge the gaps with shims / VINTF cleanup / props / SELinux.

## Manifest file counts
| Location | Donor (Nord CE6 COS17) | Target (Moto eqe) |
|---|---|---|
| vendor/etc/vintf/manifest/*.xml | 60 | 68 |
| odm/etc/vintf (manifest files) | 46 | 6 (generic manifest_b/bf/bs/d/df/ds) |
| system/etc/vintf/manifest/*.xml | ~20 (AOSP standard) | ~20 (AOSP standard) |

## OPPO services declared by donor (odm manifests) — 34 total
These are the services ColorOS system calls. The Moto vendor implements **none** of them. Each is a potential `waitForService` hang → boot watchdog reset if not handled.

| OPPO service | Manifest | Action needed |
|---|---|---|
| `vendor.oplus.hardware.charger.ICharger` | manifest_oplus_charger_aidl.xml | **Shim** — chargehal-oplus adapter exists (reference/chargehal-oplus) |
| `vendor.oplus.hardware.touch.IOplusTouch` | manifest_touch_aidl.xml | **Shim** — map to Moto touch nodes (IOpenTouch) |
| `vendor.oplus.hardware.displaypanelfeature.IDisplayPanelFeature` | manifest_oplus_displaypanelfeature_aidl.xml | **Shim or strip** — Moto has `com.motorola.hardware.display.touch` |
| `vendor.oplus.hardware.display.MixLut3D.IMixLut3D` | (odm) | **Shim or strip** |
| `vendor.oplus.hardware.displaycolorfeature.IDisplayColorFeature` | (vendor) | **Strip** (OPPO color feature) |
| `vendor.oplus.hardware.cryptoeng.ICryptoeng` | manifest_oplus_cryptoeng.xml | **Shim** (crypto/TEE) |
| `vendor.oplus.hardware.misc.IOplusMisc` | manifest_misc_aidl.xml | **Shim** (misc props) |
| `vendor.oplus.hardware.gameopt.IGameOptHalService` | manifest_oplus_gameopt.xml | **Strip** (game mode) |
| `vendor.oplus.hardware.performance.IPerformance` | manifest_performance_aidl.xml | **Strip or shim** |
| `vendor.oplus.hardware.cwb.ICwbService` | manifest_oplus_cwb_aidl.xml | **Strip** |
| `vendor.oplus.hardware.handlefactory.IHandleFactory` | manifest_oplus_handlefactory... (vendor) | **Strip** |
| `vendor.oplus.hardware.riskdetect.IRiskDetect` | manifest_oplus_riskdetect.xml | **Strip** |
| `vendor.oplus.hardware.sendextcamcmd.ISendExtCamCmdService` | manifest_oplus_sendextcamcmd.xml | **Strip** (camera ext) |
| `vendor.oplus.hardware.cammidasservice.IMIDASService` | manifest_oplus_cammidasservice_aidl.xml | **Strip** |
| `vendor.oplus.hardware.camera_rfi.ICameraRfiService` | manifest_oplus_camera_rfi.xml | **Strip** |
| `vendor.oplus.hardware.oplusSensor.ISensorFeature` | manifest_oplusSensor_aidl.xml | **Strip from VINTF** + patch waitForService clients (pipa step 4q) |
| `vendor.oplus.hardware.urcc.IUrcc` | vendor.oplus.hardware.urcc-service.xml | **Strip** (sensor extensions) |
| `vendor.oplus.hardware.hummingbird.IOplusHmbirdService` | (vendor) | **Strip** |
| `vendor.oplus.hardware.virtual_device.audio.IStatusProvider` | manifest_oplus_virtualdevice_audio_aidl.xml | **Strip** |
| `vendor.oplus.hardware.binaural_record` | (vendor) | **Strip** |
| `vendor.oplus.hardware.location.IOplusLocation` | manifest_oplus_location_aidl.xml | **Shim or strip** |
| `vendor.oplus.hardware.esim.IOplusEsim` | manifest_oplus_esim.xml | **Strip** (virtual SIM) |
| `vendor.oplus.hardware.nfc` / `nfcExtns` | manifest_oplus_nfc*.xml | **Strip** (Moto has its own NFC) |
| `vendor.oplus.hardware.fido.fidoca` / `fido2ca` | manifest_oplus_fido*.xml | **Strip** |
| `vendor.oplus.hardware.ifaa` | manifest_oplus_ifaa.xml | **Strip** |
| `vendor.oplus.hardware.biometrics.fingerprintpay.IFingerprintPay` | (odm) | **Strip** |
| `vendor.oplus.hardware.biometrics.face` | manifest_oplus_face.xml | **Strip** (face unlock) |
| `vendor.oplus.hardware.fingerprint` (aidl v3) | manifest_oplus_fingerprint_aidl_v3.xml | **Shim** — map to Moto goodix fingerprint |
| `vendor.oplus.hardware.ims.IImsStable` | manifest_oplus_ims... (vendor) | **Shim** (telephony) |
| `vendor.oplus.hardware.radio.IRadioStable` | (vendor) | **Shim** (telephony) |
| `vendor.oplus.hardware.subsys_interface.subsys` / `subsys_radio` | device_manifest_subsys.xml | **Shim or strip** |
| `vendor.oplus.hardware.communicationcenter.IDmtpService` | device_manifest_communication_center_aidl.xml | **Strip** |
| `vendor.oplus.hardware.transfer.ITransfer` | manifest_transfer.xml | **Strip** |
| `vendor.oplus.hardware.transmessage.ITransmessge` | manifest_transmessage_aidl.xml | **Strip** |
| `vendor.oplus.hardware.power.powermonitor.IPowerMonitor` | manifest_powermonitor_aidl.xml | **Strip or shim** |
| `vendor.oplus.hardware.rpmh.IRpmh` | manifest_rpmh_aidl.xml | **Strip** (RPMh is SoC-specific) |
| `vendor.oplus.hardware.wifi.IOplusWifiService` / `supplicant` | oplus_aidl_wifi_service_device_manifest.xml | **Strip** (Moto has its own wifi) |
| `vendor.oplus.hardware.olc2.IOplusLogCore` | vendor.oplus.hardware.olc2_aidl.xml | **Strip** (logging) |
| `vendor.oplus.hardware.urcc.IUrcc` | vendor.oplus.hardware.urcc-service.xml | **Strip** (sensor extensions) |
| `vendor.oplus.hardware.charger` (already listed) | — | — |

## Moto-specific services (target only) — KEEP, do not remove
- `com.motorola.hardware.display.touch` (touch overlay)
- `motorola.hardware.haptic`, `motorola.hardware.input`, `motorola.hardware.power`, `motorola.hardware.sxf`, `motorola.hardware.fdrcontrol`
- `vendor.goodix.hardware.biometrics.fingerprint` (fingerprint HAL)
- `vendor.arcsoft.hardware.camera.postproc` (camera post-proc)
- `vendor.dolby.dms` / `vendor.dolby.media.c2` (Dolby audio)
- `vendor.zuialarm.hardware.alarm`

These must survive the port — the ColorOS system won't reference them directly, but they must remain registered so the Moto vendor stays functional.

## Standard/common HALs (present on both) — NO work needed
AOSP/QTI standard HALs: audio, camera (base), display composer, DRM, GNSS, health, keymint, NFC, radio, sensors, thermal, USB, wifi, vibrator, bluetooth, gralloc, etc. These are SoC-standard and already compatible at the interface level (both Snapdragon mid-range).

## Easy fixes (no new HAL code)
1. **Props** — patch `ro.product.brand/model/device/name/fingerprint`, `ro.build.fingerprint`, `ro.product.first_api_level` (36), `ro.board.first_api_level` in donor system/product to Moto values. Supply missing `ro.vendor.oplus.*` from `product/etc/build.prop` (ColorOS reads these).
2. **VINTF cleanup** — remove the 34 OPPO service declarations above from the *system-side* manifests so `waitForService` clients don't block forever (pipa step 4q). Keep them declared only if a shim provides them.
3. **waitForService → checkService** — binary-patch `waitForService` calls in `surfaceflinger`/`system_server` where a service can be safely absent (pipa step 2x).
4. **Overlays** — Moto-specific overlays (display, touch, haptic) live in vendor/odm; keep them. ColorOS overlays in `product/overlay` need review but mostly apply.
5. **fstab / mount points** — patch for Moto dynamic-partition layout (product/system/system_ext on super, vendor on super). Already documented in notes/device.md.
6. **SELinux** — compile with `secilc` on a device with full policy; new domains only for shims. Keep enforcing.
7. **Remove OPPO kernel-node dependencies** — `/proc/oplus_*`, `sched_assist`, frame boost references; Moto kernel won't have them. Disable those features cleanly.

## Needs new HALs / shims (significant work)
1. **Charger** — `vendor.oplus.hardware.charger.ICharger` → use `reference/chargehal-oplus` adapter (Rust/NDK). Charging/bypass features.
2. **Fingerprint** — `vendor.oplus.hardware.fingerprint` (aidl v3) → shim to Moto `vendor.goodix.hardware.biometrics.fingerprint`. Face unlock (`biometrics.face`) → shim or disable.
3. **Touch** — `IOplusTouch`/`IOpenTouch` (game touch modes) → shim mapping to Moto touch nodes.
4. **Display panel features** — `IDisplayPanelFeature`, `IMixLut3D`, QDCM/VF/Game Filter → shim or strip. Moto has `com.motorola.hardware.display.touch`.
5. **Crypto engine** — `ICryptoeng` → shim (TEE/RPMB). May be OPPO-TEE-specific; could break.
6. **Misc / Engine** — `IOplusMisc`, `IEngineer` → shim (props + misc).
7. **Display color** — `IDisplayColorFeature` → shim or strip.
8. **Camera extensions** — `camera_rfi`, `cammidasservice`, `sendextcamcmd`, `camera.aon` → strip (OPPO camera extensions). Camera base (Qualcomm) works via Moto vendor.
9. **IMS/Radio** — `IImsStable`, `IRadioStable`, satellite services → shim to Moto QTI radio. High risk (telephony).
10. **Game opt / performance** — `IGameOptHalService`, `IPerformance` → strip (performance hints).
11. **NFC extensions** — `IOplusNfc`, `INfcExtns` → strip (Moto has its own NFC).
12. **Sensor hub** — `ISensorFeature`, `urcc`, `hummingbird` → strip + patch wait sites.
13. **Virtual device audio** — `IStatusProvider` → strip.
14. **OPPO TEE/RPMB** — keymint/weaver extensions may be OPPO-specific → shim or use Moto's (risk to keymaster).

## Strategy recommendation
- Phase 1: VINTF cleanup (remove all 34 OPPO service declarations from system manifests) + props + fstab → attempt first boot. Expect bootloop; fix waitForService hangs.
- Phase 2: Binary-patch waitForService → checkService for non-critical services (surfaceflinger etc.).
- Phase 3: Add shims one at a time (charger, fingerprint, touch, misc) — test each.
- Phase 4: Telephony (IMS/radio) — highest risk; may need Moto's radio stack entirely.
- Phase 5: Camera, audio (Dolby), display tuning.

## Notes
- Donor vendor manifests: 60 (QTI mid-range, fewer than flagship X9 Ultra's 88).
- Target vendor manifests: 68 (Moto adds motorola.*, goodix, arcsoft, dolby, zuialarm).
- `my_*` partitions extracted (8 of them) — contain ColorOS apps/overlays/carrier config; review before merging.
- Donor trees: `$HOME/donor-trees/{system,system_ext,product,vendor,odm}` + `port/donor/trees/my_*`.
- Target trees: `$HOME/stock-trees/{system,system_ext,product,vendor}`.