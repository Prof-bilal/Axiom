# Phase 3 evidence: Axiom Shell implementation

Status: **IN PROGRESS — no exit claim.** This records the first Axiom-owned
Quickshell shell slice on the Phase 2 Hyprland foundation. It is not yet a
complete Phase 3 acceptance record.

## Build/test environment

- Test VM: stable Omarchy 4.0.6 overlay, kernel `7.2.8-9-omarchy`
- Session: Hyprland `0.56.2`, Wayland, Quickshell `0.3.2.r7`
- Shell source: `shell/shell.qml`
- Wallpaper: `branding/theme/axiom/backgrounds/aurora.png`
- Runner: `tests/axiom-shell-run.sh` (replaces the Omarchy shell in the guest)

## Implemented surfaces

| Surface | State | Evidence |
| --- | --- | --- |
| Axiom top bar | working | `final-bar.png`, `final-shell.png` |
| Workspace chips + switching | working | IPC `workspace 2`; Hyprland reports active workspace `2` |
| Keyboard application launcher | working | `launcher-2.png`; typed `foot` + Enter launched `/usr/bin/foot` |
| Launcher Escape close | working | IPC state changed from `launcher` to `closed` after QEMU `sendkey esc` |
| Floating dock | working | `final-clean.png` |
| Control Center + live `/proc` metrics | working | `final-control.png`; load/mem/PSI/process count rendered, PSI wraps |
| Notification daemon + toast | working | `final-notification.png`; `notify-send` produced an Axiom toast |
| Axiom aurora wallpaper | working | `final-clean.png`, `real-desktop-6.png` |
| Axiom welcome surface | first pass | `real-desktop-6.png`; penguin panel, wordmark, `Welcome back`, action tiles on the empty desktop |
| Panel + dock penguin mark | working (system icon) | `real-desktop-6.png`; `preferences-system-linux` from the installed Breeze icon theme, pending original Axiom mascot |
| Status cluster | working | `real-desktop-6.png`; network/audio/battery icons + battery text + date-time clock; no raw service text in the bar |
| AI/Shield/Flow indicators | placeholder | Control Center labels not connected/not active/not measuring |
| Network indicator | working | bar shows the network icon while the VM user network is connected |
| Power/volume | working/no hardware | battery icon + `AC`; no audio sink in the VM so volume reads muted/zero |
| `Super+Space` launcher shortcut | working | runtime Hyprland binding; QEMU `sendkey meta_l-spc`; `shortcut-launcher-final.png` |

## Interaction tests

```sh
# Axiom Shell IPC
quickshell -p ~/.local/share/axiom/shell ipc call axiom.shell ping
quickshell -p ~/.local/share/axiom/shell ipc call axiom.shell openLauncher
quickshell -p ~/.local/share/axiom/shell ipc call axiom.shell openControl
quickshell -p ~/.local/share/axiom/shell ipc call axiom.shell workspace 2
quickshell -p ~/.local/share/axiom/shell ipc call axiom.shell launchTerminal
quickshell -p ~/.local/share/axiom/shell ipc call axiom.shell state
quickshell -p ~/.local/share/axiom/shell ipc call axiom.shell closePanels
```

Observed results:

- `ping` → `ok`
- launcher opens; default app list populated from `DesktopEntries`
- keyboard query `term` → no results in this image; `foot` → app launched
- `sendkey esc` → shell state `closed`
- `workspace 2` → Hyprland active workspace id `2`
- `launchTerminal` → `/usr/bin/foot`
- `notify-send` → Axiom toast with app/title/body
- `Super+Space` → launcher opens; `Escape` → closed
- shell resource snapshot after the interaction run: RSS `562552 KiB` (~549 MiB),
  `2.1%` CPU at ~4m13s uptime. This is one sample, not an idle benchmark or a
  performance claim; standard VGA/software rendering inflates it.

## Screenshots (gitignored)

Under `iso/out/evidence/phase3/`:

- `axiom-shell-first.png`
- `launcher.png`, `launcher-2.png`, `launcher-foot.png`
- `control-center.png`, `final-control.png`
- `notifications.png`, `final-notification.png`
- `final-bar.png`, `final-clean.png`, `final-shell.png`
- `shortcut-launcher-final.png`
- `real-desktop-4.png`, `real-desktop-5.png`, `real-desktop-6.png`

## Findings and limitations

- The Omarchy shell has a launcher parent that respawns Quickshell. The test
  runner now stops that parent and the old shell before starting Axiom Shell.
  The parent is matched with `pgrep -x omarchy-launch-` (kernel comm only); a
  `-f` match is present in the SSH command's own argv and kills the session.
- A QMP screenshot taken immediately after a shell reload can capture the
  pre-composited frame (flat background). The runner now forces a Hyprland
  repaint and waits before capture.
- The penguin mark is currently the installed Breeze `preferences-system-linux`
  icon. It satisfies the panel/dock requirement for this slice but is not the
  original Axiom mascot; the reference screens remain the target and an
  Axiom-owned asset still has to replace it.
- The welcome surface is a `Bottom` layer window masked to the card. It renders
  on the empty desktop, but its action-tile pointer interaction and its behavior
  under tiled windows are not yet verified.
- Omarchy’s shell and Axiom Shell must not run together: two notification
  daemons/bar surfaces conflict. Production packaging must make Axiom Shell the
  single session shell.
- The Hyprland user binding for `Super+Space` is staged in `shell/hyprland.lua`.
  `hyprctl reload` did not activate a newly appended Lua binding during the test;
  registering the same binding at runtime did, and the test verified the
  launcher. A packaged session must load the binding at login (or restart the
  Hyprland session after installing it).
- Standard QEMU VGA still emits Mesa/EGL warnings and some shell/window repaint
  artifacts. The VM path is not physical-GPU evidence.
- No audio sink is present in the VM, so the volume indicator reads `0%`.
- No battery device is present; the bar correctly reports `AC`.
- The lock screen, user switcher, settings, multi-monitor variants, reduced
  motion, accessibility audit and shell idle benchmark remain unverified.
- The top bar and dock are the first slice, not the final full Axiom Shell. The
  reference screens remain the target; icon/mascot and welcome-card interaction
  work is still pending.

## Next tests

1. Verify `Super+Space` after a clean session/packaged binding.
2. Launcher search with a real installed app set and keyboard Up/Down/Enter.
3. Notification dismiss, actions and critical notification behavior.
4. Control Center at 1366×768 and 4K; text scaling and reduced motion.
5. Lock-screen integration and a shell restart/crash recovery test.
6. Shell idle memory/CPU and frame timing on virtio-vga.
7. Multi-monitor `Variants` and per-monitor workspace behavior.
8. Welcome-card action tiles and replacement of the system penguin with the
   original Axiom mascot.
