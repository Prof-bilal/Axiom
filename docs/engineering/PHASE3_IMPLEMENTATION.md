# Phase 3 implementation evidence

Status: **IMPLEMENTATION / VALIDATION** (2026-10-28). This record covers the
first integrated Axiom Shell session; it is not a Phase 3 exit claim.

## Implemented surface

`[shell/axiom-shell.qml](../../shell/axiom-shell.qml)` is the integrated
Quickshell entry point. It owns no compositor state. The pinned native models
provide:

- Hyprland workspaces and active toplevel identity, including real workspace
  activation;
- DesktopEntries-backed launcher and dock activation through
  `DesktopEntry.execute()` or an existing native toplevel's `activate()`;
- notification ownership/count/history through the Quickshell notification
  service, with dismiss-on-selection behavior;
- read-only PipeWire readiness, UPower battery state and a session clock;
- a live textual workspace overview that activates real toplevels, plus a
  read-only Control Center for NetworkManager/BlueZ/PipeWire/UPower/power-
  profile health;
- explicit unavailable values instead of invented service status.

The existing `WindowState`/`WindowActions` adapters remain the only path for
window close, minimize, maximize and fullscreen operations. No root daemon,
privileged broker, arbitrary shell interpolation or AI control path was added.

## Evidence

| Check | Result |
| --- | --- |
| `python3 tests/axiom-shell-contract.py` | PASS: required native models and session-scoped operations present; privileged/process dispatch absent |
| `qmllint -I /usr/lib/qt6/qml ...` | PASS; Quickshell's abstract `PanelWindow` warnings are expected tooling metadata warnings |
| `python3 scripts/validate-repo.py` | PASS (0 foundation errors) |
| `python3 scripts/verify-rea.py` | PASS; REA 6.8.0, 229-tool catalog, pinned Quickshell Hyprland inventory evidence `ev_056eb0d504af8726ebd1a3258db52d9278b87aa4e8ac38c581553620fef9a80e` |
| `bash scripts/build-phase2-foundation.sh` | PASS; rebuilt staged ISO SHA-256 `ffe5b9347f3ecb3402bdfa515a0c22f2d1293982383a3c1550e0155be673cb7d`; the wrapper used the recorded Node.js cache SHA-256 `0fd1eb7770598f52a21995edf6ed35fc690400fa437c2386af329519e9143132` |
| `tests/qemu-boot.sh` on the rebuilt ISO | NOT VERIFIED: one UEFI attempt produced 113 bytes of graphical-terminal control output but no serial login prompt; retained under `iso/out/evidence/phase3-iso-boot-current/`. This is not converted into a shell-pass claim. |
| Direct kernel/initramfs QEMU boot from the rebuilt ISO | PASS for live guest core: KVM/QEMU 11.1.2 reached systemd Basic, Network, OpenSSH and User Login Management targets and an `archiso login:` prompt; clean HMP `system_powerdown` completed. Serial evidence is retained under `iso/out/evidence/phase3-direct-kernel-current/`. This bypasses UEFI and does not prove a graphical user session. |
| `QT_QPA_PLATFORM=offscreen qs -p shell/axiom-shell.qml` | EXPECTED HOST LIMITATION: no Wayland `PanelWindow` backend outside a compositor |

The QEMU workflow used the required disposable ISO path with QEMU 11.1.2,
OVMF `edk2-ovmf 202608-1`, KVM acceleration (`/dev/kvm` present), UEFI
`q35`, host CPU, 1536 MiB RAM, 2 vCPUs, no network, no host disk and a serial
file plus QEMU monitor. The harness retained both firmware variables and all
attempt logs. Attempt 1 stopped at firmware output; attempt 2 reached the DVD
bootloader but produced no serial kernel/login output before timeout. This is
an unresolved ISO/harness boot gate and is not converted into a shell-pass
claim.

The build staged `axiom-shell.qml` at
`/usr/share/omarchy/default/axiom-shell/axiom-shell.qml`, copied the
target-scoped `WindowActions` adapter and integrated control cluster, and
changed the Hyprland autostart boundary to `axiom-shell-launch`. The rebuilt
SquashFS was inspected directly: the ISO contains the launcher, Axiom shell,
window-controls surface/probes, asset, Axiom session entry and autostart
reference. The ISO remains a disposable validation artifact and is not a
release deliverable.

## Open gates

The next guest run must use a real Hyprland user session and capture startup,
idle CPU/PSS, keyboard/focus/accessibility, mixed-DPI/multi-monitor behavior,
browser/Electron window controls, notification bus conflicts and service
failure/denial states. The current live ISO boots an automatic root tty when
started with `graphical.target`; that is why direct guest-core evidence is
separate from the still-missing installed-session evidence. Dock pin
persistence, full launcher search modes, Control Center mutation contracts and
thumbnail/drag workspace overview presentation are not complete. The
file-manager specification is recorded in its dossier, but no replacement
implementation is authorized. REA's native decompiler providers are not
installed on this host, so no binary semantics are inferred from REA.
