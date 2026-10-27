# Axiom Shell

Status: Phase 3 implementation (in progress). This is the first Axiom-owned Quickshell surface set
on Hyprland: top bar, workspace chips, launcher, dock, Control Center,
notifications, live process/system data and truthful AI/Shield/Flow status
placeholders.

The Axiom Shell does not depend on Plasma or Omarchy's shell. It does use
Hyprland for the compositor, Windows/workspaces and input policy, and the
installed Quickshell services for audio, power, networking and notifications.

`Super+Space` toggles the launcher through the binding in `hyprland.lua`; that
binding must be installed before the Hyprland session starts (a runtime append
is not picked up by `hyprctl reload`).

## Run in the test VM

```sh
tests/axiom-shell-run.sh \
  --key iso/out/evidence/phase2/omarchy-boot-1/state/id_ed25519 \
  --port 2222
```

The script copies this directory and the Axiom aurora image into
`~/.local/share/axiom/`, stops the Omarchy shell instance and starts Axiom Shell.
It is a disposable-guest test helper, not an installer or a privileged service.

## Test IPC

```sh
quickshell ipc call axiom.shell ping
quickshell ipc call axiom.shell openLauncher
quickshell ipc call axiom.shell openControl
quickshell ipc call axiom.shell closePanels
```

## Current scope

- top bar with workspace switching, launcher, clock, volume and power status
- keyboard-first application launcher using Quickshell `DesktopEntries`
- floating dock with core application shortcuts
- Control Center with live `/proc` load/memory/PSI/process snapshot
- notification daemon and toast cards
- original aurora wallpaper and graphite/teal tokens
- explicit indicators that AI, Shield and Flow are not connected yet

Not yet implemented: lock screen ownership, a full settings UI, per-monitor
variants, rich media controls, the final icon/mascot system, and production
packaging.
