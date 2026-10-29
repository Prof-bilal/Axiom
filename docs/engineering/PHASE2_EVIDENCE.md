# Phase 2 evidence: Omarchy-derived foundation

Status: **IN PROGRESS — no exit claim.** This record covers the Phase 2 foundation
POC only. It is not evidence for Axiom Shell, AI runtime, security enforcement,
installer release or first-party integration.

## Pinned inputs

| Input | Value |
| --- | --- |
| Omarchy migration base | `omacom/omarchy` tag `v4.0.6` → `237f1b4071a0bff2296c6d740ba2b9fd695ebfa0` |
| Tracking branch | `quattro` `39d56653d649312453316f2536fcfb9982f08fb8` |
| ISO tooling | `omacom/omarchy-iso` `main` `3c36557fd58fe8dcd963f47eb9145f48a543a658` |
| Tracking ISO branch | `quattro` `50832fb585edb1e16cc9b8f6726b13cc3bfecefe` |
| Stable VM image | `https://nightly.omarchy.org/stable/4.0.6/460/omarchy-4.0.6.qcow2` |
| VM image SHA256 | `130144a193494c0510812ac02dbc1218b79de0ad53598eabc41b685907987d9f` |
| VM image size | `4708873728` bytes |
| VM kernel/initrd/cmdline | `workspace/upstream/omarchy-vm/`, SHA256 verified against `SHA256SUMS` |
| Quickshell | `v0.3.2` (`4f508be5`), LGPL-3.0-only |
| Hyprland | `0.56.2`, BSD-3-Clause |

The VM image and kernel/initrd were downloaded into gitignored `workspace/upstream/`.
Upstream source worktrees are detached at the pinned revisions; no upstream code is
tracked in Axiom.

## Host preflight

| Check | Result |
| --- | --- |
| Arch/x86-64 host | PASS (`uname -m`) |
| `/dev/kvm` | PASS |
| QEMU | PASS (`qemu-base 11.1.2-1`; no `virtio-vga`, standard VGA fallback) |
| OVMF | PASS (`edk2-ovmf 202608-1`) |
| Hyprland / Quickshell host packages | PASS (`hyprland 0.56.2-4`, `quickshell 0.3.2.r7.g2b4501a-1`) |
| Existing Phase 1 ISO screenshot smoke | PASS: QMP `screendump` produced a 1280×800 PNG |
| VM image checksum | PASS: `130144a193494c0510812ac02dbc1218b79de0ad53598eabc41b685907987d9f` |

## Phase 2 branding integration

Added under `branding/theme/axiom/`:

- `colors.toml` — graphite/teal palette and Hyprland active-border gradient
- `backgrounds/aurora.svg` + `aurora.png` (3840×2160 original composition)
- `preview.png` (1800×1012)
- `shell.bar.toml`, `shell.lock.toml` — shell surface adjustments
- `branding/identity/axiom-wordmark.svg` + `.png` (800×188; retained identity assets)

This is an Omarchy **user theme**, not Axiom Shell. It changes palette, wallpaper and
branding only; Omarchy's shell widgets remain. A replacement shell is not part
of this reset.

## Harness

- `tests/omarchy-vm-boot.sh` — disposable qcow2 overlay, generated SSH key,
  checksum verification, standard VGA fallback, VNC on localhost and QMP socket.
- `tests/qmp-screenshot.py` — QMP `screendump` to PNG using only the standard library.
- `tests/omarchy-install-axiom-theme.sh` — installs the user theme in a test guest;
  optional test-only SDDM/Plymouth logo replacement.

## Baseline boot — 2026-10-27

Booted the stable qcow2 through a disposable overlay using the direct
kernel/initrd path. This is a baseline POC boot, **not** the final UEFI path.

| Check | Result |
| --- | --- |
| Image checksum before boot | PASS |
| SSH readiness | PASS |
| Guest OS | Omarchy, kernel `7.2.8-9-omarchy` |
| Session | `Type=wayland`, `Active=yes`, `State=active`, `Remote=no` |
| Display manager | SDDM autologin to user `omarchy` |
| Hyprland | running |
| Quickshell | running (`quickshell -n -p /usr/share/omarchy/shell`) |
| Failed system units | none observed |
| Omarchy bar | initially hidden by default (`bar-off`); removing the toggle restored the layer |
| Axiom theme | installed as a user theme; shell restart required for palette/background reload |
| Axiom theme files | active `colors.toml`, aurora background symlink, Foot palette present |
| Process view | `btop` launched in Foot; ~190 guest processes visible |
| Host viewer | QEMU VNC on `127.0.0.1:5901`, noVNC on `127.0.0.1:6080`, Firefox window open |

Evidence artifacts (gitignored under `iso/out/evidence/phase2/omarchy-boot-1/`):

- `desktop-baseline.png`, `desktop-baseline-2.png`
- `desktop-after-wake.png`, `desktop-bar-visible.png`
- `axiom-theme-restarted.png`, `axiom-theme-processes.png`
- `process-view-2.png`
- `guest-status.txt`, `shell-diagnostics.txt`, `shell-layers.txt`,
  `display-diagnostics.txt`, `theme-diagnostics.txt`, `theme-foot-fix.txt`

### Findings from the baseline

- Standard QEMU VGA produces Mesa/EGL warnings and occasional partial wallpaper
  repaints; a `virtio-vga`/`qemu-desktop` path is still the preferred graphical
  test configuration.
- The default image hides the bar; `omarchy toggle bar off` removes the
  `bar-off` flag and restores it. The inverted naming is an upstream UX sharp
  edge.
- The lock screen did not accept the published test password through QEMU
  keystrokes; rebooting the disposable overlay returned to autologin. This needs
  a proper input-path test.
- A theme switch does not fully repaint the running shell; `omarchy-restart-shell`
  was required. The theme also initially lacked `foot.ini`; the Axiom theme now
  ships one.
- Guest listeners include SSH on `0.0.0.0:22`, mDNS on `0.0.0.0:5353`, Docker DNS
  on `172.17.0.1:53`, and CUPS on loopback. These must be reviewed/dispositioned
  before Phase 2 exit; the QEMU host forwards SSH only to localhost.

## Current limitations

- Baseline boot and desktop screenshots collected; Axiom theme applied and
  shell restarted successfully.
- QEMU standard VGA is a software/emulated path; it does not prove physical GPU
  behavior, and its Mesa/EGL warnings require a better virtual GPU path.
- The preinstalled VM boots via direct kernel/initrd in the initial harness. UEFI
  boot with OVMF and the final build recipe remain required.
- SDDM currently uses the Omarchy theme shell; only the user theme/logo path is
  covered. The login/lock styling still needs Axiom work.
- Secure Boot/TPM, snapshots, updates and the installer remain unverified.
- Unexpected-listener disposition and the lock-password input path remain open.
- Phase 2 exit is not claimed.

## Next evidence to collect

1. Re-run with a better virtual GPU (`virtio-vga`) or an authorized
   `qemu-desktop` install.
2. UEFI boot path with OVMF and a reproducible build recipe.
3. Network/audio/Bluetooth smoke and listener disposition.
4. SDDM/Plymouth Axiom logo replacement and login/lock styling.
5. Snapshot/update and failed-unit tests.
6. Axiom Shell replacement of Omarchy widgets (Phase 3).
