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
| `bash scripts/build-phase2-foundation.sh` | PASS; new staged ISO SHA-256 `e0e7cc099829cf4cdfd54a4e00369822980d0faeaf4fdc541836256b25baab6d` |
| `tests/qemu-boot.sh` on that ISO | NOT VERIFIED: two attempts produced firmware/bootloader output but no serial login prompt; retained under `iso/out/evidence/phase3-iso-boot/` and treated as host/boot evidence gap, not shell success |
| `QT_QPA_PLATFORM=offscreen qs -p shell/axiom-shell.qml` | EXPECTED HOST LIMITATION: no Wayland `PanelWindow` backend outside a compositor |

The build staged `axiom-shell.qml` at
`/usr/share/omarchy/default/axiom-shell/axiom-shell.qml` and changed the
Hyprland autostart boundary to `axiom-shell-launch`. The ISO remains a
disposable validation artifact and is not a release deliverable.

## Open gates

The next guest run must use a real Hyprland user session and capture startup,
idle CPU/PSS, keyboard/focus/accessibility, mixed-DPI/multi-monitor behavior,
browser/Electron window controls, notification bus conflicts and service
failure/denial states. Dock pin persistence, full launcher search modes,
Control Center mutation contracts and thumbnail/drag workspace overview
presentation are not complete. The file-manager specification is recorded in
its dossier, but no replacement implementation is authorized. REA's native
decompiler providers are
not installed on this host, so no binary semantics are inferred from REA.
