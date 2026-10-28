# Window controls validation plan

Status: VALIDATION — current pinned Foot/Hyprland slice exercised; broader
application, accessibility and performance gates remain open.

## Functionality matrix

| Target | Close | Minimize/restore | Maximize/restore | Fullscreen | Result |
| --- | --- | --- | --- | --- | --- |
| Foot terminal | PASS | PASS | PASS | PASS | PASS in disposable KVM guest |
| Normal native app | required | required | required | required | NOT YET MEASURED |
| Browser | required | required | required | required | NOT YET MEASURED |
| Electron app | required | required | required | required | NOT YET MEASURED |
| Two same-app windows | target isolation required | target isolation required | target isolation required | target isolation required | close/max/fullscreen/minimize exercised on owned target; broader isolation matrix open |
| Two monitors/mixed scale | target remains correct | target remains correct | target remains correct | target remains correct | model placement PASS; action placement not yet measured |
| Locked/unavailable compositor | deny without mutation | deny without mutation | deny without mutation | deny without mutation | read-only lock/unavailable boundary PASS; action denial matrix open |

## Required evidence

- QML lint for the adapter, surface and probe.
- Disposable UEFI/KVM guest versions, command line, logs and owned overlay.
- Independent compositor observations plus native model observations.
- Target identity and process ownership checks; no title-based targeting.
- Negative cases: invalid address, unavailable backend, target closed during
  request, timeout, unsupported minimize, lock screen and second-window focus.
- Keyboard-only, accessibility-name, reduced-motion and multi-monitor checks.
- Performance protocol for shell startup, panel interaction and idle PSS/CPU;
  no universal speed claim from one guest.

## Current evidence

The integration harness `AXIOM_TEST_VM=1 python3 tests/window-controls-integration.py`
passed in the pinned guest: maximize/restore, fullscreen/exit,
private-workspace minimize/restore and close all verified against the same
canonical target. The native minimize property was attempted separately and
timed out, which is why the implementation records the private-workspace
policy rather than claiming protocol minimize support.

The visible surface mapped as a non-exclusive layer namespace
`axiom-window-controls` and rendered the active app identity. QML lint passed
for the action adapter, probe, theme and surface. This confirms integration and
mapping, not keyboard-only, pointer-focus, browser/Electron or visual-quality
completion. The guest used software/emulated graphics.

The result must update this file and the phase ledger. Rendering the cluster or
calling an IPC method once is insufficient for completion.

## Implementation update — 2026-10-28

The visible control cluster now exposes an explicit fullscreen toggle alongside
close, minimize/restore and maximize/restore. It uses the same canonical target
address and bounded `WindowActions` adapter as the existing controls; the
accessible name changes between entering and exiting fullscreen from the real
Wayland state. The surface remains a non-exclusive, non-keyboard-interactive
layer surface so it cannot steal compositor focus.

QML lint passes for the surface, adapter, probe and theme. The REA verifier also
passes against the installed Quickshell Hyprland module (server 6.8.0,
229-tool catalog, bounded directory evidence `ev_056eb0d504af8726ebd1a3258db52d9278b87aa4e8ac38c581553620fef9a80e`).
REA's native decompiler providers are not configured on this host; no binary
behavior is inferred from that unavailable probe.
