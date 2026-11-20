# Phase 6 UI update: boot, login, installer

Status date: 2026-11-11. Single source of truth for the boot, login and installer UI work.

## Context
Boot, login and installer screens were text-mode (curses). Goal: a clean graphical look with a penguin
and animation, in the style of the lock screen (`shell/src/session/LockScreen.qml`).
Reference: Omarchy 4.0.6 (`/usr/share/omarchy/`). Its progress bar is faked and it boots a UKI; we do neither.

Repo facts:
- The installed system uses systemd-boot without a UKI (`installer/axiom_install.py`, `build_config`).
  systemd-boot cannot show images, so the visible boot screen is a Plymouth splash.
- The live ISO boots BIOS via syslinux and UEFI via systemd-boot (`iso/profile/profiledef.sh`).
- Two ISO profiles: `iso/profile` (Phase 6) and `iso/phase3` (graphical session). Both need the
  Plymouth changes. `scripts/build-phase3-iso.sh` builds the phase3 profile.
- Penguin source: `shell/assets/axiom-penguin.png` (96x96 RGBA).

## Status
- Phase 1, Plymouth splash: code and unit tests done. Not built, not booted.
- Phase 2, boot menu: code and unit tests done. ISO built (`axiom-2026.11.09`, built 2026-11-11 10:11).
  Headless QEMU test 2026-11-11 (`/tmp/axs/new`, screendumps at 8/20/40/60 s, serial log kept):
  - Live UEFI menu shows "Install Axiom / Axiom Live Desktop / ..." with the 15 s countdown (screenshot
    `/tmp/axs/new/shot-8s.png`). Expected: live medium keeps the visible menu.
  - Screen is fully black at 40 s and 60 s (max brightness 0). The live medium's initramfs has no
    `plymouth` hook, so the Axiom theme is not loaded on the live ISO. The Axiom splash was added only
    to the installed system. Live splash is NOT implemented (plan Phase 2 item 2 is partly done).
  - Serial: `Show Plymouth Boot Screen` OK, `Show Plymouth Power Off Screen` OK, system reached user
    login and clean poweroff.
  - Failed unit `Attach File /sys/d…block/sr0 to Loopback Block Device`: also present in the previous
    ISO `axiom-2026.11.06` (`/tmp/axs/old/serial.log`), so it predates this change (not caused by Phase 1–2).
  - Previous ISO has zero Plymouth lines in its serial log; new ISO has Plymouth services.
  - Not verified: Axiom splash image and LUKS prompt on the installed system (needs an install in
    QEMU, which needs root for the ISO build and an install run). Login screen rendering (not on the live
    boot path, needs greetd).
- Login UI rebuild (lock-screen style, penguin): planned, not implemented.
- Phase 3, QML installer: not started. Waiting on the privilege-model decision.
- Phase 4, docs: ADR 025 written, research doc corrected. `docs/PHASES.md` not updated.
- Phase 5 and regression: not run.
- Tests: `pytest tests` passes 71 of 71 (last run). `validate-repo.py`: 0 errors.

## Phase 1: Plymouth splash
Done in code:
- Theme `axiom` at `iso/phase3/airootfs/usr/share/plymouth/themes/axiom/` (`axiom.plymouth`,
  `axiom.script`, `logo.png`). Penguin bob, real boot-progress bar
  (`Plymouth.SetBootProgressFunction`), visible LUKS passphrase prompt
  (`SetDisplayPasswordFunction` / `SetDisplayNormalFunction`).
- `plymouth` in `BASE_PACKAGES` (`installer/axiom_install.py`) and in both `packages.x86_64` files.
- `/usr/share/plymouth/themes/axiom` in the overlay copy list.
- `boot_splash()` run from `post_install()`: adds `plymouth` to mkinitcpio HOOKS after `kms`, runs
  `arch-chroot <target> plymouth-set-default-theme -R axiom`. On failure it logs and continues
  (soft failure: the text console still boots).

Not verified:
- Plymouth script API calls (`Math.Sin`, `Image.Rectangle`, `Image.Text`) were written without a running
  Plymouth. A wrong call shows as a blank or broken splash.
- LUKS prompt on the splash, in QEMU.
- Initramfs rebuild in the installed target.

## Phase 2: Boot menu
Done in code:
- Installed system: `loader.conf` gets `timeout 0` and `editor no`; `quiet splash` is appended once to
  every `options` line in `boot/loader/entries/` (`boot_splash()`).
- Live ISO BIOS: `iso/profile/syslinux/splash.png` replaced with a 640x480 Axiom splash (penguin on dark
  background), generated with Pillow from `shell/assets/axiom-penguin.png`.
- Live ISO UEFI: unchanged (systemd-boot, 15 s timeout).
- Recovery: menu hidden, so recovery uses the firmware boot menu or the live ISO. The "hold Space to show
  the menu" idea from the first plan was not implemented.

Not verified:
- syslinux splash on a real BIOS boot.
- Menu actually hidden on the installed system.

## Login UI rebuild (lock-screen style, penguin)
Decided by the user on 2026-11-11: the current freebuff login UI (`greeter/qml/shell.qml`) is rejected.
Keep the lock-screen look: dark background, centered penguin, password field, error text below.

Plan:
1. Reuse `Theme.qml` colors from `shell/src/shared`. Do not copy them.
2. Rewrite the visual layer of `greeter/qml/shell.qml`: penguin (about 120 px, from
   `shell/assets/axiom-penguin.png`), user name, password field, message line.
3. Bob animation (about 6 px, about 2 s period), the same as the Plymouth splash.
4. Keep the reviewed greetd wiring: `Greetd.createSession`, `respond`, `launch`, and the `authFailure`
   and error handling.
5. Rules unchanged: password only goes to `Greetd.respond()`, never logged or stored. Only local human
   accounts. Wrong password shows "That password didn't work. Try again." Curses fallback stays.
6. Checks: `qmllint` if available, `pytest tests`, `validate-repo.py`.

Status (2026-11-11): implemented in `greeter/qml/shell.qml` (visual layer rewritten; greetd wiring
kept). Penguin PNG copied to `greeter/qml/assets/axiom-penguin.png`. Bob animation is a
SequentialAnimation (about 6 px, 2 s period). Left/Right switch accounts when there is more than one.
Checks: `qmllint` shows only Quickshell-type warnings (no errors from our code); `pytest tests`: 71 pass.
Not verified: the rendered screen (no display in this run). Needs a QEMU screenshot of the login screen.

## Phase 3: QML installer (reverted, not active)
Status (2026-11-11): the Phase 3 installer work was reverted at the user's request. The curses installer
stays the live installer. The login UI rebuild (lock-screen style, penguin) stays.

What was moved out of the active tree to `docs/handoff/phase3-wip/` (kept for later):
- `axiom_installd.py` (root socket backend), `axiom-installer-gui` (labwc launcher)
- `qml/shell.qml` and `qml/assets/` (installer UI)
- `tests/test_installd.py` (daemon tests)
- `026-installer-privilege.md` (ADR draft)

What was reverted in the active tree: `axiom-installer.service` (root curses installer again),
`axiom-installd.service` and `axiom-installer-tui.service` removed, `axiom-install` group lines removed from
`customize_airootfs.sh`, build and profile lines for the installer GUI and daemon removed.

Not verified: a full install of the curses installer on the current ISO is not part of this revert.

## Phase 4: Docs
Done:
- `docs/decisions/025-boot-ui.md` (ADR 025; 024 is the graphical greeter).
- `docs/research/boot-ui-plan.md` corrected (no GRUB).

Not done:
- `docs/PHASES.md`: add a Phase 6 sub-section for this work. Note that "Phase 3" here means the QML
  installer step, which is different from the old "Phase 3 Axiom Shell MVP" in PHASES.md.

## Phase 5 and regression
- Regression for Phases 3, 4 and 5 means running `tests/phase3-*.py`, `tests/phase4-apps.py` and
  `tests/phase5-system.py` against the new ISO after every UI change.
- Not run yet. Needs a built ISO and a QEMU run.

## Verification (user runs these; root is needed)
1. `pytest tests` and `python3 scripts/validate-repo.py` (Claude can run these).
2. `sudo scripts/build-phase3-iso.sh` (phase3 profile with the Plymouth changes).
3. `tests/qemu-boot.sh` on the built ISO: screenshots of the splash and the LUKS prompt, serial and
   journal retained, `journalctl -b -u plymouth-start` checked.
4. `tests/phase6-install.py`: full install including the LUKS path, passphrase accepted at boot.
5. Login: right password and wrong password; screenshot the lock-style screen.
6. Fallback: disable the theme and confirm the system still boots to the text console.
7. Boot time with and without Plymouth (`systemd-analyze`) before claiming no slowdown.
8. Phase 3, 4 and 5 regression scripts on the same ISO.

## Risks
- LUKS prompt hidden by the splash. Highest risk; explicit test in step 4.
- Plymouth script API mistakes only show up on a real boot.
- Both ISO profiles must stay in sync.
- Plymouth depends on the virtual GPU under QEMU; check virtio-gpu and a plain framebuffer.
- Phase 3 depends on the privilege decision and the login rebuild.

## Next steps
1. User chooses the Phase 3 privilege model (1, 2 or 3).
2. Claude implements the login UI rebuild (from step 2).
3. User runs the build and QEMU checks above and sends the output.
4. Claude fixes what the output shows, then starts Phase 3.

## Decision (user, 2026-11-11): installer stays curses (phase6 base)
- The live ISO runs the curses installer again (`axiom-installer.service` -> `/usr/local/bin/axiom-installer`, root).
- The QML installer, the root daemon and the GUI launcher are parked in `docs/handoff/phase3-wip/`. They are not in the build.
- Base is the phase6 curses installer (`origin/phase6`, commit `0150c22`) plus the Part A pick-lists and the Plymouth changes already in the tree.
- Login screen stays QML (greetd greeter): penguin on top, big Axiom wordmark, password field below.
- Open: improve the curses look (logo, wordmark) without changing its flow.
