# Handoff: boot UI, Phases 1-2 (Plymouth splash, boot menu)

Plan: `docs/updatephase6.md` (read Phases 1 and 2 only). Decision: keep systemd-boot, hide its menu,
show a Plymouth splash. systemd-boot cannot show images, so there is no graphical boot menu on the
installed system. Do not add GRUB.

## Hard rules
- No new privileges, no sudo, no root in any UI. Plymouth runs from initramfs; do not add daemons.
- LUKS passphrase prompt must stay visible and usable through the splash. If you cannot make it
  work, stop and report. Do not ship a splash that hides it.
- Plymouth failure must fall back to the plain text console; the system must still boot.
- Use the existing Axiom palette from `tui/axiom_tui.py` (BG, CYAN, TEXT) and the penguin in
  `shell/assets/axiom-penguin.png`. Do not invent a new penguin.

## Owned files (edit only these)
- New theme: `iso/phase3/airootfs/usr/share/plymouth/themes/axiom/` (`axiom.plymouth`, `axiom.script`,
  images)
- `iso/phase3/packages.x86_64` and `iso/profile/packages.x86_64`: add `plymouth` only
- `iso/phase3/airootfs/etc/mkinitcpio.conf.d/` and `iso/profile/airootfs/etc/mkinitcpio.conf.d/`:
  plymouth hook, placed before any encrypt hook
- `installer/axiom_install.py`: add `plymouth` to the package list (around line 43), add the theme
  to the copy list (around line 50), set `quiet splash` on the installed entry, set loader.conf
  `timeout 0` and `editor no`. Follow the pattern of `propagate_console()` (around line 320).
- `iso/profile/syslinux/` (Phase 2): replace `splash.png` with an Axiom background, same size
- `tests/installer/` new tests for the installer changes
- Do not touch `greeter/`, `shell/`, `docs/decisions/`, or the QML installer.

## Steps
1. Plymouth theme `axiom`. Static wordmark and penguin first; get that booting.
2. Animation: penguin waddle in the refresh callback. Progress bar bound to real boot progress
   (`Plymouth.SetBootProgressFunction`). Do not fake progress.
3. LUKS: implement the password display functions so the prompt is visible and accepts input.
4. Packages, mkinitcpio hook, kernel params (`quiet splash`) on both ISO and installed system.
5. Phase 2: loader.conf and syslinux splash.

## Acceptance criteria
- `python3 scripts/validate-repo.py` passes.
- `pytest tests` passes (run from repo root with `pytest tests`, not `python -m pytest` at the root).
- `python3 scripts/check-iso-profile.py` passes for the profile you changed.
- Unit tests cover the installer changes (loader.conf content, quiet splash, package list).

## Testing you cannot do (the user runs these; list what is needed in your report)
- `sudo scripts/build-phase3-iso.sh` (or the Phase 6 build)
- `tests/qemu-boot.sh`: capture screenshots of the splash and the LUKS prompt, and retain serial
  and journal (`journalctl -b -u plymouth-start`).
- Fallback: disable the theme and confirm the system still boots.

## Report back with
- `git diff --stat` and the full diff of owned files.
- Output of the test commands above.
- Anything not verified, stated plainly. Do not commit.
