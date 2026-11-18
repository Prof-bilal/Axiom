# Phase 7 end-to-end test plan

Goal: prove, in QEMU on an installed btrfs system, that a user can install, update and remove a
package from the Software Center, and roll back after a bad update (PHASES.md Phase 7 exit).
Evidence is kept under `iso/out-*/evidence/` with serial logs, screenshots and sha256 sums.

## Preconditions
- ISO built from the default profile (`scripts/build-phase3-iso.sh`, sudo).
- Installer run (`tests/phase6-install.py` or the installer UI) to a blank virtio disk of at least
  20 GB: btrfs root with @, @home, @log, @pkg, @snapshots (installer/axiom_install.py build_config).
- `SNAPPER_SETUP` ran on first boot: `snapper -c root list` works for the desktop user (or the
  helper runs it as root).
- Guest has network (user-mode) for pacman and Flathub.

## Steps
1. **Install from the UI:** Software Center > Applications > install a small package (e.g. `htop`)
   through the App Installer or the Hub. Check `pacman -Q htop` and the menu entry.
2. **Flatpak:** Software Center > Flatpak apps > install `org.gnome.Calculator` from Flathub;
   check `flatpak list --user`; update it; remove it.
3. **Snapshot exists:** Software Center > Snapshots shows at least one snapshot (`before update`).
4. **Update:** Software Center > Updates > Update all. Admin approval (polkit, action
   `org.axiom.installer.update`). Check a new snapshot "before update" and the pacman log.
5. **Remove:** Software Center > All packages > remove `htop`; check `pacman -Q htop` fails.
6. **Bad update (controlled):** install a local test package that overwrites a file under
   `/usr/lib/axiom-test/` with a known bad value, after a snapshot; then roll back to the
   snapshot from step 4 (Software Center > Snapshots > Roll back, then Confirm; admin approval
   with action `org.axiom.installer.rollback`). Reboot. Check the file is back to its earlier value.
7. **Negative checks:**
   - a non-admin approval is refused for update and rollback (polkit prompt cancelled);
   - `axiom-pkgd update` on the live ISO (ext4, no snapper config) is refused with exit 3;
   - an invalid snapshot number or description is refused by the helper (`tests/apps/pkgd.test.mjs`).

## Automation
- `tests/phase7-hub-apps.py` covers step 1's install, launch and remove for the Hub app list.
- A new `tests/phase7-update-rollback.py` (to write) drives steps 4 to 6 over the serial root shell
  (as `tests/phase6-install.py` does), with network enabled and screenshots for evidence.
- Unit tests: `node --test tests/apps/` (pkgd, software-logic, installfile-logic).

## Pass criteria
- Every step above passes, with the evidence files present.
- No QML errors in the shell log.
- The helper refuses every negative case.

## Known gaps to close before the test runs
- Snapshot listing needs `snapper` to be readable by the desktop user; if not, the list stays
  empty and the test must use the root shell for step 3.
- Flatpak needs network and the Flathub remote; offline runs skip step 2.
