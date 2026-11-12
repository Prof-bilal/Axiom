# ADR 025: Boot UI (Plymouth splash, hidden boot menu)

Status: Accepted for the Phase 6 polish track, implemented but not yet verified in QEMU.

## Context
The installed system boots with systemd-boot (`installer/axiom_install.py` `build_config`). systemd-boot
cannot draw images or themes, so a graphical boot menu would need a different bootloader. Omarchy, the
reference, uses a UKI and a Plymouth script theme with a fake progress bar.

## Decision
- Keep systemd-boot. Hide its menu (`timeout 0`, `editor no`); hold Space is not wired, so recovery uses
  the firmware boot menu or the live ISO.
- Show a Plymouth `axiom` theme (`iso/phase3/airootfs/usr/share/plymouth/themes/axiom/`): penguin
  with a gentle bob, a real boot-progress bar (`Plymouth.SetBootProgressFunction`), and a visible LUKS
  passphrase prompt (`SetDisplayPasswordFunction`). No fake progress.
- Add `plymouth` to the installer package list and the `plymouth` mkinitcpio hook after `kms`, then rebuild
  the initramfs with `plymouth-set-default-theme -R axiom` in the target.
- Live ISO BIOS menu uses an Axiom syslinux splash (`iso/profile/syslinux/splash.png`).

## Consequences and limits
- Boot menu is hidden on installed systems. Recovery depends on the firmware menu or the live ISO.
- Theme setup is a soft failure: if Plymouth cannot be configured the installer logs it and the system
  boots to the text console. The LUKS prompt then uses the plain prompt.
- Not yet verified: Plymouth script API calls (`Math.Sin`, `Image.Rectangle`) were written without a
  running Plymouth; the QEMU boot test and screenshots of the LUKS prompt are required before this is Accepted.
- The mkinitcpio edit is a text substitution on the `kms` hook; it assumes archinstall's default HOOKS layout.

## Rollback
Remove `plymouth` from the package list and the `boot_splash()` call. The system then boots as before.

Related: [[024-graphical-greeter]], `docs/updatephase6.md`.
