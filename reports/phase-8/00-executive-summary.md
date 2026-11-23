# Axiom pre-Phase-8 executive summary

Date: 2026-11-23. Synthesis of reports 01 to 05 in this directory. Audit and research only; no source code was changed and Phase 8 has not started.

**Evidence labels.** *Verified* = I re-checked it in the repo myself. *Reported* = a subagent's claim I did not re-check. Report 03's measurements come from a 2026-11-14 work tree. Report 04's comparisons with distros other than Omarchy come from general knowledge, not fetched pages. Report 05's web research is search-summary level.

## 1. Health assessment

**Fair: a sound core with real gaps in the installed system.** The unit tests (106) and ISO profile check pass (reported). The narrow root helper `axiom-pkgd` has a solid design (reported). I found no exploitable injection and no secrets in tracked files (reported). The weak points are that the installed system diverges from the live ISO, CI proves little, and docs overstate what exists.

## 2. Critical issues (all from report 01 unless noted)

| # | Issue | Status |
|---|---|---|
| H1 | `BASE_PACKAGES` in `installer/axiom_install.py` omits `grim`, `wf-recorder`, `wl-clipboard`, `minisign`, `bubblewrap`, `flatpak`, `distrobox`, `podman`, `polkit-gnome`, so installed systems lose screenshots, recording, AppImage checks and Hub podman items | Verified (list read) |
| H2 | Polkit rules 50, 51 (and 52) match only user `axiom`, which the installer reserves, so Settings and power actions never authorize on an installed system | Verified (rules read) |
| H3 | Signature trust root `axiom.pub` is not shipped; `LocalFileSigLevel = Optional` plus `pacman -U` means an unsigned package installs as root after an admin prompt | Reported |
| H4 | `axiom-pkgd sync` runs `pacman -Sy <pkg>` (`system/pkgd/axiom-pkgd:70`), an unsupported partial upgrade with no snapshot | Verified |
| H5 | Rollback does not restore `/boot` (FAT ESP), so a kernel update then rollback leaves kernel and modules mismatched; ADR-033 is silent on it | Reported |
| H6 | CI runs only the validators, none of the 106 tests; the validator was red on Phase 7 until this session's merge | Reported; the validator now passes locally |

Medium, from the same report: the live image's empty-password `wheel` user with `sshd` allowing root login (not confirmed exploitable); docs and code disagree on the default compositor; ADRs 030-035 still say "Proposed" although code exists; `remove` has no protected-package list.

## 3. Most valuable optimizations (report 03; estimates, not measurements)

- **Verified:** the host disk is 90% full, mostly `iso/out-phase3-fix/evidence` (56 GB). Clean this before any build work.
- **Reported:** the ISO is 2350 MiB. Of that, `airootfs.sfs` is 1767 MiB, and the initramfs is stored twice (about 500 MiB combined with the kernel). About 147 MiB of the initramfs is firmware pulled in by the `kms` hook.
- **Reported:** `code` plus `electron42` is 1.1 GiB of the build rootfs, and the installed system doesn't include it.
- **Reported:** a build takes about 21 minutes (11 of them xz squashfs), and the work dir is wiped every run.
- **Quick wins:** drop `code`, drop PXE hooks and bcachefs from the initramfs, `NoExtract` for docs, a zstd dev profile, and keeping the work dir and package cache. Report 03 estimates 1.3 to 1.5 GiB and 6 to 12 minutes; nothing has been measured.
- **Not worth doing:** firmware pruning without a hardware matrix, EROFS, replacing the boot chain.

## 4. Missing essential features (report 04, grep-checked by the agent)

No idle lock or lock-before-suspend, no firewall, no removable-media automount, no printing, no default image/video/PDF viewers, no keyring, no IME or emoji picker, accessibility limited to text size, `/home` not backed up, no fwupd or update notifier. Likely screen-sharing bug: the package list has `xdg-desktop-portal-wlr` but not `xdg-desktop-portal-hyprland` (package list read; behaviour untested). Report 04 added these to Phases 8, 9, 10 and 13 in `docs/PHASES.md`.

## 5. Differentiation (report 05)

- **Real today:** `axiom-pkgd` (polkit-gated, argv-only, snapshot before update), the unified installer front-end, and QEMU evidence per phase.
- **Design only:** the AI layer, Warden and Flow. The `ai/`, `services/` and `security/` directories don't exist.
- **Overclaims to fix:** Hub "Install verified: 81" (a command check, not an install), scripted landing-page demos, "Axiom owns the compositor".
- **Positioning:** report 05 suggests "every system change is typed, attributed and undoable" instead of "AI-native". I agree it is the defensible claim, but that is a product decision for you.

## 6. Conflicts and tensions between reports

1. **Untracked artifact size:** report 01 says 77 GB, report 02 says about 3 GB under `iso/`. The 56 GB `out-phase3-fix/evidence` directory likely explains the gap; unreconciled.
2. **Rescue medium vs lean ISO:** report 03 wants to prune about 250 MiB of inherited rescue tools, while report 04 wants recovery media that repairs a non-booting system (Phase 13). Resolve before pruning.
3. **Slimming vs completing:** report 03 cuts packages while reports 01 and 04 need about a dozen added (H1, viewers, portal, firewall, udisks, CUPS). The net ISO will be larger than report 03's estimate.
4. **Default compositor:** labwc vs Hyprland disagree across `/etc/axiom/compositor`, `axiom-session` and ADR-031 (report 01); report 03 notes its measurements predate Hyprland. Decide first, since it changes both the portal fix and the performance baseline.
5. **Rollback scope:** report 04 flags "rollback works only while the system boots" and report 01's H5 says `/boot` isn't covered. One fix (kernels inside the snapshotted root, or a boot-time snapshot path) closes both.

## 7. Dependencies

- Compositor decision before portal fix, performance baseline and ADR reconciliation.
- H1 package fix before any claim that Capture, AppImage or Hub podman work when installed.
- H5 and the `/boot` design before expanding rollback or update features.
- H3 trust-root decision before the Hub installs anything on the user's behalf.
- Disk cleanup before baselines or builds.
- Baseline measurements before any optimization is accepted.

## 8. Phase 8 readiness: not ready

The roadmap now holds the right Phase 8 content, but these should land first:

1. Fix H1 (package parity) and H2 (polkit user match), then test both in QEMU on an installed system.
2. Fix H4 (`sync`) and decide the H3 signature policy.
3. Design the H5 `/boot` rollback gap (an ADR plus a kernel-bump rollback test).
4. Make CI run the node tests and the ISO profile check.
5. Decide the default compositor and set ADR statuses to match reality.
6. Correct the Hub "verified" wording and the landing-page claims.
7. Free disk space and take baseline measurements.

Everything else in the reports can wait for Phases 8 to 13 as scheduled in `docs/PHASES.md`.

## 9. Should be avoided or removed

Per reports 03 and 05: GTK-app replacement for size, aggressive firmware pruning, new daemons for the AI layer before the capability and audit spine exists, and any marketing that implies a working policy engine or sandbox.

## 10. Git state

Phase 7 plus `origin/main` is merged and pushed (`0a24aa8`). Archive tags exist and nothing was deleted. See `02-git-management.md`. Still open: `worktree-ui-glass-restyle` (11 unique commits), the unpushed local `axiom` commit, worktree cleanup, the `.contextgit/context.md` deletion, and a CI result for the merge commit.

## 10a. Decision recorded

2026-11-23: the user chose **Hyprland** as the default compositor. labwc stays as a fallback. Code and ADR-031 still need to be aligned with this (not yet done).

## 11. Next steps (for your approval)

Approve the "before Phase 8" list above, in particular the compositor decision, since it blocks the most other work. Nothing here starts without that approval.
